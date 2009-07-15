package com.sinkluge.servlets;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import accounting.Cost;

import com.sinkluge.accounting.AccountingUtils;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.security.Name;
import com.sinkluge.security.Permission;
import com.sinkluge.security.Security;

public class CSV extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = -613926148863682228L;

	public String getServletName() {
		return "CSVExportServlet";
	}

	public void service(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		ResultSet rs = null;
		HttpSession session = request.getSession(true);
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		Security sec = (Security) session.getAttribute("sec");
		String path = request.getPathInfo();
		String query;
		try {
			db.connect();
			response.setContentType("text/csv");
			ServletOutputStream out = response.getOutputStream();
			if (path.indexOf("project") != -1) {
				response.setHeader ("Content-Disposition", "attachment; filename=\"Project Contacts.csv\"");
				query = "(select c.company_name, c.phone as cp, c.fax as cf, n.phone as np, n.fax as nf, n.name, n.email, n.mobile_phone,"
					+ "type, c.address as ca, c.city as cc, c.state as cs, c.zip as cz, n.address as na, n.city as nc, n.state as ns, n.zip as nz, null as cost_code, "
					+ "null as phase_code, null as division, title, null as code_description from ((job_contacts left join "
					+ "contacts as n using(contact_id)) left join company as c on "
					+ "c.company_id = job_contacts.company_id) where job_id = " + attr.getJobId() + ") ";
				query += "union (select distinct c.company_name, c.phone as cp, c.fax as cf, n.phone as np, n.fax as nf, n.name, n.email, n.mobile_phone,"
					+ "null as type, c.address as ca, c.city as cc, c.state as cs, c.zip as cz, n.address as na, n.city as nc, n.state as ns, n.zip as nz, "
					+ "cost_code, phase_code, division, null as title, code_description from (((contracts left join contacts as n using(contact_id)) left join company as c on "
					+ "contracts.company_id = c.company_id) left join job_cost_detail using (cost_code_id)) where contracts.job_id = " + attr.getJobId() + ") order by company_name, type desc";
				rs = db.dbQuery(query);
				out.println("Company,Name,Job Title,Business Phone,Business Fax,Mobile Phone,E-mail Address,Type,Division,Code,Phase,Trade,Business Street,Business City,Business State,Business Postal Code");
				String name, title, trade, phone, fax, mobile, type, code, address, city, state, zip, email;
				while (rs.next()) {
					name = rs.getString("name");
					if (name == null) {
						name = "";
						trade = rs.getString("code_description");
						if (trade == null) trade = "";
						phone = rs.getString("cp");
						if (phone == null) phone = "";
						title = rs.getString("title");
						if (title == null) title = "";
						fax = rs.getString("cf");
						if (fax == null) fax = "";
						mobile = "";
						type = rs.getString("type");
						if (type == null) type = "Contract";
						code = rs.getString("cost_code");
						if (code == null) code = "\",\"\",\"";
						else code = rs.getString("division") + "\",\"" + rs.getString("cost_code") 
							+ "\",\"" + rs.getString("phase_code");
						address = rs.getString("ca");
						if (address == null) address = "";
						email = "";
						city = rs.getString("cc");
						if (city == null) city = "";
						state = rs.getString("cs");
						if (state == null) state = "";
						zip = rs.getString("cz");
						if (zip == null) zip = "";
					} else {
						trade = rs.getString("code_description");
						if (trade == null) trade = "";
						phone = rs.getString("np");
						if (phone == null) phone = "";
						title = rs.getString("title");
						if (title == null) title = "";
						fax = rs.getString("nf");
						if (fax == null) fax = "";
						mobile = rs.getString("mobile_phone");
						if (mobile == null) mobile = "";
						type = rs.getString("type");
						if (type == null) type = "Contract";
						code = rs.getString("cost_code");
						code = rs.getString("cost_code");
						if (code == null) code = "\",\"\",\"";
						else code = rs.getString("division") + "\",\"" + rs.getString("cost_code") 
							+ "\",\"" + rs.getString("phase_code");
						address = rs.getString("na");
						if (address == null) address = "";
						email = rs.getString("email");
						if (email == null) email = "";
						city = rs.getString("nc");
						if (city == null) city = "";
						state = rs.getString("ns");
						if (state == null) state = "";
						zip = rs.getString("nz");
						if (zip == null) zip = "";
					}
					out.print("\"" + rs.getString("company_name") + "\",\"" + name + "\",\"" + title + "\",\"");
					out.print(phone + "\",\"" + fax + "\",\"" + mobile + "\",\"" + email + "\",\"" + type + "\",\"");
					out.println(code + "\",\"" + trade + "\",\"" + address + "\",\"" + city + "\",\"" + state + "\",\"" + zip + "\"");
				}
			} else if (path.indexOf("costDetails") != -1) {
				if (!sec.ok(Name.ACCOUNTING_DATA, Permission.PRINT)) response.sendRedirect("../../accessDenied.html");
				response.setHeader ("Content-Disposition", "attachment; filename=\"Project Cost Details.csv\"");
				out.println("\"Div\",\"Phase\",\"Type\",\"Name\",\"Invoice\",\"Date\",\"Cost\",\"Hours\",\"Description\"");
				String inv, desc, name;
				List<Cost> costs = AccountingUtils.getAccounting(session).getAllCosts(attr.getJobNum());
				Cost data;
				SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
				for (Iterator<Cost> i = costs.iterator(); i.hasNext(); ) {
					data = i.next();
					inv = data.getInvoiceNum();
					inv = inv == null?"":inv;
					desc = data.getDescription();
					desc = desc == null?"":desc;
					name = data.getName();
					name = name == null?"":name;
					out.println("\"" + data.getCode().getDivision() + "\",\"" + data.getCode().getCostCode() + "\",\"" 
							+ data.getCode().getPhaseCode() + "\",\"" + name + "\",\"" + inv + "\",\"" + 
							sdf.format(data.getDate()) + "\",\"" + data.getCost() + "\",\"" 
							+ data.getHours() + "\",\"" + desc + "\"");
				}
				costs.clear();
				costs = null;
			} else if (path.indexOf("costs") != -1) {
				if (!sec.ok(Name.ACCOUNTING, Permission.PRINT) || !sec.ok(Name.COSTS, Permission.PRINT)) 
					response.sendRedirect("../../accessDenied.html");
				response.setHeader ("Content-Disposition", "attachment; filename=\"Project Costs.csv\"");
				double estimate = 0;
				double contract = 0;
				double budget = 0;
				double co = 0;
				double ctd = 0;
				double etc = 0;
				int job_id = attr.getJobId();
				//Variables used to put in header info

				//Build resultsets
				//Here we need to add daysCost to other column in co_temp
				// Build the rs
				query = "select jcd.cost_code_id, jcd.division, jcd.cost_code, jcd.code_description as description, jcd.phase_code, estimate, budget, "
					+ "cost_to_complete, percent_complete, pm_cost_to_date, c.amount, sum(cr.amount) as cr_amount from "
					+ "job_cost_detail as jcd left join contracts as c on jcd.cost_code_id = c.cost_code_id left join changes as cr "
					+ "on jcd.cost_code_id = cr.cost_code_id where jcd.job_id = " + job_id + " group by jcd.cost_code_id order by costorder(division), costorder(cost_code), phase_code";
				rs = db.dbQuery(query);

				//Put column headers in
				out.println("Div,Phase,Type,Description,Estimate,Contract,Start Budget,Changes,Cost to Date,Est to Complete,Est Over,Est Total Cost");
				while (rs.next()) {
						// Get line info
					estimate = rs.getDouble("estimate");
					contract = rs.getDouble("amount");
					budget = rs.getDouble("budget");
					co = rs.getDouble("cr_amount");
					//addCo = rs.getDouble("co_other");
					ctd = rs.getDouble("pm_cost_to_date");
					etc = rs.getDouble("cost_to_complete");

					// Output the indivdual line.
					out.println("\"" + rs.getString("division") + "\",\"" + rs.getString("cost_code") + "\",\"" 
						+ rs.getString("phase_code") + "\",\"" + rs.getString("description") + "\",\""
						+ estimate + "\",\""  + contract + "\",\""  + budget + "\",\""  + co + "\",\""
						+ ctd + "\",\""  + etc + "\",\""  + (ctd + etc - (budget + co)) + "\",\""  
						+ (ctd + etc) + "\"");

				} // End adding rows.

				if (rs != null) rs.getStatement().close();
				rs = null;
			}
			out.flush();
			out.close();
		} catch(SQLException e) {
			throw new ServletException("CVS SQLException: ",e);
		} catch(Exception io) {
			throw new ServletException("CVS Exception: ", io);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("CVS Exception: " ,e);
			}
		}
	}
}
