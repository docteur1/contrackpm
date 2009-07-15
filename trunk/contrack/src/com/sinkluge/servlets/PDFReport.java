package com.sinkluge.servlets;

import org.apache.commons.io.output.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.PreparedStatement;
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
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.fax.Fax;
import com.sinkluge.reports.ErrorReport;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportUtils;
import com.sinkluge.reports.documents.KFWImage;
import com.sinkluge.reports.changes.GenCA;
import com.sinkluge.reports.changes.GenCR;
import com.sinkluge.reports.changes.GenChangeAuthorizationSummary;
import com.sinkluge.reports.changes.GenChangeRequestSummary;
import com.sinkluge.reports.contacts.JobContacts;
import com.sinkluge.reports.contracts.GenCloseout;
import com.sinkluge.reports.contracts.GenContractChecklist;
import com.sinkluge.reports.contracts.GenLienWaiver;
import com.sinkluge.reports.contracts.GenSubJobsiteSummary;
import com.sinkluge.reports.contracts.GenSubSubmittal;
import com.sinkluge.reports.contracts.GenSubcontract;
import com.sinkluge.reports.contracts.GenSubcontractAllDocs;
import com.sinkluge.reports.contracts.GenSubcontractWorksheet;
import com.sinkluge.reports.contracts.GenWarranty;
import com.sinkluge.reports.costCodes.GenCostCodesReport;
import com.sinkluge.reports.documents.AccImage;
import com.sinkluge.reports.payRequests.GenFinalPayment;
import com.sinkluge.reports.payRequests.GenFinalPaymentBlank;
import com.sinkluge.reports.payRequests.GenMonthlyPayment;
import com.sinkluge.reports.payRequests.GenMonthlyPaymentBlank;
import com.sinkluge.reports.payRequests.GenPRReport;
import com.sinkluge.reports.payRequests.GenPRRetReport;
import com.sinkluge.reports.rfi.GenRFIDocument;
import com.sinkluge.reports.submittals.GenSubmittalSummary;
import com.sinkluge.reports.submittals.GenSubmittalToArch;
import com.sinkluge.reports.submittals.GenSubmittalToSub;
import com.sinkluge.reports.transmittals.GenTransmittal;
import com.sinkluge.security.Name;
import com.sinkluge.security.Permission;
import com.sinkluge.security.Security;
import com.sinkluge.utilities.DocMailer;
import com.sinkluge.utilities.ItemLogger;

public class PDFReport extends HttpServlet {

	private static Logger log = Logger.getLogger(PDFReport.class);
	
	private static final long serialVersionUID = -5109640726679253133L;

	public String getServletName() {
		return "PFDReportServlet";
	}

