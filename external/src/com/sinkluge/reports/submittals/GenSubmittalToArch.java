package com.sinkluge.reports.submittals;

import java.awt.Color;
import org.apache.commons.io.output.ByteArrayOutputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lowagie.text.Cell;
import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.Table;
import com.lowagie.text.pdf.Barcode39;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfWriter;
import com.sinkluge.Info;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Attachments;
import com.sinkluge.reports.Report;

public class GenSubmittalToArch  implements Report {

	ResultSet info;
	String subcontractor = null;
	String job_name;
	
	public void doCleanup(Database db) {
		try {
			if (info != null) info.getStatement().close();
			info = null;
		} catch (SQLException e) {}
	}
	

	public GenSubmittalToArch(String id, Database db) throws Exception {
		String query = "select company_name from submittals join contracts using(contract_id) join "
			+ "company using(company_id) where submittal_id = " +id;
		info = db.dbQuery(query);
		if (info.first()) subcontractor = info.getString(1);
		else subcontractor = db.get("full_name");
		info.getStatement().close();
		query = "select company_name, name, contacts.address, contacts.city, contacts.state, user, submittal_type, "
			+ "contacts.zip, contacts.phone, contacts.fax, submittal_num, submittal_id, alt_cost_code, "
			+ "submittals.description, submittal_status, comment_to_sub, comment_to_architect, "
		    + "cost_code from submittals left join contracts using(contract_id) left join job_cost_detail "
		    + "on job_cost_detail.cost_code_id = submittals.cost_code_id left join job_contacts on architect_id = job_contact_id left join "
		    + "company on job_contacts.company_id = company.company_id join contacts on job_contacts.contact_id = "
		    + "contacts.contact_id where submittal_id = " + id;
		info = db.dbQuery(query);
		if (!info.isBeforeFirst()) {
			info.getStatement().close();
			query = "select company_name, null as name, address, city, state, zip, phone, fax, submittal_num, "
				+ "submittal_id, alt_cost_code, user, submittal_type, "
				+ "submittals.description, submittal_status, comment_to_sub, comment_to_architect, "
			    + "cost_code from submittals left join contracts using(contract_id) left join job_cost_detail "
			    + "on job_cost_detail.cost_code_id = submittals.cost_code_id left join job_contacts on architect_id = job_contact_id left join "
			    + "company on job_contacts.company_id = company.company_id where submittal_id = " + id;
			info = db.dbQuery(query);
		}
		job_name = db.job_name;
		info.first();
		

	}// constructor

	public ByteArrayOutputStream create(Info in, Image toplogo) throws Exception {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		Document document = new Document(PageSize.LETTER, 15, 15, 27, 36);
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		writer.setEncryption(null, "3p(0pdf".getBytes(), PdfWriter.ALLOW_COPY | 
				PdfWriter.ALLOW_PRINTING, PdfWriter.STANDARD_ENCRYPTION_128);
		document.open();
		String submittal_num = info.getString("submittal_num");
		String spec = info.getString("alt_cost_code");
		if (spec == null || (spec.equals("")))
			spec = info.getString("cost_code");
		String name = info.getString("name");
		if (name == null) name = "";
		String company = info.getString("company_name");
		String address1 = info.getString("address");
		String address2 = info.getString("city") + ", "
				+ info.getString("state") + " " + info.getString("zip");
		String comments = info.getString("comment_to_architect");
		if (comments == null)
			comments = "";
		Image unchecked = Image.getInstance(in.path
				+ "/jsp/images/unchecked.jpg");
		Image checked = Image.getInstance(in.path
				+ "/jsp/images/checked.jpg");
		Image blank1_0 = Image.getInstance(in.path
				+ "/jsp/images/blank1_0.jpg");
		Font tnr10 = new Font(Font.TIMES_ROMAN, 10);
		String id = info.getString("submittal_id");
		PdfContentByte cb = writer.getDirectContent();
		Barcode39 code39 = new Barcode39();
		code39.setCode("SL" + id);
		code39.setStartStopText(false);
		Image image39 = code39.createImageWithBarcode(cb, null, null);
		Date cur_date = new java.util.Date();
		SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
		Phrase p1 = new Phrase();
		int[] widths3 = { 60, 40 };
		Table table1 = new Table(2, 2);
		table1.setWidths(widths3);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(0);
		table1.setOffset(0);
		toplogo.scalePercent(20);
		Chunk ch1 = null;
		// p1.add(ch1);
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
		cell.add(new Phrase("\nSubmittal Number: " + submittal_num, tnr10));
		cell.add(new Phrase("\n" + sdf.format(cur_date), tnr10));
		cell.setBorder(0); table1.addCell(cell);

		p1 = new Phrase("LETTER OF TRANSMITTAL", new Font(Font.TIMES_ROMAN,
				16, Font.BOLD));
		cell = new Cell(p1);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBackgroundColor(new Color(191, 191, 191));
		cell.setColspan(2);
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase(company + "\n" + address1 + "\n"
				+ address2, new Font(Font.TIMES_ROMAN, 12)));
		cell.add(new Phrase("\nPhone:\t " + info.getString("phone")
				+ "    Fax:\t" + info.getString("fax"), new Font(
				Font.TIMES_ROMAN, 8)));
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Attention:\n   "
				+ name + "\nFrom: \n   "
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
		int[] widths2 = { 10, 40, 50 };
		table1.setWidths(widths2);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setBorderWidth(1);

