/***********************************************************************************************************************
Copyright (c) 2003
Grant Ellsworth
Sinkluge Date Systems
All rights reserved.

Version 0.8
Revised: 7 July 2003
***********************************************************************************************************************/

package com.sinkluge.servlets;

import java.sql.ResultSet;
import java.sql.SQLException;
import com.sinkluge.utilities.DataUtils;
import com.sinkluge.database.Database;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class VCardServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1533794702655425795L;

	/**
	 * From HttpServlet.
	 * @return The literal string 'barbecue'
	 */
	public String getServletName() {
		return "vCardServ";
	}

	/**
	 * From HttpServlet.
	 * @param req The servlet request
	 * @param res The servlet response
	 * @throws ServletException If an error occurs during processing
	 */
	public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException {
		doRequest(req, res);
	}

	/**
	 * From HttpServlet.
	 * @param req The servlet request
	 * @param res The servlet response
	 * @throws ServletException If an error occurs during processing
	 */
	public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException {
		doRequest(req, res);
	}

	private void doRequest(HttpServletRequest req, HttpServletResponse res) throws ServletException {
		String contact_id = req.getParameter("contact_id");
		String company_id = req.getParameter("company_id");
		ResultSet rs = null;
		Database db = new Database();
		try {
			String query;
			if (contact_id != null) query = "select name, cn.address, cn.city, cn.state, cn.zip, title, " +
				"company_name, cn.fax, cn.phone, cn.mobile_phone, cn.email, website, description from contacts as cn, " +
				"company where cn.company_id = company.company_id and contact_id = " + contact_id;
			else query = "select company_name, address, city, state, zip, fax, phone, website, description from " +
				"company where company_id = " + company_id;
			rs = db.dbQuery(query);
			rs.next();
			res.setContentType("text/x-vcard");
			ServletOutputStream out = res.getOutputStream();
			out.println("BEGIN:VCARD\nVERSION:2.1");
			out.println("ORG:" + DataUtils.chkForm(rs.getString("company_name")));
			out.println("TEL;WORK;VOICE:" + DataUtils.chkForm(rs.getString("phone")));
			out.println("TEL;WORK;FAX:" + DataUtils.chkForm(rs.getString("fax")));
			out.println("NOTE;ENCODING=QUOTED-PRINTABLE:" + DataUtils.chkForm(rs.getString("description")));
			out.println("ADR;WORK:;;" + DataUtils.chkForm(rs.getString("address")) + ";" + 
					DataUtils.chkForm(rs.getString("city")) + ";" + DataUtils.chkForm(rs.getString("state")) + ";" + 
					DataUtils.chkForm(rs.getString("zip")) + ";" + "United States of America");
			out.println("URL;WORK:" + DataUtils.chkForm(rs.getString("website")));
			if (contact_id != null) {
				String name = DataUtils.chkForm(rs.getString("name"));
				int first = name.indexOf(" ");
				int last = name.lastIndexOf(" ");
				String tout;
				if (last == -1) tout = name;
				else tout = name.substring(last);
				if (first != -1) {
					if (first == last) tout += ";" + name.substring(0, first);
					else tout += ";" + name.substring(0, first) + ";" + name.substring(first, last);
				}
				out.println("N:" + tout);
				out.println("FN:" + name);
				out.println("TEL;CELL;VOICE:" + DataUtils.chkForm(rs.getString("mobile_phone")));
				out.println("TITLE:" + DataUtils.chkForm(rs.getString("title")));
				out.println("EMAIL;PREF;INTERNET:" + DataUtils.chkForm(rs.getString("email")));
			}
			out.println("REV:" + (new java.util.Date()).toString());
			out.println("END:VCARD");
			out.flush();
			out.close();
		} catch(SQLException e) {
			throw new ServletException("vCardServ SQLException: ",e);
		} catch(Exception io) {
			throw new ServletException("vCardServ Exception: ",io);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("vCardServ Exception: " ,e);
			}
		}
	}

}
