package com.sinkluge.reports.payRequests;

/*
This file generates the form for subcontractors to submit a final payment request.
it's in the subcontracts section.
*/
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

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


public class GenFinalPayment extends Report {

	private ResultSet pr;	
	private BigString txt;
	private String fullName;
	
	public void doCleanup(Database db) {}
	
	public ReportContact getReportContact(String id, Database db) {
		String query = "select contact_id, company_id from contracts join pay_requests using(contract_id) "
			+ "where pr_id = " + id;
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
		return "select company_name, period, date_created, amount, pr.*, division, cost_code, phase_code, job_name, job_num "
		+ "from owner_pay_requests as opr join pay_requests as pr using (opr_id) join contracts "
		+ "using(contract_id) join job_cost_detail as jcd using(cost_code_id) join company using(company_id) "
		+ "join job on opr.job_id = job.job_id where pr.pr_id = " + id;
	}
	
	public static String getQuery2() {
		return "select txt from reports where id = 'prFinal'";
	}

	public GenFinalPayment(ResultSet pr, String txt, String fullName){
		this.pr = pr;
		type = Type.PR;
		this.txt = new BigString(txt);
		this.fullName = fullName;
	}//constructor

	public void create(Info in, Image logo) throws Exception {
		init();
		logo.scalePercent(20);

		String company_name = "Company Name";
		Date date_created = new Date();
		int request_num = 1;
		String cost_code = "0000-00000-0";
		String job_num = "0000";
		DecimalFormat df = new DecimalFormat("0000");
		double amount = 0;
		String period_out = "*** ****";
		String inv_num = "Invoice Number", job_name = "ERROR";
		float co = 0;
		float ret = 0;
		float ptd = 0;

		SimpleDateFormat sdf = new SimpleDateFormat("MMM yyyy");
		if (pr.next()) {
			id = pr.getString("pr_id");
			company_name = pr.getString("company_name");
			date_created = pr.getDate("date_created");
			request_num = pr.getInt("request_num");
			job_num = pr.getString("job_num");
			job_name = pr.getString("job_name");
			cost_code = job_num + "-" + pr.getString("division") + "-" + pr.getString("cost_code") + "-" + pr.getString("phase_code");
			amount = pr.getDouble("amount");
			period_out = pr.getString("period");
			co = pr.getFloat("co");
			ptd = pr.getFloat("adj_previous_billings");
			ret = pr.getFloat("adj_retention");
			inv_num = pr.getString("invoice_num");
			
		}

		Phrase p = new Phrase("Pay Request: " + company_name + ", " + period_out + "  Page:  ", DocHelper.font(8, Font.BOLD));
		HeaderFooter footer = new HeaderFooter(p, true);
		footer.setAlignment(Element.ALIGN_CENTER);
		footer.setBorder(Rectangle.NO_BORDER);
		document.setFooter(footer);

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
		int[] w4 = {20,48,12,20};
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
		t.addCell(c);

		p = new Phrase ("Date:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		sdf.applyPattern("d MMM yyyy");

		String dc = null;
		try {
			dc = sdf.format(date_created);
		} catch (NullPointerException e) { dc = ""; }

		p = new Phrase(dc, DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase ("Request #:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase(Integer.toString(request_num), DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		t.addCell(c);

		t.addCell(space);
		t.addCell(space);

		p = new Phrase ("Billing Period:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		c.setBorder(0);
		DocHelper.right(c);
		t.addCell(c);

		p = new Phrase("Final Pay Request", DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase ("Contract:", DocHelper.font(12, Font.BOLD));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);

		p = new Phrase(cost_code, DocHelper.font(12));
		c = new PdfPCell(p);
		c.setBorder(0);
		t.addCell(c);

		//t.complete();
		document.add(t);

		int[] w3 = {60,4,34,2};



		df.applyPattern("$#,##0.00");

		document.add(s);

		t = new PdfPTable(4);
		t.setWidths(w3);
		t.setWidthPercentage(70);
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

		p = new Phrase(inv_num, DocHelper.font(12));
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

		p = new Phrase(df.format(co)	, DocHelper.font(12));
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

		p = new Phrase(df.format(amount + (double) co)	, DocHelper.font(12));
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

		p = new Phrase(df.format(ptd)	, DocHelper.font(12));
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

		p = new Phrase(df.format(amount+(double)(co-ptd)), DocHelper.font(12));
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

		p = new Phrase(df.format(ret)	, DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(0);
		t.addCell(c);
		t.addCell(space);

		p = new Phrase("Final Amount Due", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.LEFT | Rectangle.BOTTOM);
		c.setUseDescender(true);
		t.addCell(c);

		p = new Phrase("=", DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.BOTTOM);
		t.addCell(c);

		p = new Phrase(df.format(amount+(double)(co-ptd-ret)), DocHelper.font(12));
		c = new PdfPCell(p);
		DocHelper.right(c);
		c.setBorder(Rectangle.BOTTOM);
		t.addCell(c);

		space.setBorder(Rectangle.BOTTOM | Rectangle.RIGHT);
		t.addCell(space);

		//t.addCell(space);

		//t.complete();
		t.setKeepTogether(true);
		//if (!writer.fitsPage(t)) document.newPage();

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

		txt.replaceAll("%c", fullName);
		txt.replaceAll("%s", company_name);
		txt.replaceAll("%n", job_name);

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
		//if (!writer.fitsPage(t)) document.newPage();

		document.add(t);

	}

}