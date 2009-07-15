package com.sinkluge.reports.payRequests;

/*
This file generates the form for subcontractors to submit a final payment request.
it's in the subcontracts section.
*/
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lowagie.text.Cell;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;


public class GenPRReport extends Report {

	private ResultSet opr, rs;

	public void doCleanup(Database db) {}
	
	public GenPRReport(ResultSet opr, ResultSet rs){
		this.opr = opr;
		this.rs = rs;
		type = Type.OPR;
	}//constructor
	
	public static String getQuery(String id) {
		return "select opr_id, period, job_name from job join owner_pay_requests as opr using(job_id) where "
		+ "opr_id = " + id;
	}
	
	public static String getQuery2(String id) {
		return "select division, cost_code, phase_code, company_name, pr.*, amount from job_cost_detail as jcd join "
			+ "contracts using(cost_code_id) join pay_requests as pr using(contract_id) join "
			+ "owner_pay_requests using(opr_id) join company using(company_id) where opr_id = " + id
			+ " order by costorder(division), costorder(cost_code), phase_code";
	}

	public void create(Info in, Image logo) throws Exception {
		
		init(PageSize._11X17.rotate());

		String job_name = "ERROR";
		SimpleDateFormat sdf = new SimpleDateFormat("MMM yyyy");
		String period_out = "ERROR";

		if (opr.next()) {
			id = opr.getString("opr_id");
			job_name = opr.getString("job_name");
			period_out = opr.getString("period");
		}


		Phrase p = new Phrase(period_out + " Pay Requests: " + job_name + "     Page: ", DocHelper.font(12));
		HeaderFooter header = new HeaderFooter(p, true);
		header.setAlignment(Element.ALIGN_CENTER);
		header.setBorder(Rectangle.NO_BORDER);
		//header.setBorderWidth(2);
		document.setHeader(header);

		document.open();

		int[] widths = {9,17,8,8,8,8,8,8,8,8,8,5,5,5};
		Table t = new Table(14);
		t.setWidth(100);
		t.setWidths(widths);
		t.setBorderWidth(1);
		t.setPadding(3);
		t.setCellsFitPage(true);
		//t.setDefaultCellBorder(Rectangle.BOX);
		//t.setDefaultCellBorderWidth(1);

		Cell c = new Cell(new Phrase("\nPhase", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nCompany Name", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nContract", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("CAs", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("Adjusted Contract", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("Value of Work", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("Paid to Date", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nSubtotal", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nRetention", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nDue", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nAccepted", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nInv #", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.bottom(c);
		t.addCell(c);
		
		c = new Cell(new Phrase("\nVoucher #", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nRef #", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.bottom(c);
		t.addCell(c);
		
		t.endHeaders();

		String code;
		String company_name;
		double contract;
		float co, vwctd, ptd, ret;
		Date approved;
		String ref_num, invoice_num, account_id;
		boolean fp;

		sdf.applyPattern("d MMM yyyy");
		DecimalFormat df = new DecimalFormat("$#,##0.00");

		while (rs.next()) {
			code = rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code");
			company_name = rs.getString("company_name");
			contract = rs.getDouble("amount");
			co = rs.getFloat("co");
			vwctd = rs.getFloat("adj_value_of_work");
			ptd = rs.getFloat("adj_previous_billings");
			ret = rs.getFloat("adj_retention");
			approved = rs.getDate("date_approved");
			ref_num = rs.getString("ref_num");
			fp = rs.getBoolean("final");
			if (fp) vwctd = (float)contract + co;
			if (ref_num == null || ref_num.equals("0")) ref_num = "";
			account_id = rs.getString("account_id");
			if (account_id == null || account_id.equals("0")) account_id = "";
			invoice_num = rs.getString("invoice_num");
			if (invoice_num == null || invoice_num.equals("0")) invoice_num = "";

			p = new Phrase(code, DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(company_name, DocHelper.font(8));
			c = new Cell(p);
			t.addCell(c);

			p = new Phrase(df.format(contract), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(co), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(contract + (double) co), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(fp ? "FINAL" : df.format(vwctd), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(ptd), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(vwctd-ptd), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(ret), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(vwctd-ptd-ret), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			try {
				p = new Phrase(sdf.format(approved), DocHelper.font(8));
			} catch (NullPointerException e) {
				p = new Phrase("***", DocHelper.font(8));
			}
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(invoice_num, DocHelper.font(8));
			c = new Cell(p);
			t.addCell(c);
			
			p = new Phrase(account_id, DocHelper.font(8));
			c = new Cell(p);
			t.addCell(c);
			
			p = new Phrase(ref_num, DocHelper.font(8));
			c = new Cell(p);
			t.addCell(c);

		}

		t.complete();

		document.add(t);

	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}

}