package com.sinkluge.reports.contracts;

import java.awt.Color;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

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

public class GenCloseout extends Report {

	private ResultSet info;
	private BigString txt;
	
	public void doCleanup(Database db) {}

	public GenCloseout(ResultSet info, String txt) {
		this.info = info;
		this.txt = new BigString(txt);
		type = Type.SUBCONTRACT;
		attachments = false;
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
		return "select contracts.*, company.*, contacts.*, job.job_name, job.city, job.state from contracts "
			+ "join company on contracts.company_id = company.company_id left join contacts using(contact_id) "
			+ "join job on contracts.job_id = job.job_id where contract_id = " + id;
	}
	
	public static String getQuery2(String id) {
		return "select txt from reports where id = 'subCloseout'";
	}

	public void create (Info in, Image toplogo) throws Exception {
		init(15, 15, 36, 36);
		SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");

		//while(info.next()) {
		info.first();
		id = info.getString("contract_id");
		String job_name = info.getString("job_name");
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
		String reqSub = info.getString("req_tech_submittals");
		String 	haveSub = info.getString("have_tech_submittals");
		String 	reqWar = info.getString("req_warranty");
		String 	haveWar = info.getString("have_warranty");
		String 	reqTrain = info.getString("req_owner_training");
		String 	haveTrain = info.getString("have_owner_training");
		//String 	haveLien = info.getString("have_lien_release");
		String 	reqSpecialty = info.getString("req_specialty");
		if(reqSpecialty == null) reqSpecialty = "";
		String 	haveSpecialty = info.getString("have_specialty");

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
		Table table1=new Table(3,2);
		int[] widths= {60,40};
		int[] width2= {59,1,40};
		table1.setWidths(width2);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		toplogo.scalePercent(20);
		//blank1_0.scalePercent(85);
		//Chunk ch1=new Chunk(toplogo, -10, -60);
		//p1.add(ch1);
		Cell cell=new Cell(toplogo);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.add(new Phrase("\n\n\n\n"));
		cell.setBorder(0); table1.addCell(cell);

		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(job_name+ "\n", new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell.add(new Phrase(sdf.format(new java.util.Date()), new Font(Font.TIMES_ROMAN, 10)));
		cell.setBorder(0); table1.addCell(cell);


		p1=new Phrase("Project Closeout", new Font(Font.TIMES_ROMAN, 16, Font.BOLD));
		cell=new Cell(p1);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		cell.setBackgroundColor(new Color(191, 191, 191));
		cell.setColspan(3);
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(3);
		table1.addCell(blank);
		blank.setColspan(1);

		cell = new Cell(new Phrase(company + "\n" + address1 + "\n" + address2, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);

		table1.addCell(blank);

		cell = new Cell(new Phrase("Phone:\t " + phone + "\nFax:\t" + fax, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(3);
		table1.addCell(blank);
		blank.setColspan(1);

		document.add(table1);

		table1 = new Table(2,2);
		table1.setWidths(widths);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);

		table1.addCell(blank);
		blank.setBackgroundColor(new Color(225, 225, 225));
		table1.addCell(blank);
		blank.setBackgroundColor(new Color(255, 255, 255));

		if(job_name.substring(0,3).compareTo("The") == 0)  job_name = job_name.substring(4); //take "The" out of job names so it's not repeated in this sentence
		cell = new Cell(new Phrase("        The " + job_name + " project is nearing completion. As closeout approaches the following item(s) are needed:\n", new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("        Please provide the indicated item(s) below:", new Font(Font.TIMES_ROMAN, 10, Font.ITALIC	)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("center");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Operation and Maintenance Manuals:", new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		String myOut = "";
		if(reqSub.equals("n")) myOut = "(Not Required)";
		else if (haveSub.equals("n")) myOut = "Yes";
		else myOut = "Received";
		cell = new Cell(new Phrase(myOut, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Letter of Warranty:", new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		if(reqWar.equals("n")) myOut = "(Not Required)";
		else if (haveWar.equals("n")) myOut = "Yes";
		else myOut = "Received";
		cell = new Cell(new Phrase(myOut, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Signed Copy of \"Owner's Training Form\":", new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		if(reqTrain.equals("n")) myOut = "(Not Required)";
		else if (haveTrain.equals("n")) myOut = "Yes";
		else myOut = "Received";
		cell = new Cell(new Phrase(myOut, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Other Closeout Requirements:", new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		if(reqSpecialty.equals("")) myOut = "(Not Required)";
		else if (haveSpecialty.equals("n")) myOut = "Yes";
		else myOut = "Received";
		cell = new Cell(new Phrase(myOut, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);

		//table1.addCell(blank);  //taken out due to the increase in size for the requirement specialty statement

		cell = new Cell(new Phrase(reqSpecialty, new Font(Font.TIMES_ROMAN, 12, Font.ITALIC)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("\n(Any other items specifically required by the contract documents)\n\n", new Font(Font.TIMES_ROMAN, 10)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("center");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase(txt.toString(), new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("left");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);

	}

}
