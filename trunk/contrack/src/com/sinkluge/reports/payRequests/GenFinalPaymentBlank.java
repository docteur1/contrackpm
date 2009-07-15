package com.sinkluge.reports.payRequests;

/*
This file generates the form for subcontractors to submit a final payment request.
it's in the subcontracts section.
*/
import java.sql.ResultSet;
import java.text.DecimalFormat;

import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;
import com.sinkluge.utilities.BigString;

public class GenFinalPaymentBlank extends Report {

	private ResultSet pr;
	private BigString txt;
	private String fullName;

	public void doCleanup(Database db) {}

	public ReportContact getReportContact(String id, Database db) {
		String query = "select contact_id, company_id from contracts "
			+ "where contract_id = " + id;
		ResultSet rs = null;
		ReportContact rp = new ReportContact();
		try {
			rs = db.dbQuery(query);
			if (rs.next()) {
				if (rs.getInt(1) != 0) {
					rp.setContactId(rs.getInt(1));
					rp.setCompanyId(rs.getInt(2));
				} else rp.setCompanyId(rs.getInt(2)); 
			}
		} catch (Exception e) {
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
			} catch (Exception e) {}
		}
		return rp;
	}
	
	public static String getQuery(String id) {
		return "select job_num, contract_id, job_name, company_name, division, cost_code, phase_code, amount from job join "
			+ "contracts using(job_id) join job_cost_detail using(cost_code_id) join company using(company_id) "
			+ "where contract_id = " + id;
	}
	
	public static String getQuery2() {
		return "select txt from reports where id = 'prFinal'";
	}
	
	public GenFinalPaymentBlank(ResultSet pr, String txt, String fullName){
		this.pr = pr;
		this.fullName = fullName;
		this.txt = new BigString(txt);
		type = Type.SUBCONTRACT;
	}//constructor

	public void create(Info in, Image logo) throws Exception {
		init();
		logo.scalePercent(20);

		String job_name = "Project Name";
		String company_name = "Company Name";
		String cost_code = "0000-00000-0";
		String job_num = "0000";
		DecimalFormat df = new DecimalFormat("0000");
		double amount = 0;

		if (pr.next()) {
			id = pr.getString("contract_id");
			job_name = pr.getString("job_name");
			company_name = pr.getString("company_name");
			job_num = pr.getString("job_num");
			txt.setContractorName(fullName);
			txt.setProjectName(job_name);
			txt.setSubcontractorName(company_name);
			cost_code = job_num + "-" + pr.getString("division") + "-" + pr.getString("cost_code") + "-" + pr.getString("phase_code");
			amount = pr.getDouble("amount");
		}

		Phrase p = new Phrase("Pay Request: " + company_name + ",   Page:  ", DocHelper.font(8, Font.BOLD));
		HeaderFooter footer = new HeaderFooter(p, true);
		footer.setAlignment(Element.ALIGN_CENTER);
		footer.setBorder(Rectangle.NO_BORDER);
		document.setFooter(footer);
		document.open();

		PdfPCell space = new PdfPCell();
		space.setFixedHeight(10f);
		space.setBorder(0);

		PdfPTable s = new PdfPTable(1);
		//s.setBorder(0);
		//s.setDefaultPdfPCellBorder(0);
		s.addCell(space);

		PdfPTable t = new PdfPTable(2);
		//t.setBorder(0);
		//t.setDefaultPdfPCellBorder(0);
		t.setWidthPercentage(100);

		PdfPCell c = new PdfPCell(logo);
		DocHelper.top(c);
		c.setPaddingBottom(4);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("\n" + job_name, DocHelper.font(16));
		c = new PdfPCell(p);
		DocHelper.middle(c);
		DocHelper.center(c);
		c.setBorder(0);
		t.addCell(c);

		//t.complete();
		document.add(t);

		t = new PdfPTable(4);
		int[] w4 = {18,32,18,32};
		//t.setPadding(2);
		//t.setSpacing(2);
		t.setWidths(w4);
		t.setWidthPercentage(100);
		//t.setBorder(0);
		//t.setDefaultPdfPCellBorder(0);

		p = new Phrase ("FINAL REQUEST FOR PAYMENT", DocHelper.font(16, Font.BOLD));
		c = new PdfPCell(p);
		c.setUseDescender(true);
		DocHelper.center(c);
		DocHelper.middle(c);
		DocHelper.gray(c);
		c.setColspan(4);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase ("Subcontractor:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase (company_name, DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		c.setColspan(3);
		t.addCell(c);

		p = new Phrase ("Request #:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase("_________________________", DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		c.setFixedHeight(22f);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase ("Date:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase("_________________________", DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		c.setFixedHeight(22f);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase ("Billing Period:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		c.setBorder(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase("Final Pay Request", DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		c.setFixedHeight(22f);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase ("Contract:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		DocHelper.bottom(c);
		t.addCell(c);

		p = new Phrase(cost_code, DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		DocHelper.bottom(c);
		t.addCell(c);

		//t.complete();
		document.add(t);

		int[] w3 = {60,4,34,2};

		df.applyPattern("$#,##0.00");

		document.add(s);

		t = new PdfPTable(4);
		t.setWidths(w3);
		t.setWidthPercentage(70);
		t.setSpacingBefore(12);
		//t.setBorder(Rectangle.BOX);
		//t.setDefaultPdfPCellBorder(0);
		//t.setPdfPTableFitsPage(true);

		p = new Phrase("   Final Pay Request", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		c.setBorder(Rectangle.LEFT | Rectangle.RIGHT | Rectangle.TOP);
		c.setColspan(4);
		t.addCell(c);

		p = new Phrase("Invoice Number:", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		c.setColspan(2);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		space.setBorder(Rectangle.RIGHT);
		t.addCell(space);

		p = new Phrase("Original Contract Amount", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		space.setBorder(0);
		t.addCell(space);
		space.setBorder(Rectangle.RIGHT);

		p = new Phrase(df.format(amount)	, DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);
		t.addCell(space);

		p = new Phrase("Approved Change Orders", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		p = new Phrase("+", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		t.addCell(space);

		p = new Phrase("Final Contract Amount", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		p = new Phrase("=", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		t.addCell(space);

		p = new Phrase("Less Previous Gross Billings", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		p = new Phrase("-", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);
		t.addCell(space);

		p = new Phrase("SUBTOTAL (Final Billing)", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		p = new Phrase("=", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		t.addCell(space);

		p = new Phrase("Total Retention", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		t.addCell(c);

		p = new Phrase("-", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);
		t.addCell(space);

		p = new Phrase("Final Amount Due", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT);
		c.setUseDescender(true);
		t.addCell(c);

		p = new Phrase("=", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase("____________________", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		t.addCell(space);

		space.setBorder(Rectangle.BOX & ~Rectangle.TOP);

		space.setColspan(4);

		t.addCell(space);

		space.setColspan(1);

		space.setBorder(Rectangle.RIGHT);

		//t.addCell(space);

		//t.complete();
		t.setKeepTogether(true);

		document.add(t);

		document.add(s);

		t = new PdfPTable(3);
		int[] wt = {27, 46, 27};
		t.setWidths(wt);
		t.setWidthPercentage(100);
		t.setSpacingBefore(6f);
		//t.setPadding(2);
		//t.setSpacing(2);
		//t.setBorder(Rectangle.NO_BORDER);
		//t.setDefaultPdfPCellBorder(0);
		//t.setPdfPTableFitsPage(true);

		p = new Phrase(txt.toString(), DocHelper.font(10));
		c = new PdfPCell(p);
		c.setColspan(3);
		DocHelper.bTop(c);
		t.addCell(c);

		space.setBorder(0);

		space.setColspan(3);
		t.addCell(space);
		space.setColspan(1);

		t.addCell(space);

		p = new Phrase(company_name, DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.center(c);
		DocHelper.bBottom(c);
		t.addCell(c);

		t.addCell(space);
		t.addCell(space);

		p = new Phrase("Subcontractor", DocHelper.font(8, Font.ITALIC));
		c = new PdfPCell(p);
		c.setBorder(0);
		DocHelper.center(c);
		t.addCell(c);

		t.addCell(space);
		t.addCell(space);

		p = new Phrase("");
		c = new PdfPCell(p);
		c.setFixedHeight(35f);
		DocHelper.bBottom(c);
		t.addCell(c);

		t.addCell(space);
		t.addCell(space);

		p = new Phrase("Print Name of Authorized Company Officer", DocHelper.font(8, Font.ITALIC));
		c = new PdfPCell(p);
		c.setBorder(0);
		DocHelper.center(c);
		t.addCell(c);

		t.addCell(space);
		t.addCell(space);

		p = new Phrase("");
		c = new PdfPCell(p);
		c.setFixedHeight(35f);
		DocHelper.bBottom(c);
		t.addCell(c);

		t.addCell(space);
		t.addCell(space);

		p = new Phrase("Authorized Signature", DocHelper.font(8, Font.ITALIC));
		c = new PdfPCell(p);
		DocHelper.center(c);
		c.setBorder(0);
		t.addCell(c);

		t.addCell(space);

		//t.complete();
		t.setKeepTogether(true);

		document.add(t);

	}
}