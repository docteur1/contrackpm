package com.sinkluge.servlets;

import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.log4j.Logger;

import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.documents.KFWImage;

public class AccountingImage extends HttpServlet {

	private static final long serialVersionUID = 1L;
	
	Logger log = Logger.getLogger(AccountingImage.class);
	
	@Override
	public void service(HttpServletRequest request, HttpServletResponse response) 
		throws ServletException {
		ResultSet rs = null;
		Database db = null;
		try {
			db = new Database();
			String id = request.getParameter("id");
			rs = db.dbQuery("select site_id, document_key from kfw_documents " +
				"where document_id = " + id);
			if (rs.next()) {
				if (rs.getString("document_key").equals(request.getParameter("key"))) {
					Report r = new KFWImage(id, rs.getInt("site_id"), getServletContext());
					// no need to call r.create() since it doesn't do anything.
					ByteArrayOutputStream baos = r.getStream();
					response.setContentLength(baos.size());
					response.setHeader("Cache-Control", "private");
					response.setHeader("Pragma", "expires"); 
					response.setContentType("application/pdf");
					ServletOutputStream out = response.getOutputStream();
					baos.writeTo(out);
				} else response.sendError(HttpServletResponse.SC_FORBIDDEN,
					"The supplied key \"" + request.getParameter("key")
					+ "\" does not match the index key in Contrack");
			} else response.sendError(HttpServletResponse.SC_NOT_FOUND,
				"Document id " + request.getParameter("id") + " does not"
				+ "exist or has not been indexed by Contrack");
		} catch (Exception e) {
			handleException("service: Exception", e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			} catch (Exception e) {
				handleException("service: cleanup Exception", e);
			}
		}
	}
	
	private void handleException(String msg, Throwable t) throws ServletException {
		log.error(msg, t);
		throw new ServletException(msg, t);
	}
	
}
