package com.sinkluge.servlet;

import org.apache.commons.io.output.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.zip.InflaterInputStream;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.sinkluge.database.Database;

public class FileServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = -50461397475755926L;

	public void doGet(HttpServletRequest request, HttpServletResponse response)
		throws ServletException {
		ResultSet rs = null;
		String id = request.getParameter("id");
		HttpSession session = request.getSession();
		Database db = (Database) session.getAttribute("db");
		try{
			if (db == null) db = new Database();
			db.connect();
			rs = db.getStatement().executeQuery("select content_type, filename, size, "
					+ "file from files where protected = 0 and file_id = " + id);
			if (rs.next()) {
				response.setContentType(rs.getString("content_type"));
				response.setHeader ("Content-Disposition", "attachment; filename=\"" + 
						rs.getString("filename") + "\"");
				response.setHeader ("Pragma", "expires");
				response.setHeader ("Cache-Control", "private");
				try {
					ServletOutputStream out = response.getOutputStream();
					InflaterInputStream iis = new InflaterInputStream(rs.getBinaryStream("file"));
					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					int b = 0;
					do {
						b = iis.read();
						baos.write(b);
					} while (b != -1);
					iis.close();
					response.setContentLength(baos.size());	
					baos.writeTo(out);
					baos.close();
					out.flush();
					out.close();
				} catch (IOException e) {
					throw new ServletException (e);
				}
			} else throw new ServletException ("File " + id + " not found");
		} catch (SQLException e) {
			throw new ServletException (e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				if (db != null) db.disconnect();
			} catch (SQLException e) {}
		}
	}
	
}
