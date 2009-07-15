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

import org.apache.log4j.Logger;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.fax.Fax;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportUtils;
import com.sinkluge.reports.letters.GenLetter;
import com.sinkluge.utilities.DocMailer;

public class Letters extends HttpServlet {

	private Logger log = Logger.getLogger(Letters.class);
	
	private static final long serialVersionUID = 4258208128744971882L;

	public String getServletName() {
		return "LettersServlet";
	}
	
	public void service(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		HttpSession session = request.getSession(true);
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		Info in = (Info) session.getServletContext().getAttribute("in");
		ResultSet rs = null;
		String id = request.getParameter("id");
		String query = "select contact_id, company_id, method from letter_contacts where (method = 'Email' or method = 'Fax') and letter_id = " + id;
		ResultSet info = null;
		boolean send = request.getPathInfo().indexOf("send") != -1;
		boolean[] action = {false, false, false};
		try {
			db.connect();
			rs = db.dbQuery("select logo from sites where site_id = " + attr.getSiteId());
			Image logo = null;
			if (rs.first()) logo = Image.getInstance(rs.getBytes(1));
			if (rs != null) rs.getStatement().close();
			rs = null;
			GenLetter gl = null;
			String job_id = "", fax, faxFixed;
			byte[] pdfKey = null;
			if (in.pdf_key != null) pdfKey = in.pdf_key.getBytes();
			Type t = Type.LETTER;
			DocMailer dm = new DocMailer(attr.getEmail(), attr.getFullName(), 
					"Please read attached letter.", in);
			if (send) {
				rs = db.dbQuery(query);
				while (rs.next()) {
					if (rs.getString("method").equals("Email")) {
						info = db.dbQuery(GenLetter.getQuery(id, rs.getString("contact_id"), 
							rs.getString("company_id")));
						gl = new GenLetter(info, attr.getJobName(), attr.get("short_name"));
						gl.create(in, logo);
						dm.removeAttachments();
						dm.addFiles(t, id, db);
						ReportUtils.addAttachments(gl, db, pdfKey, true, session);
						dm.addFile("Letter.pdf", "Letter", "application/pdf",
							gl.getStream().toByteArray());
						dm.setSubject(info.getString("subject"));
						dm.addTo(info.getString("email"));
						if (log.isDebugEnabled()) log.debug("Emailing letter to: "
								+ info.getString("email"));
						dm.send();
						action[0] = true;
						if (info != null) info.getStatement().close();
						info = null;
					} else if (rs.getString("method").equals("Fax")) {
						info = db.dbQuery(GenLetter.getQuery(id, rs.getString("contact_id"), 
								rs.getString("company_id")));
						gl = new GenLetter(info, attr.getJobName(), attr.get("short_name"));
						gl.create(in, logo);
						ReportUtils.addAttachments(gl, db, pdfKey, false, session);
						fax = info.getString("n.fax");			
						if (fax == null) fax = info.getString("c.fax");
						faxFixed = Fax.getFax(fax);
						if (faxFixed != null) {
							if (log.isDebugEnabled()) log.debug("Faxing letter to: "
									+ faxFixed);
							job_id = Fax.sendPDF(faxFixed, gl.getStream().toByteArray(), in);
							//Queues okay
							action[1] = true;
							if(!job_id.equals("0")) {
								Fax.logFax(job_id, fax, "Letter"
										, info.getString("name"), info.getString("company_name")
										, info.getString("subject"), session);
							}
						}
						if (info != null) info.getStatement().close();
						info = null;
					}
				}
			} // end send
			if (rs != null) rs.getStatement().close();
			boolean hasPrintedDocs = false;
			Report r = ReportUtils.getAppendableReport();
			query = "select contact_id, company_id, method from letter_contacts where method = 'Print' and letter_id = " + id;
			rs = db.dbQuery(query);
			while (rs.next()) {
				hasPrintedDocs = true;
				log.debug("Printing letter");
				info = db.dbQuery(GenLetter.getQuery(id, rs.getString("contact_id"), 
						rs.getString("company_id")));
				gl = new GenLetter(info, attr.getJobName(), attr.get("short_name"));
				gl.create(in, logo);
				ReportUtils.addAttachments(gl, db, pdfKey, false, session);
				log.debug("Attachments added, now combining letter reports");
				ReportUtils.add(gl, r, false, pdfKey);
				if (info != null) info.close();
				info = null;
			}
		// End inserted crap
			if (r != null && hasPrintedDocs && !send) {
				response.setHeader("Cache-Control", "private");
				response.setHeader("Pragma", "expires"); 
				response.setContentType("application/pdf");
				response.setContentLength(r.getStream().size());
				ServletOutputStream out = response.getOutputStream();
				r.getStream().writeTo(out);
				out.flush();
				out.close();
				action[2] = true;
			} else {
				response.setContentType("text/html");
				PrintWriter pw = response.getWriter();
				pw.println("<html><script>");
				if (send) pw.println("window.alert('Emails sent" + 
					(in.hasFax ? " and faxes queued" : "") + ".');");
				else if (!hasPrintedDocs) pw.println("window.alert('No print recipients selected.');");
				pw.println("window.close();</script></html>");
				pw.flush();
				pw.close();
			}
			if (action[0]) com.sinkluge.utilities.ItemLogger.Emailed.update(
					com.sinkluge.Type.LETTER, id, session);
			if (action[1]) com.sinkluge.utilities.ItemLogger.Faxed.update(
					com.sinkluge.Type.LETTER, id, session);
			if (action[2]) com.sinkluge.utilities.ItemLogger.Printed.update(
					com.sinkluge.Type.LETTER, id, session);
		} catch (IOException e) {
			throw new ServletException("Letters: " + e.toString(), e);
		} catch (SQLException e) {
			throw new ServletException("Letters: " + e.toString(), e);
		} catch (Exception e) {
			throw new ServletException("Letters: " + e.toString(), e);
		} finally {
			try {
				
				if (rs != null) rs.getStatement().close();
				rs = null;
				if (db != null) db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("Letters Exception: " ,e);
			}
		}
	}
	
}
