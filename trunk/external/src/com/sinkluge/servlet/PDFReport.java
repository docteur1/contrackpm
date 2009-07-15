package com.sinkluge.servlet;

import java.io.IOException;
import java.sql.PreparedStatement;
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
import com.sinkluge.database.Database;
import com.sinkluge.reports.ErrorReport;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.changes.GenChangeAuthorizationSummary;
import com.sinkluge.reports.payRequests.GenFinalPayment;
import com.sinkluge.reports.payRequests.GenMonthlyPayment;
import com.sinkluge.reports.rfi.GenRFIDocument;
import com.sinkluge.reports.submittals.GenSubmittalToArch;
import com.sinkluge.reports.submittals.GenSubmittalToSub;

public class PDFReport extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = -5109640726679253133L;

	public String getServletName() {
		return "ReportServlet";
	}
	
	/*
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

	private void doRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException {
		HttpSession session = request.getSession(true);
		Database db = (Database) session.getAttribute("db");
		Info in = (Info) session.getServletContext().getAttribute("in");
		String path = request.getPathInfo();
		String id = request.getParameter("id");
		PreparedStatement ps = null;
		ByteArrayOutputStream baos = getBytes(request, path, id, db, in);
		try {
			if (baos != null) {
				response.setContentLength(baos.size());
				response.setHeader("Cache-Control", "private");
				response.setHeader("Pragma", "expires"); 
				response.setContentType("application/pdf");
				ServletOutputStream out = response.getOutputStream();
				baos.writeTo(out);
				out.flush();
				out.close();
			} else throw new ServletException("Report: Nothing to output.");
		} catch (IOException e) {
			throw new ServletException("Report: " + e.toString(), e);
		//} catch (SQLException e) {
		//	throw new ServletException("Report: " + e.toString(), e);
		} catch (Exception e) {
			throw new ServletException("Report: " + e.toString(), e);
		} finally {
			try {
				if (ps != null) ps.close();
				db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("Report Exception: " ,e);
			}
		}
	}
	
	private ByteArrayOutputStream getBytes(HttpServletRequest request, String path, String id, Database db, Info in) throws ServletException {
		db.connect();
		ResultSet rs = null;
		ResultSet rs2 = null;
		ResultSet rs3 = null;
		Report rep;
		//String add = request.getParameter("add");
		ByteArrayOutputStream baos = null;
		Image logo = null;
		try {
			rs = db.dbQuery("select logo from sites where site_id = " + db.site_id);
			if (rs.first()) logo = Image.getInstance(rs.getBytes(1));
			if (rs != null) rs.getStatement().close();
			rs = null;
			if (path.indexOf("sl") != -1) {
				if (path.indexOf("Architect") != -1) rep = new GenSubmittalToArch(id, db);
				else rep = new GenSubmittalToSub(id, db);
			/*
			 * Pay Requests
			 */
			} else if (path.indexOf("pr") != -1) {
				if (path.indexOf("Month") != -1) {
					rs = db.dbQuery(GenMonthlyPayment.getQuery(id));
					rs2 = db.dbQuery(GenMonthlyPayment.getQuery2());
					rs2.first();
					rep = new GenMonthlyPayment(rs, rs2.getString(1), db.get("full_name"));
				} else {
					rs = db.dbQuery(GenFinalPayment.getQuery(id));
					rs2 = db.dbQuery(GenFinalPayment.getQuery2());
					rs2.first();
					rep = new GenFinalPayment(rs, rs2.getString(1), db.get("full_name"));
				}
			}
			/*
			 * Change Orders
			 */
			else if (path.indexOf("changes") != -1) {
				rep = new GenChangeAuthorizationSummary(db);
			} else if (path.indexOf("rfi") != -1) {
				rs = db.dbQuery(GenRFIDocument.getQuery(id));
				if (!rs.isBeforeFirst()) {
					rs.getStatement().close();
					rs = db.dbQuery(GenRFIDocument.getQuery2(id));
				}
				rep = new GenRFIDocument(rs, db.job_name); 
			/* else if (path.indexOf("Transmittal") != -1) {
				if (path.indexOf("my") != -1) {
					rs = db.dbQuery(GenTransmittal.getQuery(id, true));
					rep = new GenTransmittal(rs, null, true);
				} else {
					rs = db.dbQuery(GenTransmittal.getQuery(id));
					rep = new GenTransmittal(rs, attr.getJobName());
				}
				*/
			} else rep = new ErrorReport();
			baos = rep.create(in, logo);
			rep.doCleanup(db);
			rep = null;
		} catch (IOException e) {
			throw new ServletException("Report: " + e.toString(), e);
		} catch (SQLException e) {
			throw new ServletException("Report: " + e.toString(), e);
		} catch (Exception e) {
			throw new ServletException("Report: " + e.toString(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				if (rs2 != null) rs2.getStatement().close();
				rs3 = null;
				if (rs3 != null) rs3.getStatement().close();
				rs3 = null;
			} catch (SQLException e) {
				throw new ServletException("Report Exception: " ,e);
			}
		}
		return baos;
	}
	
}