		// first row
		cell = new Cell(new Phrase("We are sending: "
				+ info.getString("submittal_type"), tnr10));
		cell.setColspan(2);
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Spec. No. " + spec, tnr10));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		// second row
		cell = new Cell(new Chunk(blank1_0, 5, 5));
		cell.setRowspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Description:  "
				+ info.getString("description"), tnr10));
		cell.setVerticalAlignment("top");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		// third row
		cell = new Cell(new Phrase("Subcontractor:  " + subcontractor,
				tnr10));
		cell.setVerticalAlignment("top");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		// fourth row
		cell = new Cell(new Phrase("These Transmissions are:", tnr10));
		cell.setVerticalAlignment("top");
		cell.setColspan(3);
		cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
		// cell.setBackgroundColor(new Color(225, 225, 225));
		cell.setBorder(0); table1.addCell(cell);

		// sixth row - what this submittal is for
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.add(new Chunk(checked, 2, -2));
		cell.add(new Phrase("  For your approval  ", tnr10));
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  For review and comment  ", tnr10));
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  Approved as submitted  ", tnr10));
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  To be resubmitted", tnr10));
		cell.setColspan(3);
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  For your use  ", tnr10));
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  Per your request  ", tnr10));
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  Approved as noted  ", tnr10));
		cell.add(new Chunk(unchecked, 2, -2));
		cell.add(new Phrase("  Other: ________________________________",
				tnr10));
		cell.setUseDescender(true);
		cell.setColspan(3);
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);

		// 7th row
		table1 = new Table(3, 4);
		int[] checkwidths = { 5, 50, 45 };
		//table1.setDefaultCellBorder(0);
		table1.setWidths(checkwidths);
		table1.setBorderWidth(0);

		cell = new Cell(new Phrase(" \n\n\n\n\n\n\n "));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Comments:\n" + comments, new Font(
				Font.TIMES_ROMAN, 10, Font.ITALIC)));
		cell.setVerticalAlignment("top");
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(
				new Phrase(
						"Copy to: _____________________________________\n               _____________________________________\n\n",
						tnr10));
		cell.setColspan(2);
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);

		table1 = new Table(4, 1);
		int[] widths = { 2, 22, 45, 33 };
		table1.setWidths(widths);
		table1.setPadding(2);
		//table1.setDefaultCellBorder(0);
		table1.setBorderWidth(1);

		cell = new Cell("");
		cell.setBorder(Rectangle.BOTTOM);
		cell.setBorder(0); table1.addCell(cell);

		p1 = new Phrase("ENGINEER'S RESPONSE", tnr10);
		cell = new Cell(p1);
		cell.setVerticalAlignment("top");
		cell.setColspan(2);
		cell.setBorder(Rectangle.BOTTOM);
		// cell.setBackgroundColor(new Color(225, 225, 225));
		cell.setBorder(0); table1.addCell(cell);

		p1 = new Phrase("Copies Returned: _____    ", new Font(
				Font.TIMES_ROMAN, 8));
		cell = new Cell(p1);
		cell.setVerticalAlignment("bottom");
		cell.setHorizontalAlignment("right");
		cell.setBorder(Rectangle.BOTTOM);
		// cell.setBackgroundColor(new Color(225, 225, 225));
		cell.setBorder(0); table1.addCell(cell);

		table1.addCell(blank);

		ch1 = new Chunk(unchecked, 0, -2);
		p1 = new Phrase(ch1);
		p1.add(new Phrase("  Approved as Submitted\n", new Font(
				Font.TIMES_ROMAN, 8)));
		p1.add(ch1);
		p1.add(new Phrase("  Approved as Noted", new Font(Font.TIMES_ROMAN,
				8)));
		cell = new Cell(p1);
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		p1 = new Phrase(ch1);
		p1.add(new Phrase("  Disapproved - Make Corrections\n", new Font(
				Font.TIMES_ROMAN, 8)));
		p1.add(ch1);
		p1.add(new Phrase(
				"  Disapproved - As Noted, Develop Replacement\n",
				new Font(Font.TIMES_ROMAN, 8)));
		p1.add(ch1);
		p1.add(new Phrase("  Reference only - Approval Not Req'd",
				new Font(Font.TIMES_ROMAN, 8)));
		cell = new Cell(p1);
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		p1 = new Phrase(ch1);
		p1.add(new Phrase("  Incomplete - Complete and Resubmit\n",
				new Font(Font.TIMES_ROMAN, 8)));
		p1.add(ch1);
		p1.add(new Phrase("  Incomplete - Submit Missing Portions",
				new Font(Font.TIMES_ROMAN, 8)));
		cell = new Cell(p1);
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Comments: ", new Font(Font.TIMES_ROMAN,
				8)));
		// for(i=0; i<10; i++) cell.add(new
		// Phrase("___________________________________________________________________________________________________"));

		cell = new Cell(
				new Phrase(
						"\n\nSigned: _____________________________________________________________________",
						new Font(Font.TIMES_ROMAN, 8)));
		cell.setVerticalAlignment("top");
		cell.setHorizontalAlignment("center");
		cell.setColspan(4);
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Engineer Representative", new Font(
				Font.TIMES_ROMAN, 8)));
		cell.setVerticalAlignment("top");
		cell.setHorizontalAlignment("center");
		cell.setColspan(4);
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);

		image39.setAbsolutePosition(30, 30);

		document.add(image39);
		int orgPages = writer.getPageNumber();
		
		Attachments.addImageAttachments(id, "SL", writer, document);
		
		document.close();

		return Attachments.addPDFAttachmentsAndStamp(id, "SL", orgPages, baos.toByteArray());
	}
}
