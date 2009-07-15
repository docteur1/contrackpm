package com.sinkluge.reports.submittals;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.User;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

//import com.joe.db.*;

public class GenSubmittalToSub  extends Report {

	ResultSet info;
	String job_name;
	String stamp;
	public void doCleanup(Database db) {
		try {
			if (info != null) info.getStatement().close();
			info = null;
		} catch (SQLException e) {}
	}
	
	public ReportContact getReportContact(String id, Database db) {
		String query = "select contact_id, company_id from contracts join submittals using(contract_id) " +
			"where submittal_id = " + id;
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

	public GenSubmittalToSub (String id, Database db, Attributes attr) throws Exception {
		job_name = attr.getJobName();
		this.id = id;
		type = Type.SUBMITTAL;
		String query = "select company_name, contractor_stamp, name, contacts.address, contacts.city, contacts.state, user_id, submittal_type, "
			+ "contacts.zip, contacts.phone, contacts.fax, submittal_num, submittal_id, alt_cost_code, "
			+ "submittals.description, submittal_status, comment_to_sub, comment_to_architect, "
		    + "cost_code from submittals join contracts using(contract_id) join job_cost_detail "
		    + "on submittals.cost_code_id = job_cost_detail.cost_code_id join company on contracts.company_id = company.company_id join contacts "
		    + "using(contact_id) where submittal_id = " + id;
		info = db.dbQuery(query);
		if (!info.isBeforeFirst()) {
			info.getStatement().close();
			query = "select company_name, contractor_stamp, null as name, address, city, state, zip, phone, fax, submittal_num, "
				+ "submittal_id, alt_cost_code, user, submittal_type, "
				+ "submittals.description, submittal_status, comment_to_sub, comment_to_architect, "
			    + "cost_code from submittals join contracts using(contract_id) join job_cost_detail "
			    + "on submittals.cost_code_id = job_cost_detail.cost_code_id join company on contracts.company_id = company.company_id where "
			    + "submittal_id = " + id;
			info = db.dbQuery(query);
		}
		query = "select txt from reports where id = 'submittalStamp'";
		ResultSet rs = db.dbQuery(query);
		if (rs.first()) stamp = rs.getString("txt");
		rs.getStatement().close();
		rs = null;
	}//constructor

	public void create(Info in, Image toplogo) throws Exception {
		init(15, 15, 27, 36);
		info.next();
		String submittal_num = info.getString("submittal_num");
		String spec = info.getString("alt_cost_code");
		if (spec == null || (spec.equals("")))
			spec = info.getString("cost_code");
		String company = info.getString("company_name");
		String name = info.getString("name");
		if (name == null) name = "";
		String address1 = info.getString("address");
		String address2 = info.getString("city") + ", "
				+ info.getString("state") + " " + info.getString("zip");

		Date cur_date = new java.util.Date();
		SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
		Phrase p1 = new Phrase();
		Table table1 = new Table(2, 2);
		int[] widths = { 60, 40 };
		table1.setWidths(widths);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		toplogo.scalePercent(20);
		Cell cell = new Cell(toplogo);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);

		Cell blank = new Cell(new Phrase("", new Font(Font.HELVETICA, 6)));

		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("\n" + job_name, new Font(
				Font.TIMES_ROMAN, 12, Font.BOLD)));
		cell.add(new Phrase("\nSubmittal Number: " + submittal_num,
				new Font(Font.TIMES_ROMAN, 10)));
		cell.add(new Phrase("\n" + sdf.format(cur_date), new Font(
				Font.TIMES_ROMAN, 10)));
		cell.setBorder(0); table1.addCell(cell);