	public void service(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession(true);
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		Info in = (Info) session.getServletContext().getAttribute("in");
		String path = request.getPathInfo();
		boolean fax = path.indexOf("fax") != -1;
		boolean email = path.indexOf("email") != -1;
		String id = request.getParameter("id");
		PreparedStatement ps = null;
		ResultSet rs = null;
		if (fax || email) {
			path = request.getParameter("doc");
			id = path.substring(path.indexOf("id=") + 3);
		}
		log.debug("generating report: " + path + " id " + id);
		Report r = getGeneratedReport(request, path, id, attr, in);
		try {
			ByteArrayOutputStream baos = r.getStream();
			if (baos != null) {
				if (!fax && !email) {
					response.setContentLength(baos.size());
					response.setHeader("Cache-Control", "private");
					response.setHeader("Pragma", "expires"); 
					response.setContentType("application/pdf");
					ServletOutputStream out = response.getOutputStream();
					baos.writeTo(out);
					if (r.type != null && id != null) {
						ItemLogger.Printed.update(r.type, id, session);
					}
					out.flush();
					out.close();
				} else if (fax) {
					response.setContentType("text/html");
					String jobId = Fax.sendPDF(Fax.getFax(request.getParameter("fax")), 
						baos.toByteArray(), in);
					Fax.logFax(jobId, request.getParameter("fax"), path.substring(0, path.indexOf("."))
							, request.getParameter("contact"), request.getParameter("company")
							, request.getParameter("description"), session);
					if (r.type != null && id != null) {
						ItemLogger.Faxed.update(r.type, id, "Sent to " 
							+ request.getParameter("fax"), session);
					}
					PrintWriter pw = response.getWriter();
					pw.println("<html>");
					pw.println("<script>window.alert('Fax Queued\\n----------------\\nFax Job Id: " + jobId + "');");
					pw.println("window.location='../../utils/print.jsp?doc=" + path 
						+ "&add=" + request.getParameter("add") + "';");
					pw.println("</script></html>");
					pw.flush();
					pw.close();
					db.disconnect();
				} else {
					// TODO add error checking
					String file = path.indexOf("?") != -1 ? path.substring(0, path.indexOf("?")) : path;
					DocMailer dm = new DocMailer(attr.getEmail(), attr.getFullName(), 
						request.getParameter("address"), request.getParameter("subject"), 
						request.getParameter("body"), in);
					dm.addFile(file, "Document", "application/pdf", baos.toByteArray());
					rs = db.dbQuery("select * from files where type = '" + r.type.getCode()
						+ "' and " + "id = '" + id + "' and email = 1");
					InputStream is;
					while (rs.next()) {
						is = FileServlet.getFileAsInputStream(rs);
						dm.addFile(rs.getString("filename"), rs.getString("description"),
							rs.getString("content_type"), is);
						is.close();
					}
					dm.send();
					if (r.type != null && id != null) {
						ItemLogger.Emailed.update(r.type, id, "Sent to " 
							+ request.getParameter("address"), session);
					}
					response.sendRedirect("../../utils/print.jsp?doc=" + path + "&add=" + request.getParameter("add"));
				}
			} else {
				response.setContentType("text/html");
				ServletOutputStream out = response.getOutputStream();
				out.print("<html><head><link rel=\"stylesheet\" href=\"../../stylesheets/v2.css\" type=\"text/css\" />");
				out.print(com.sinkluge.utilities.Widgets.fontSizeStyle(attr)); 
				out.print("</head><body><div class=\"title\">Error - No Document Returned</div><hr>");
				out.print("Please try your request again or contact an administrator.</body></html>");
				out.flush();
				out.close();
			}
		} catch (IOException e) {
			throw new ServletException("Report: " + e.toString(), e);
		} catch (SQLException e) {
			throw new ServletException("Report: " + e.toString(), e);
		} catch (Exception e) {
			throw new ServletException("Report: " + e.toString(), e);
		} finally {
			r = null;
			try {
				if (ps != null) ps.close();
				if (rs != null) rs.close();
				db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("Report Exception: " ,e);
			}
		}
	}
	
	public static Report getGeneratedReport(HttpServletRequest request, String path, String id,
			Attributes attr, Info in) throws ServletException {
		return getGeneratedReport(request, path, id, attr, in, true);
	}
	
