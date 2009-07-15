package com.sinkluge.reports.submittals;

import java.awt.Color;
import org.apache.commons.io.output.ByteArrayOutputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lowagie.text.*;
import com.lowagie.text.pdf.Barcode39;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfWriter;
import com.sinkluge.Info;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Attachments;
import com.sinkluge.reports.Report;

//import com.joe.db.*;

public class GenSubmittalToSub  implements Report {

	ResultSet info;
	String job_name;
	String stamp;
	public void doCleanup(Database db) {
		try {
			if (info != null) info.getStatement().close();
			info = null;
		} catch (SQLException e) {}
	}
	

	public GenSubmittalToSub (String id, Database db) throws Exception {
		job_name = db.job_name;
		String query = "select company_name, contractor_stamp, name, contacts.address, contacts.city, contacts.state, user, submittal_type, "
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

	public ByteArrayOutputStream create(Info in, Image toplogo) throws Exception {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		Document document = new Document(PageSize.LETTER, 15, 15, 27, 36);
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		writer.setEncryption(null, "3p(0pdf".getBytes(), PdfWriter.ALLOW_COPY | 
				PdfWriter.ALLOW_PRINTING, PdfWriter.STANDARD_ENCRYPTION_128);
		document.open();
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

		cell = new Cell(new Phrase("Attention:\n        "
				+ name + "\nFrom:\n        "
				+ info.getString("user"), new Font(Font.TIMES_ROMAN,
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
		
		String id = info.getString("submittal_id");
		
		PdfContentByte cb = writer.getDirectContent();
		Barcode39 code39 = new Barcode39();
		code39.setCode("SL" + id);
		code39.setStartStopText(false);
		Image image39 = code39.createImageWithBarcode(cb, null, null);

		image39.setAbsolutePosition(30, 30);
		
		
		document.add(image39);

		int orgPages = writer.getPageNumber();
		
		Attachments.addImageAttachments(id, "SL", writer, document);
		
		document.close();

		return Attachments.addPDFAttachmentsAndStamp(id, "SL", orgPages, baos.toByteArray());
	}
}
