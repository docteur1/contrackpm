package com.sinkluge.reports.contracts;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.lowagie.text.Cell;
import com.lowagie.text.Chunk;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenSubSubmittal extends Report {

	ResultSet rs;

	String companyName, jobName, address, city, state, zip, phone, fax,
			submittalCopies, contract_id;
	
	Attributes attr;

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
	
	public void doCleanup(Database db) {
		try {
			if (rs != null) rs.getStatement().close();
			rs = null;
		} catch (SQLException e) {}
	}
	
	public GenSubSubmittal(String id, Database db, Attributes attr) throws Exception {
		this.attr = attr;
		this.id = id;
		type = Type.SUBCONTRACT;
		rs = db.dbQuery("select company_name, job_name, c.address, c.city, c.state, c.zip, c.phone, c.fax, "
			+ "submittal_copies from contracts join job using (job_id) join company as c using (company_id) where "
			+ "contract_id = " + id);
		rs.first();
		this.companyName = rs.getString("company_name");
		this.jobName = rs.getString("job_name");
		this.address = rs.getString("address");
		if (this.address == null)
			this.address = "";
		this.city = rs.getString("city");
		this.state = rs.getString("state");
		this.zip = rs.getString("zip");
		this.phone = rs.getString("phone");
		this.fax = rs.getString("fax");
		this.submittalCopies = rs.getString("submittal_copies");
	}// constructor

	public void create(Info in, Image toplogo) throws Exception {
		init();
		Image checkbox = Image.getInstance(in.path
				+ "/WEB-INF/images/unchecked.jpg");
		Chunk ch2 = new Chunk(checkbox, -7, -7);
		Phrase checkboxPhrase = new Phrase();
		checkboxPhrase.add(ch2);

		Image iBox = Image.getInstance(in.path
				+ "/WEB-INF/images/initialsBox.jpg");
		Chunk ch3 = new Chunk(iBox, -3, -3);
		Phrase initialsBoxPhrase = new Phrase();
		initialsBoxPhrase.add(ch3);

		Phrase underLinePhrase = new Phrase(
				"  ___________________________________________________________________________________________  ",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD));
		Phrase blankLinePhrase = new Phrase("\n");
		int[] two = { 60, 40 };// sets the widths of the columns(2) with
								// checkboxes
		int[] twoB = { 70, 30 };
		int[] three = { 7, 7, 86 };
		int[] eight = { 4, 26, 4, 26, 10, 10, 4, 26 };

		// blank spacer for keeping tables apart
		Table spacer = new Table(1, 1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		Cell blank = new Cell();
		blank.add(new Chunk("", new Font(Font.TIMES_ROMAN, 1, Font.BOLD,
				new Color(255, 255, 255))));
		blank.setBorderWidth(0);
		blank.setLeading(0);
		spacer.addCell(blank);

		// add image
		Table table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		// add title on top
		Cell cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
				"SUBCONTRACTOR/SUPPLIER'S SUBMITTAL TRANSMITTAL FORM\n",
				new Font(Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); 
		table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setOffset(4);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setLeading(10);
		cell.add(new Phrase(jobName, new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell.add(new Phrase("\nSubmittals are due as specified in AGREEMENT EXHIBIT \"C\"",
				new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		// document.add(spacer);

		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(two);
		table1.setPadding(0);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("TO:",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("FROM:", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(attr.get("short_name"),
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(companyName, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(attr.get("address"), new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(address, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(attr.get("city") + ", " + attr.get("state") + "   " + attr.get("zip"), new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(city + "," + state + "   " + zip, new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Phone: " + attr.get("phone") + "    Fax: " + attr.get("fax"),
				new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Phone: " + phone + "  " + "Fax: " + fax,
				new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		/*
		 * table1=new Table(1,1); table1.setBorderWidth(0); table1.setWidth(100);
		 * //table1.setDefaultCellBorder(0); cell= new Cell();
		 * cell.add(underLinePhrase); cell.setBorder(0); table1.addCell(cell);
		 * document.add(table1);
		 */
		table1 = new Table(2, 1);
		table1.setBorderWidth(0);
		//table1.setBorder(Rectangle.TOP);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(twoB);
		table1.setOffset(6);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Submitted with this transmittal are "
				+ submittalCopies + " copies of:", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("This is:", new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(8, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(eight);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Shop Drawings or Plans", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Materials Specification", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("An Original Submittal", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Material Samples", new Font(Font.TIMES_ROMAN,
				10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Color Chart/Samples", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("A 2nd Submittal", new Font(Font.TIMES_ROMAN,
				10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.setColspan(3);
		cell.add(new Phrase("Other: __________________________________",
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("A ______ Submittal", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.setColspan(3);
		cell.add(new Phrase("Operations & Maintenance Manuals",
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);

		// document.add(spacer);

		table1 = new Table(1, 1);
		table1.setBorderWidth(1);
		//table1.setDefaultCellBorder(0);
		table1.setWidth(90);
		table1.setOffset(9);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		// cell.setLeading(20);
		cell.add(new Phrase("Subject Of Submittal\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment(5);
		cell.setLeading(20);
		cell.add(underLinePhrase);
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(blankLinePhrase);
		cell.setBorder(0);
		table1.addCell(cell);
		document.add(table1);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(90);
		//table1.setDefaultCellBorder(0);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell
				.add(new Phrase(
						"REQUIRED:  Complete and sign for either (A) or (B) as follows:",
						new Font(Font.TIMES_ROMAN, 12, Font.BOLD)));
		cell.add(new Phrase("\n                   Initial Only One",
				new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		Table table2 = new Table(3, 1);
		table2.setBorderWidth(0);
		//table2.setDefaultCellBorder(0);
		table2.setWidths(three);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("A: ",
				new Font(Font.TIMES_ROMAN, 12, Font.BOLD)));
		cell.setBorder(0);
		table2.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(initialsBoxPhrase);
		cell.setBorder(0);
		table2.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
						companyName
								+ " has verified all materials, equipment, design, and all other properties of the attached submittals comply with the Project Plans and Specifications as published for "
								+ jobName + ".", new Font(Font.TIMES_ROMAN,
								10, Font.BOLD)));
		cell.setBorder(0);
		table2.addCell(cell);
		// table1.add(table2);
		document.add(table2);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(90);
		//table1.setDefaultCellBorder(0);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("- OR -\n", new Font(Font.TIMES_ROMAN, 16,
				Font.ITALIC)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table2 = new Table(3, 1);
		table2.setBorderWidth(0);
		//table2.setDefaultCellBorder(0);
		table2.setWidths(three);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("B: ",
				new Font(Font.TIMES_ROMAN, 12, Font.BOLD)));
		cell.setBorder(0);
		table2.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(initialsBoxPhrase);
		cell.setBorder(0);
		table2.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
						companyName
								+ " has verified all materials, equipment, design, and all other properties of the attached submittals comply with the Project Plans and Specifications as published for "
								+ jobName
								+ " EXCEPT for the following deviations (Listed here and marked on the submittals where appropriate):",
						new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		table2.addCell(cell);
		cell.setBorder(0);
		document.add(table2);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(90);
		//table1.setDefaultCellBorder(0);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setLeading(20);
		cell.add(underLinePhrase);
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(blankLinePhrase);
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase(
						"   Printed Name: __________________________________  Signature: ________________________________ ",
						new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

	}
/*
	public static void main(String[] args) throws Exception {
		String companyName = "The Sinkluge Group";
		String jobName = "Project--Get the Kluge Out";
		String address = "My Address";
		String city = "Whatever city";
		String state = "This State";
		String zip = "ZipCode";
		String phone = "1234567";
		String fax = "12309874";
		int user_id = 3298;
		GenSubSubmittal g = new GenSubSubmittal(user_id, companyName, jobName,
				"7", address, city, state, zip, phone, fax);
		System.out.println(g.create());
	}
*/
}
