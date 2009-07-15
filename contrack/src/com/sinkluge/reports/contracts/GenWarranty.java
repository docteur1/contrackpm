package com.sinkluge.reports.contracts;

import java.awt.Color;
import java.sql.ResultSet;

import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;
import com.sinkluge.utilities.BigString;

public class GenWarranty extends Report {

	ResultSet info;
	String jobName;
	BigString txt;
	
	public void doCleanup(Database db) {}

	public GenWarranty(ResultSet info, String txt, String jobName){
		this.info = info;
		this.jobName = jobName;
		this.txt = new BigString(txt);
		this.txt.setProjectName(jobName);
		type = Type.SUBCONTRACT;
	}//constructor

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
		return "select contract_id, company.*, contacts.*, job.job_name, job.city, job.state from contracts join company "
			+ "on contracts.company_id = company.company_id left join contacts using(contact_id) join job "
			+ "where contract_id = " + id;
	}
	
	public static String getQuery2(String id) {
		return "select txt from reports where id = 'subWarranty'";
	}

	public void create (Info in, Image toplogo) throws Exception {
		init(15, 15, 36, 36);
		info.next();
		id = info.getString("contract_id");
		String company = info.getString("company_name");
		String address1 = info.getString("contacts.address");
		String address2, phone, fax;
		if (address1 != null) {
			address2 = info.getString("contacts.city") +", " + info.getString("contacts.state") + " " 
				+ info.getString("contacts.zip");
			phone = info.getString("contacts.phone");
			fax = info.getString("contacts.fax");
		} else {
			address1 = info.getString("company.address");
			address2 = info.getString("company.city") +", " + info.getString("company.state") + " " 
				+ info.getString("company.zip");
			phone = info.getString("company.phone");
			fax = info.getString("company.fax");
		}

		Cell blank = new Cell(new Phrase("", new Font(Font.HELVETICA, 6)));
		blank.setBorder(0);
		Table spacer=new Table(1,1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		spacer.addCell(blank);

		Phrase p1 = new Phrase();
		Table table1=new Table(2,2);
		int[] widths= {50,50};
		table1.setWidths(widths);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);


		p1=new Phrase("Warranty", new Font(Font.TIMES_ROMAN, 30));
		Cell cell=new Cell(p1);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		p1=new Phrase(jobName, new Font(Font.TIMES_ROMAN, 16));
		cell=new Cell(p1);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);


		blank.setColspan(2);
		table1.addCell(blank);
		blank.setColspan(1);

		cell = new Cell(new Phrase(company + "\n" + address1 + "\n" + address2, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Phone:\t " + phone + "\nFax:\t" + fax, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(2);
		table1.addCell(blank);
		blank.setColspan(1);

		document.add(table1);

		table1 = new Table(1,1);
		//table1.setDefaultCellBorder(0);
		table1.setBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);

		blank.setBackgroundColor(new Color(225, 225, 225));
		table1.addCell(blank);
		blank.setBackgroundColor(new Color(255, 255, 255));
		
		cell = new Cell(new Phrase(txt.toString(), new Font(Font.TIMES_ROMAN, 12)));
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(new Phrase("\nSigned:_________________________________________\n\nTitle:_________________________________________", new Font(Font.TIMES_ROMAN, 12)));
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);

	}
}
