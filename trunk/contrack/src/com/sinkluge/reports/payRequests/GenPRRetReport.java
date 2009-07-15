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


public class GenPRRetReport extends Report{

	private Database db;
	
	public void doCleanup(Database db) {}

	public GenPRRetReport(String opr_id, Database db){
		this.db = db;
		id = opr_id;
		type = Type.OPR;
	}//constructor

	public void create(Info in, Image logo) throws Exception {
		init(PageSize._11X17.rotate());
		
		String job_name = "ERROR";
		SimpleDateFormat sdf = new SimpleDateFormat("MMM yyyy");

		String query = "select job_name from owner_pay_requests as opr join job using(job_id) " +
				"where opr_id = " + id;
		ResultSet rs = db.dbQuery(query);
		if (rs.next()) job_name = rs.getString("job_name");
		if (rs != null) rs.getStatement().close();

		Phrase p = new Phrase("Retention: " + job_name + "     Page: ", DocHelper.font(12));
		HeaderFooter header = new HeaderFooter(p, true);
		header.setAlignment(Element.ALIGN_CENTER);
		header.setBorder(Rectangle.NO_BORDER);
		//header.setBorderWidth(2);
		document.setHeader(header);

		document.open();

		int[] widths = {10,34,8,8,8,8,8,8,8,13};
		Table t = new Table(10);
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

		c = new Cell(new Phrase("Final Contract", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);


		c = new Cell(new Phrase("Paid to Date", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nRetention", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
		DocHelper.bottom(c);
		t.addCell(c);

		c = new Cell(new Phrase("\nAccepted", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		DocHelper.right(c);
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

		String company_name;
		String contractId;
		String costCode;
		String phaseCode;
		String division;
		double contract;
		float co, ptd, ret;
		Date approved;
		String ref_num, invoice_num, account_id;
		ResultSet rs2;

		sdf.applyPattern("d MMM yyyy");
		DecimalFormat df = new DecimalFormat("$#,##0.00");
		
		query = "select account_id, invoice_num, division, cost_code, phase_code, contracts.contract_id, amount, company_name, " +
				"date_approved, ref_num from job_cost_detail as jcd join contracts using(cost_code_id) " +
				"join pay_requests as pr using(contract_id) join company using(company_id) where " +
				"opr_id = " + id + " order by costorder(division), costorder(cost_code), phase_code";
		rs = db.dbQuery(query);

		while (rs.next()) {
			division = rs.getString("division");
			costCode = rs.getString("cost_code");
			phaseCode = rs.getString("phase_code");
			contractId = rs.getString("contract_id");
			contract = rs.getDouble("amount");
			company_name = rs.getString("company_name");
			approved = rs.getDate("date_approved");
			ref_num = rs.getString("ref_num");
			if (ref_num == null || ref_num.equals("0")) ref_num = "";
			account_id = rs.getString("account_id");
			if (account_id == null || account_id.equals("0")) account_id = "";
			invoice_num = rs.getString("invoice_num");
			if (invoice_num == null || invoice_num.equals("0")) invoice_num = "";
	
			p = new Phrase(division + " " + costCode + "-" + phaseCode, DocHelper.font(8));
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
			
			co = 0;
			query = "select sum(amount) as co from change_request_detail where" +
				" authorization = 1 and contract_id = " + contractId;
			rs2 = db.dbQuery(query);
			if (rs2.next()) co = rs2.getFloat(1); 
			if (rs2 != null) rs2.getStatement().close();
			
			p = new Phrase(df.format(co), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			p = new Phrase(df.format(contract + (double) co), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			query = "select sum(paid) as ptd from pay_requests as pr join owner_pay_requests as opr "
				+ "using(opr_id) where period != 'Retention' and contract_id = " + contractId;
			rs2 = db.dbQuery(query);
			ptd = 0;
			if (rs2.next()) ptd = rs2.getFloat(1);
			if (rs2 != null) rs2.close();
			
			p = new Phrase(df.format(ptd), DocHelper.font(8));
			c = new Cell(p);
			DocHelper.right(c);
			t.addCell(c);

			query = "select sum(adj_retention) as ptd from pay_requests as pr join owner_pay_requests "
				+ "as opr using(opr_id) where contract_id = " + contractId;
			rs2 = db.dbQuery(query);
			ret = 0;
			if (rs2.next()) ret = rs2.getFloat(1);
			if (rs2 != null) rs2.close();
			rs2 = null;	
			
			p = new Phrase(df.format(ret), DocHelper.font(8));
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
			
			p = new Phrase(account_id, DocHelper.font(8));
			c = new Cell(p);
			t.addCell(c);

			p = new Phrase(ref_num, DocHelper.font(8));
			c = new Cell(p);
			t.addCell(c);

		}
		if (rs != null) rs.getStatement().close();
		rs = null;

		t.complete();

		document.add(t);

	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}
}