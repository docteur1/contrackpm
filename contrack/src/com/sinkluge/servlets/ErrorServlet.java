package com.sinkluge.servlets;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;

import com.sinkluge.database.Database;
import com.sinkluge.utilities.FormHelper;

/**
 * Servlet implementation class ErrorServlet
 */
public class ErrorServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ErrorServlet() {
        super();
    }

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Database db = null;
		ResultSet rs = null;
		try {
			db = new Database();
			rs = db.dbQuery("select * from error_log where id = " + request.getParameter("id"));
			if (rs.next()) {
				String msg = StringUtils.replace(rs.getString("message"), "<br>", "\r\n");
				msg = StringUtils.replace(msg, "&nbsp;", " ");
				msg = StringUtils.replace(msg, "<BR>", "\r\n");
				msg = FormHelper.string(rs.getString("comments"))
					+ "\r\n****************************************************************\r\n"
					+ FormHelper.timestamp(rs.getTimestamp("error_time")) + "\r\n" + msg;
				String name = "Error_" + rs.getInt("id") + ".txt";
				response.setHeader ("Content-Disposition", "attachment; filename=\"" + name + "\"");
				response.setContentType("text/plain");
				ServletOutputStream out = response.getOutputStream();
				out.print(msg);
				out.flush();
				out.close();
			}
		} catch (Exception e) {
			throw new ServletException("Error in ErrorServlet", e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			} catch (SQLException e) {}
		}
	}

}