		p1 = new Phrase("LETTER OF TRANSMITTAL", new Font(Font.TIMES_ROMAN,
				16, Font.BOLD));
		cell = new Cell(p1);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBackgroundColor(new Color(191, 191, 191));
		cell.setLeading(17);
		cell.setUseDescender(true);
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase(company + "\n" + address1 + "\n"
				+ address2, new Font(Font.TIMES_ROMAN, 12)));
		cell.add(new Phrase("\nPhone:\t " + info.getString("phone")
				+ "    Fax:\t" + info.getString("fax"), new Font(
				Font.TIMES_ROMAN, 8)));
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		User user = User.getUser(info.getInt("user_id"));
		
		cell = new Cell(new Phrase("Attention:\n        "
				+ name + (user != null ? "\nFrom:\n        "
				+ user.getFullName() : ""), new Font(Font.TIMES_ROMAN,
				12)));
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(2);
		blank.setBorder(0);
		table1.addCell(blank);
		blank.setColspan(1);

		document.add(table1);

		table1 = new Table(3, 5);
		int[] widths2 = { 2, 48, 50 };
		table1.setWidths(widths2);
		//table1.setDefaultCellBorder(0);
		table1.setBorder(0);
		table1.setPadding(2);

		cell = new Cell(new Phrase("We are sending: "
				+ info.getString("submittal_type"), new Font(
				Font.TIMES_ROMAN, 10)));
		cell.setColspan(2);
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.TOP);
		table1.addCell(cell);

		cell = new Cell(new Phrase("Spec. No. " + spec, new Font(
				Font.TIMES_ROMAN, 10)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(Rectangle.TOP);
		table1.addCell(cell);

		cell = new Cell(new Phrase("Submittal Status:   ", new Font(
				Font.TIMES_ROMAN, 10)));
		cell.add(new Phrase(info.getString("submittal_status"), new Font(
				Font.TIMES_ROMAN, 10, Font.ITALIC)));
		cell.setVerticalAlignment("top");
		cell.setColspan(3);
		cell.setBorder(Rectangle.BOTTOM);
		table1.addCell(cell);

		cell = new Cell(new Phrase("Details:", new Font(Font.TIMES_ROMAN,
				10)));
		cell.setVerticalAlignment("top");
		cell.setColspan(3);
		cell.setBorder(0); table1.addCell(cell);

		Image blank1_0 = Image.getInstance(in.path
				+ "/jsp/images/blank1_0.jpg");
		cell = new Cell();
		cell.add(blank1_0);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase(info.getString("description"), new Font(
				Font.TIMES_ROMAN, 10)));
		cell.setVerticalAlignment("top");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		table1.addCell(blank);
		table1.addCell(blank);
		table1.addCell(blank);

		String remarks = info.getString("comment_to_sub");
		if (remarks == null)
			remarks = "";
		cell = new Cell(new Phrase("Remarks:", new Font(Font.TIMES_ROMAN,
				10)));
		cell.setVerticalAlignment("top");
		cell.setBorder(Rectangle.TOP);
		cell.setColspan(3);
		table1.addCell(cell);

		Image blank2_5 = Image.getInstance(in.path
				+ "/jsp/images/blank2_5.jpg");
		cell = new Cell();
		cell.add(blank2_5);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase(remarks, new Font(Font.TIMES_ROMAN, 10)));
		cell.setVerticalAlignment("top");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(
				new Phrase(
						"Copy to: _____________________________________\n              _____________________________________",
						new Font(Font.TIMES_ROMAN, 10)));
		cell.setVerticalAlignment("top");
		cell.setColspan(3);
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);
		
		if (info.getString("contractor_stamp") != null) {
		
			Table spacer = new Table(1, 1);
			spacer.setBorderWidth(0);
			//spacer.setDefaultCellBorderWidth(0);
			spacer.setWidth(100);
			spacer.setPadding(0);
			spacer.setSpacing(0);
			spacer.addCell(blank);
			
			document.add(spacer);
			
			table1 = new Table(1, 1);
			table1.setBorderWidth(0);
			//table1.setDefaultCellBorderWidth(0);
			table1.setWidth(80);
			table1.setPadding(2);
			table1.setSpacing(0);
			
			cell = new Cell(new Paragraph(info.getString("contractor_stamp").toUpperCase(), 
					new Font(Font.TIMES_ROMAN, 10, Font.BOLD, Color.RED)));
			cell.setBorder(0);
			cell.setBorder(0); table1.addCell(cell);
	
			cell = new Cell(new Paragraph(stamp, new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
			cell.setBorder(0);
			cell.setBorder(0); table1.addCell(cell);
			
			document.add(table1);
		
		}

	}
}
