package com.sinkluge.reports.contacts;

import java.sql.ResultSet;
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

public class JobContacts extends Report {

	private ResultSet rs;
	private String job_name;

	public JobContacts (ResultSet rs, String job_name, String id) {
		this.rs = rs;
		this.job_name = job_name;
		this.id = id;
		type = Type.PROJECT;
	}
	public void doCleanup(Database db) throws Exception {}
	
	public void create(Info in, Image logo) throws Exception {
		

		SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");

		Phrase p = new Phrase(job_name + " Contacts        " + sdf.format(new Date()) + "          Page: ", DocHelper.font(14, Font.BOLD));
		HeaderFooter header = new HeaderFooter(p, true);
		header.setAlignment(Element.ALIGN_CENTER);
		header.setBorder(Rectangle.NO_BORDER);
		//header.setBorderWidth(2);
		init(PageSize._11X17.rotate(), 36, 45, 36, 36, null, header);

		int[] widths = {22, 24, 12, 12, 10, 10, 10};
		Table t = new Table(7);
		t.setWidth(100);
		t.setWidths(widths);
		t.setBorderWidth(0);
		t.setPadding(1);
		//t.setSpacing(2);
		t.setCellsFitPage(true);
		//t.setDefaultCellBorder(Rectangle.TOP);
		//t.setDefaultCellBorderWidth(1);

		Cell c = new Cell(new Phrase("Trade", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		c = new Cell(new Phrase("Company Name", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		c = new Cell(new Phrase("City", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		c = new Cell(new Phrase("Contact", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		c = new Cell(new Phrase("Office Phone", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		c = new Cell(new Phrase("Fax", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		c = new Cell(new Phrase("Mobile", DocHelper.font(10, Font.BOLD)));
		c.setBorderWidth(0);
		t.addCell(c);

		t.endHeaders();

		Cell blank = new Cell(new Phrase("", DocHelper.font(10)));
		blank.setColspan(2);

		String temp = "", name;
		int id = 0, old_id = 0;
		long cc_id = 0, old_cc_id = 0;

		while (rs.next()) {
			id = rs.getInt("company_id");
			cc_id = rs.getLong("cost_code_id");
			if (id != old_id || cc_id != old_cc_id) {
				temp = rs.getString("code_description");
				if (temp == null || temp.equals("")) temp = rs.getString("type");
				if (temp == null || temp.equals("")) temp = "N/A";

				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);

				temp = rs.getString("company_name");
				if (temp == null || temp.equals("")) temp = "N/A";

				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
			} else t.addCell(blank);
			
			name = rs.getString("name");
			
			if (name != null) {

				temp = rs.getString("nc");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				c = new Cell(new Phrase(name, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				temp = rs.getString("np");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				temp = rs.getString("nf");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				temp = rs.getString("mobile_phone");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
			} else {
				temp = rs.getString("cc");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				c = new Cell(new Phrase("N/A", DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				temp = rs.getString("cp");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(2);
				t.addCell(c);
	
				temp = rs.getString("cf");
				if (temp == null || temp.equals("")) temp = "N/A";
	
				c = new Cell(new Phrase(temp, DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(1);
				t.addCell(c);
	
				c = new Cell(new Phrase("N/A", DocHelper.font(10)));
				//if (rs.isFirst()) c.setBorderWidth(1);
				t.addCell(c);
			}

			old_id = id;
			old_cc_id = cc_id;
		}

		t.complete();

		document.add(t);

	}
	
	public static String getQuery(int jobId) {
		String query = "(select null as cost_code_id, c.company_id,c.company_name, c.city as cc, n.city as nc, c.phone as cp, c.fax as cf, n.phone as np, n.fax as nf, n.name, n.email, n.mobile_phone,"
			+ "type, null as code_description from ((job_contacts left join "
			+ "contacts as n using(contact_id)) left join company as c on "
			+ "c.company_id = job_contacts.company_id) where job_id = " + jobId + ") ";
		query += "union (select distinct jcd.cost_code_id, c.company_id,c.company_name, c.city as cc, n.city as nc, c.phone as cp, c.fax as cf, n.phone as np, n.fax as nf, n.name, n.email, n.mobile_phone,"
			+ "null as type, code_description from (((contracts left join contacts as n using(contact_id)) left join company as c on "
			+ "contracts.company_id = c.company_id) left join job_cost_detail as jcd using (cost_code_id)) where contracts.job_id = " + jobId + ") order by company_name, type desc";
		return query;
	}

	public static void main(String[] args) {
		/*
		System.out.println("\nCreating PDF...\n\n");
		Database db = new Database();
		ResultSet rs = null;
		String query = null;
		String job_num = "360";
		if (args.length > 0) job_num = args[0];
		try{
			db.connect();
			String job_name = "This job's name";
			query = "select job_name from job where job_num = " + job_num;
			rs = db.dbQuery(query);
			if (rs.next()) job_name = rs.getString(1);
			if (rs != null) rs.close();
			rs = null;

			query = "select contracts.company_id, code_description, contracts.cost_code_id, company_name, city, name, phone, fax, mobile_phone from contracts, job_cost_detail as jcd, company, contacts "
				+ "where contracts.job_num = " + job_num + " and contracts.cost_code_id = jcd.cost_code_id and contracts.company_id = company.company_id "
				+ "and company.company_id = contacts.company_id and contracts.company_id != 546 order by company_name, name";
			rs = db.dbQuery(query);

			//System.out.println(query);

			JobContacts jc = new JobContacts(rs, job_name, 0);

			jc.create();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				rs = null;
				if (rs != null) rs.close();
				db.disconnect();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			System.out.println("\nComplete...\n");

		}
		*/
	}
	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}

}