	public static Report getGeneratedReport(HttpServletRequest request, String path, String id,
			Attributes attr, Info in, boolean stamp) throws ServletException {
		ResultSet rs = null;
		Report rep;
		Database db = new Database();
		try {
			rs = db.dbQuery("select logo from sites where site_id = " + attr.getSiteId());
			Image logo = null;
			if (rs.first()) logo = Image.getInstance(rs.getBytes(1));
			if (rs != null) rs.getStatement().close();
			rs = null;
			byte[] pdfKey = in.pdf_key.getBytes();
			rep = getReport(request, path, id, pdfKey, db, attr, in);
			rep.create(in, logo);
			rep.doCleanup(db);
			ReportUtils.addAttachments(rep, db, pdfKey, request.getParameter("encrypt") != null, stamp, request.getSession());
		} catch (SQLException e) {
			throw new ServletException("Report: " + e.getMessage(), e);
		} catch (Exception e) {
			throw new ServletException("Report: " + e.getMessage(), e);
		} finally {
			try {
				if (rs != null && rs.getStatement() != null) rs.getStatement().close();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {
				throw new ServletException("Report Exception: " ,e);
			}
		}
		return rep;
	}
	
	public static Report getReport(HttpServletRequest request, String path, String id, 
			byte[] pdfKey, Database db, Attributes attr, Info in) throws ServletException {
		ResultSet rs = null;
		ResultSet rs2 = null;
		ResultSet rs3 = null;
		Report rep;
		String add = request.getParameter("add");
		try {
			if (path.indexOf("jobContacts") != -1) {
				rs = db.dbQuery(JobContacts.getQuery(attr.getJobId()));
				rep = new JobContacts(rs, attr.getJobName(), Integer.toString(attr.getJobId()));
			} else if (path.indexOf("completeSummary") != -1) {
				rs = db.dbQuery(GenCostCodesReport.getQuery(attr.getJobId()));
				rs2 = db.dbQuery(GenCostCodesReport.getQuery2(attr.getJobId()));
				rs3 = db.dbQuery(GenCostCodesReport.getQuery3(attr.getJobId()));
				double contractStartAmount = 0, ownerCo = 0, intCo = 0;
				if (rs3.first()) contractStartAmount = rs3.getFloat("contract_amount_start");
				if (rs3 != null) rs3.getStatement().close();
				rs3 = db.dbQuery(GenCostCodesReport.getQuery4(attr.getJobId()));
				if (rs3.first()) ownerCo = rs3.getFloat("amount");
				if (rs3 != null) rs3.getStatement().close();
				rs3 = db.dbQuery(GenCostCodesReport.getQuery5(attr.getJobId()));
				log.debug(GenCostCodesReport.getQuery5(attr.getJobId()));
				if (rs3.first()) intCo = rs3.getFloat("amount");
				if (rs3 != null) rs3.getStatement().close();
				rep = new GenCostCodesReport(rs, rs2, GenCostCodesReport.getPhases(db), attr.getJobName(), 
					contractStartAmount, ownerCo, intCo, attr.getJobId());
			/*
			 * Subcontracts
			 */
			} else if (path.indexOf("sub") != -1) {
				if (path.indexOf("Warranty") != -1) {
					rs = db.dbQuery(GenWarranty.getQuery(id));
					rs2 = db.dbQuery(GenWarranty.getQuery2(id));
					rs2.first();
					rep = new GenWarranty(rs, rs2.getString(1), attr.getJobName());
				} else if (path.indexOf("Closeout") != -1) {
					rs = db.dbQuery(GenCloseout.getQuery(id));
					rs2 = db.dbQuery(GenCloseout.getQuery2(id));
					rs2.first();
					rep = new GenCloseout(rs, rs2.getString(1));
				} else if (path.indexOf("Checklist") != -1) {
					rs = db.dbQuery(GenContractChecklist.getQuery(id));
					rs.first();
					rs2 = db.dbQuery(GenContractChecklist.getQuery2(id));
					rs2.first();
					rep = new GenContractChecklist(rs.getString(1), attr.getJobName(), add, 
						rs2.getString("contract_title"), rs2.getString("contractee_title"), 
						rs2.getBoolean("site_work"), attr.get("short_name"), 
						rs2.getString("contract_id"));
				} else if (path.indexOf("Submittals") != -1) rep = new GenSubSubmittal(id, db, attr); 
				else if (path.indexOf("JobSummary") != -1) rep = new GenSubJobsiteSummary(id, db, attr.get("short_name"), attr.get("full_name"));
				else if (path.indexOf("Worksheet") != -1) rep = new GenSubcontractWorksheet(id, db, 
					attr.get("short_name")); 
				else if (path.indexOf("All") != -1) rep = new GenSubcontractAllDocs(id, add, db, attr);
				else if (path.indexOf("LienWaiver") != -1) rep = new GenLienWaiver(attr, db);
				else rep = new GenSubcontract(id, attr.getJobId(), db, attr); 
			/*
			 * Submittals
			 */
			} else if (path.indexOf("sbmt") != -1) {
				if (path.indexOf("Architect") != -1) rep = new GenSubmittalToArch(id, db, attr);
				else if (path.indexOf("Subcontractor") != -1) rep = new GenSubmittalToSub(id, db, attr);
				else {
					if (id != null)id = " costorder(division), costorder(cost_code), phase_code, costorder(submittal_num) desc";
					else id = " costorder(submittal_num) desc";
					rs = db.dbQuery(GenSubmittalSummary.getQuery(attr.getJobId(), id));
					rep = new GenSubmittalSummary(rs, attr.getJobName(), attr.get("short_name"));
				}
			/*
			 * Pay Requests
			 */
			} else if (path.indexOf("pr") != -1) {
				if (path.indexOf("Report") != -1) {
					if (path.indexOf("Retention") != -1) {
						rep = new GenPRRetReport(id, db);		
					} else { 
						rs = db.dbQuery(GenPRReport.getQuery(id));
						rs2 = db.dbQuery(GenPRReport.getQuery2(id));
						rep = new GenPRReport(rs, rs2);
					}
				} else if (path.indexOf("Blank") != -1) {
					if (path.indexOf("Month") != -1) {
						rs = db.dbQuery(GenMonthlyPaymentBlank.getQuery(id));
						rs2 = db.dbQuery(GenMonthlyPaymentBlank.getQuery2());
						rs2.first();
						rep = new GenMonthlyPaymentBlank(rs, rs2.getString(1), attr.get("full_name"));
					} else {
						rs = db.dbQuery(GenFinalPaymentBlank.getQuery(id));
						rs2 = db.dbQuery(GenFinalPaymentBlank.getQuery2());
						rs2.first();
						rep = new GenFinalPaymentBlank(rs, rs2.getString(1), attr.get("full_name"));
					}
				} else {
					if (path.indexOf("Month") != -1) {
						rs = db.dbQuery(GenMonthlyPayment.getQuery(id));
						rs2 = db.dbQuery(GenMonthlyPayment.getQuery2());
						rs2.first();
						rep = new GenMonthlyPayment(rs, rs2.getString(1), attr.get("full_name"));
					} else {
						rs = db.dbQuery(GenFinalPayment.getQuery(id));
						rs2 = db.dbQuery(GenFinalPayment.getQuery2());
						rs2.first();
						rep = new GenFinalPayment(rs, rs2.getString(1), attr.get("full_name"));
					}
				}
			} else if (path.indexOf("rfi") != -1) {
				rs = db.dbQuery(GenRFIDocument.getQuery(id));
				if (!rs.isBeforeFirst()) {
					rs.getStatement().close();
					rs = db.dbQuery(GenRFIDocument.getQuery2(id));
				}
				rep = new GenRFIDocument(rs, attr.getJobName());
			} else if (path.indexOf("Transmittal") != -1) {
				rs = db.dbQuery(GenTransmittal.getQuery(id));
				rep = new GenTransmittal(rs, attr.getJobName());
			/*
			 *  KlickFileReports?
			 */
			} else if (path.indexOf("image") != -1) {
				Security sec = (Security) request.getSession().getAttribute("sec");
				boolean acc = false;
				if (sec != null) acc = sec.ok(Name.ACCOUNTING, Permission.READ);
				if (path.indexOf("KFW") != -1) {
					if (path.indexOf("Acc") != -1) rep = new KFWImage(id, acc, request.getSession());
					else rep = new KFWImage(id, request.getSession());
				} else rep = new AccImage(id, request.getSession());				
				// Stamp with add
				if (rep != null) ReportUtils.stamp(rep, pdfKey, true, add);
				else throw new ServletException("KFW Image: Not Found! (Check KFWS server logs)");
			} else if (path.indexOf("change") != -1) {
				if (path.indexOf("RequestSummary") != -1)
					rep = new GenChangeRequestSummary(db, attr.getJobId(), id);
				else if (path.indexOf("AuthorizationSummary") != -1) {
					log.debug("ID " + id + " and is null " + (id == null));
					rep = new GenChangeAuthorizationSummary(id, db, attr.getJobId());
				} else if (path.indexOf("CR") != -1) rep = new GenCR(db, id, attr.get("short_name"));
				else rep = new GenCA(db, id, attr.get("short_name"), attr.getFullName());
			} else rep = new ErrorReport();
		} catch (IOException e) {
			throw new ServletException("Report: " + e.getMessage(), e);
		} catch (SQLException e) {
			throw new ServletException("Report: " + e.getMessage(), e);
		} catch (Exception e) {
			throw new ServletException("Report: " + e.getMessage(), e);
		}
		return rep;
	}
	
}
