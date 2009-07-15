package com.sinkluge.servlets;

import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.sinkluge.database.Database;

public class Logo extends HttpServlet {

	private static final long serialVersionUID = 6866379934104053561L;

	public String getServletName() {
		return "LogoServlet";
	}

	public void service(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		Database db = new Database();
		String siteId = request.getParameter("site_id");
		ResultSet rs = null;
		try {
			rs = db.dbQuery("select * from sites where site_id = " + siteId);
			if (rs.first()) {
				response.setContentType(rs.getString("content_type"));
				byte[] by = rs.getBytes("logo");
				if (by != null) {
					response.setContentLength(by.length);
					ServletOutputStream out = response.getOutputStream();
					out.write(by);
					out.flush();
					out.close();
				} else {
					response.sendError(HttpServletResponse.SC_NOT_FOUND, "No logo has been uploaded");
				}
			}
		} catch (Exception e) {
			throw new ServletException("Logo Servlet: ", e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
		}
	}
	
}
