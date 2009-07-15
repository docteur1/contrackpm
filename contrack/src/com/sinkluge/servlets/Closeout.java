package com.sinkluge.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.io.output.ByteArrayOutputStream;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.fax.Fax;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportUtils;
import com.sinkluge.reports.contracts.GenCloseout;
import com.sinkluge.reports.contracts.GenWarranty;
import com.sinkluge.utilities.BigString;
import com.sinkluge.utilities.DocMailer;
import com.sinkluge.utilities.ItemLogger;

public class Closeout extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 4258208128744971882L;

	public String getServletName() {
		return "CloseoutServlet";
	}

	public void service(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		HttpSession session = request.getSession(true);
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		Info in = (Info) session.getServletContext().getAttribute("in");
		ResultSet rs = null;
		String query = "select contract_id, contact_id, company.company_id, company_name, name, email, company.fax, "
			+ "contacts.fax, req_warranty, "
			+ "have_warranty from contracts join company on company.company_id = contracts.company_id left join "
			+ "contacts using(contact_id) where contracts.job_id = " + attr.getJobId() + " order by company_name";
		ResultSet info = null;
		try {
			rs = db.dbQuery("select logo from sites where site_id = " + attr.getSiteId());
			Image logo = null;
			if (rs.first()) logo = Image.getInstance(rs.getBytes(1));
			if (rs != null) rs.getStatement().close();
			rs = null;
			String contract_id;
			String closeout = null, warranty = null;
			BigString email = null;
			info = db.dbQuery(GenCloseout.getQuery2(null));
			if (info.first()) closeout = info.getString(1);
			info.getStatement().close();
			info = db.dbQuery(GenWarranty.getQuery2(null));
			if (info.first()) warranty = info.getString(1);
			info.getStatement().close();
			info = db.dbQuery("select txt from reports where id = 'closeoutEmail'");
			if (info.first()) email = new BigString(info.getString(1));
			email.setProjectName(attr.getJobName());
			info.getStatement().close();
			rs = db.dbQuery(query);
			GenCloseout gc;
			GenWarranty gw;
			byte[] pdfKey = null;
			if (in.pdf_key != null) pdfKey = in.pdf_key.getBytes();
			while (rs.next()) {
				contract_id = rs.getString("contract_id");
				if (request.getParameter("d" + contract_id) != null && 
						request.getParameter("s" + contract_id).equals("email")) {
					info = db.dbQuery(GenCloseout.getQuery(contract_id));
					gc = new GenCloseout(info, closeout);
					gc.create(in, logo);
					ReportUtils.stamp(gc);
					if (info != null) info.close();
					info = null;
					gw = null;
					if (!rs.getString("have_warranty").equals("y") && 
							rs.getString("req_warranty").equals("y")) {
						info = db.dbQuery(GenWarranty.getQuery(contract_id));
						gw = new GenWarranty(info, warranty, attr.getJobName());
						gw.create(in, logo);
						if (info != null) info.close();
						info = null;
					}
					if (gw != null) ReportUtils.add(gw, gc, true, pdfKey);
					ItemLogger.Emailed.update(Type.SUBCONTRACT, contract_id, "Closeout Documents", rs.getInt("contact_id"), 
						rs.getInt("company_id"), session);
					DocMailer.sendMessage(attr.getEmail(), attr.getFullName(), rs.getString("email"), 
						"Closeout.pdf", "Project Closeout", email.toString(), 
						gc.getStream().toByteArray(), in);
				}
			}
			rs.beforeFirst();
			String job_id = "", fax, faxFixed;
			while (rs.next()) {
				contract_id = rs.getString("contract_id");
				if (request.getParameter("d" + contract_id) != null && 
						request.getParameter("s" + contract_id).equals("fax")) {
					info = db.dbQuery(GenCloseout.getQuery(contract_id));
					gc = new GenCloseout(info, closeout);
					gc.create(in, logo);
					ReportUtils.stamp(gc);
					if (info != null) info.close();
					info = null;
					gw = null;
					if (!rs.getString("have_warranty").equals("y") && 
							rs.getString("req_warranty").equals("y")) {
						info = db.dbQuery(GenWarranty.getQuery(contract_id));
						gw = new GenWarranty(info, warranty, attr.getJobName());
						gw.create(in, logo);
						if (info != null) info.close();
						info = null;
					}
					if (gw != null) ReportUtils.add(gw, gc, true, null);	
					fax = rs.getString("contacts.fax");			
					if (fax == null) fax = rs.getString("company.fax");
					faxFixed = Fax.getFax(fax);
					if (faxFixed != null) {
						job_id = Fax.sendPDF(faxFixed, gc.getStream().toByteArray(), in);
						//Queues okay
						if(!job_id.equals("0")) {
							ItemLogger.Faxed.update(Type.SUBCONTRACT, contract_id, "Closeout documents faxed to "
								+ fax + ".", rs.getInt("contact_id"), rs.getInt("company_id"), session);
							Fax.logFax(job_id, fax, "Closeout Docs"
								, rs.getString("name"), rs.getString("company_name")
								, "Closeout Docs", session);
						}
					}
				}
			}
			rs.beforeFirst();
			Report r = ReportUtils.getAppendableReport();
			while (rs.next()) {
				contract_id = rs.getString("contract_id");
				if (request.getParameter("d" + contract_id) != null && 
						request.getParameter("s" + contract_id).equals("print")) {
					ItemLogger.Printed.update(Type.SUBCONTRACT, contract_id, "Closeout documents printed.", session);
					info = db.dbQuery(GenCloseout.getQuery(contract_id));
					gc = new GenCloseout(info, closeout);
					gc.create(in, logo);
					ReportUtils.add(gc, r, true, pdfKey);
					if (info != null) info.close();
					info = null;
					gw = null;
					if (!rs.getString("have_warranty").equals("y") && 
							rs.getString("req_warranty").equals("y")) {
						info = db.dbQuery(GenWarranty.getQuery(contract_id));
						gw = new GenWarranty(info, warranty, attr.getJobName());
						gw.create(in, logo);
						if (info != null) info.close();
						info = null;
					}
					if (gw != null) ReportUtils.add(gw, r, true, pdfKey);	
				}
			}
		
		// End inserted crap
			if (r != null) {
				ByteArrayOutputStream baos = r.getStream();
				response.setHeader("Cache-Control", "private");
				response.setHeader("Pragma", "expires"); 
				response.setContentType("application/pdf");
				response.setContentLength(baos.size());
				ServletOutputStream out = response.getOutputStream();
				baos.writeTo(out);
				out.flush();
				out.close();
			} else {
				response.setContentType("text/html");
				PrintWriter pw = response.getWriter();
				pw.println("<html><script>window.alert('Nothing to Print');");
				pw.println("window.close();</script></html>");
				pw.flush();
				pw.close();
			}
		} catch (IOException e) {
			throw new ServletException("Closeout: " + e.toString(), e);
		} catch (SQLException e) {
			throw new ServletException("Closeout: " + e.toString(), e);
		} catch (Exception e) {
			throw new ServletException("Closeout: " + e.toString(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("Closeout Exception: " ,e);
			}
		}
	}
	
}
