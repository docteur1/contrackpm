package com.sinkluge.servlets;

import org.apache.commons.io.output.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.zip.InflaterInputStream;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.sinkluge.database.Database;

public class FileServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = -50461397475755926L;

	public static InputStream getFileAsInputStream(ResultSet rs) throws Exception {
		return new InflaterInputStream(rs.getBinaryStream("file"));
	}
	
	public static ByteArrayOutputStream getFileAsOutputStream(ResultSet rs) throws Exception {
		InputStream is = getFileAsInputStream(rs);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		baos.write(is);
		is.close();
		return baos;
	}
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
		throws ServletException {
		Logger log = Logger.getLogger(FileServlet.class);
		ResultSet rs = null;
		String id = request.getParameter("id");
		Database db = new Database();
		try {
			rs = db.dbQuery("select content_type, filename, size, "
					+ "file from files where file_id = " + id);
			if (rs.first()) {
				response.setContentType(rs.getString("content_type"));
				response.setHeader ("Content-Disposition", "attachment; filename=\"" + 
						rs.getString("filename") + "\"");
				response.setHeader ("Pragma", "expires");
				response.setHeader ("Cache-Control", "private");
				try {
					log.debug("get file " + id);
					ServletOutputStream out = response.getOutputStream();
					ByteArrayOutputStream baos = getFileAsOutputStream(rs);
					response.setContentLength(baos.size());	
					baos.writeTo(out);
					baos.close();
					out.flush();
					out.close();
				} catch (IOException e) {
					throw new ServletException (e);
				}
			} else throw new ServletException ("File " + id + " not found");
		} catch (Exception e) {
			throw new ServletException (e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {}
		}
	}
	
}
