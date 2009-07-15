package com.sinkluge.reports;

import javax.servlet.http.HttpServletRequest;

import com.sinkluge.Info;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.servlets.PDFReport;

public class ReportContact {

	private int contactId = 0;
	private int companyId = 0;
	
	public int getCompanyId() {
		return companyId;
	}
	public void setCompanyId(int companyId) {
		this.companyId = companyId;
	}
	public int getContactId() {
		return contactId;
	}
	public void setContactId(int contactId) {
		this.contactId = contactId;
	}
	
	public static ReportContact getReportContact(String path, String id,
			HttpServletRequest request) throws Exception {
		Database db = new Database();
		Attributes attr = (Attributes) request.getSession().getAttribute("attr");
		Info in = (Info) request.getSession().getServletContext().getAttribute("in");
		Report r = PDFReport.getReport(request, path, id, null, db, attr, in);
		ReportContact rp = r.getReportContact(id, db);
		db.disconnect();
		return rp;
	}
}
