package com.sinkluge.reports.letters;

import java.awt.Color;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.User;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenLetter extends Report {

	ResultSet ltr;
	String job_name, shortName;
	
	public static String getQuery(String id, String contact_id, String company_id) {
		return "select letters.*, c.*, n.* from letters join company as c on c.company_id = "
			+ company_id + " left join contacts as n on n.contact_id = " + contact_id + " where "
			+ "letter_id = " + id;
	}

	public GenLetter(ResultSet ltr, String job_name, String shortName) {
		this.ltr = ltr;
		this.job_name = job_name;
		this.shortName = shortName;
		type = Type.LETTER;
	}// constructor
	
	public void create(Info in, Image toplogo) throws Exception{
		init();
		SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
		ltr.next();
		id = ltr.getString("letter_id");
		String subject = ltr.getString("subject");
		String body_text = ltr.getString("body_text");
		String salutation = ltr.getString("salutation");
		if (salutation == null)
			salutation = "";
		User user = User.getUser(ltr.getInt("user_id"));
		String sender = (user != null ? user.getFullName() : "");
		String cc = ltr.getString("cc");
		Date date_created = ltr.getDate("date_created");
		Table table1 = new Table(1, 1);
		//Table table2 = new Table(2, 2);
		Cell cell = new Cell();
		Cell blank = new Cell(new Phrase("", new Font(Font.HELVETICA, 6)));
		String name = "", address = "", state = "", city = "", zip = "", company_name = "", phone = "", fax = "";
		String opener = "";
		
		company_name = ltr.getString("company_name");
		name = ltr.getString("name");
		if (name == null)
			name = company_name;
		if (salutation.equals(""))
			opener = name;
		else
			opener = salutation;
		if (!opener.equals(""))
			opener += ",";
		
		address = ltr.getString("n.address");
		if (address == null) address = ltr.getString("c.address");
		if (address == null) address = "";
		city = ltr.getString("n.city");
		if (city == null) city = ltr.getString("c.city");
		if (city == null) city = "";
		state = ltr.getString("n.state");
		if (state == null) state = ltr.getString("c.state");
		if (state == null) state = "";
		zip = ltr.getString("n.zip");
		if (zip == null) zip = ltr.getString("c.zip");
		if (zip == null) zip = "";
		phone = ltr.getString("n.phone");
		if (phone == null) phone = ltr.getString("c.phone");
		if (phone == null) phone = "";
		fax = ltr.getString("n.fax");
		if (fax == null) fax = ltr.getString("c.fax");
		if (fax == null) fax = "";

		int[] widths3 = { 60, 40 };
		table1 = new Table(2, 2);
		table1.setWidths(widths3);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		table1.setWidth(100);
		toplogo.scalePercent(20);
		cell = new Cell(toplogo);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		
		table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("\n" + job_name, new Font(Font.TIMES_ROMAN,
				12, Font.BOLD)));
		cell.add(new Phrase("\n" + sdf.format(date_created) + "\n\n",
				new Font(Font.TIMES_ROMAN, 12)));
		cell.setBorder(0); table1.addCell(cell);

		if (subject != null && subject.length() > 0) {
			cell = new Cell(new Phrase(subject, new Font(
					Font.TIMES_ROMAN, 16, Font.BOLD)));
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			cell.setUseDescender(true);
			cell.setLeading(17);
			cell.setBackgroundColor(new Color(191, 191, 191));
			cell.setColspan(2);
			cell.setBorder(0); table1.addCell(cell);
		}

		cell = new Cell(new Phrase(company_name + "\n" + name + "\n"
				+ address + "\n" + city + ", " + state + " " + zip,
				new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Attention:   " + name
				+ "\n    Phone:  " + phone + "\n    Fax:  " + fax
				+ "\nFrom: " + sender, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(2);
		// table1.addCell(blank);
		blank.setColspan(1);

		document.add(table1);

		// st = new StringTokenizer(name);
		// name = st.nextToken();
		// name = name.substring(0,name.indexOf(" "));
		// body of the letter
		table1 = new Table(1, 1);
		table1.setWidth(100);
		table1.setBorder(0);
		//table1.setDefaultCellBorder(0);
		cell = new Cell(
				new Phrase(
						"\n"
								+ opener
								+ "\n\n"
								+ body_text
								+ "\n\n                                                                            Sincerely,\n\n\n                                                                            "
								+ sender
								+ "\n                                                                            " + shortName + "\n\n",
						new Font(Font.TIMES_ROMAN, 12)));
		if (cc != null && cc.length() != 0)
			cell.add(new Phrase("CC:   " + cc, new Font(
					Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		document.newPage();

	}

	public void doCleanup(Database db) throws Exception {
		
	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}
}
