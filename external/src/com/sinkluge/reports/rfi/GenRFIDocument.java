package com.sinkluge.reports.rfi;

import java.awt.Color;
import org.apache.commons.io.output.ByteArrayOutputStream;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

import com.lowagie.text.Cell;
import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.lowagie.text.pdf.Barcode39;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfWriter;
import com.sinkluge.Info;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Attachments;
import com.sinkluge.reports.Report;

public class GenRFIDocument implements Report {

	private String attn, from, rfiNum, jobName, request, urgency, company, address, city, state, zip, phone, fax, reply;
	ResultSet rs;
	
	
	public void doCleanup(Database db) {}
	
	public static String getQuery(String id) {
		return "select rfi.*, company.company_name, contacts.* from rfi join company using(company_id) join contacts using(contact_id) where rfi_id = " + id;
	}
	public static String getQuery2(String id) {
		return "select rfi.*, company.*, null as name from rfi join company using(company_id) where rfi_id = " + id;
	}
	
	public GenRFIDocument(ResultSet rs, String jobName){
		this.jobName = jobName;
		this.rs = rs;
	}//constructor

	public ByteArrayOutputStream create(Info in, Image toplogo) throws Exception {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		rs.next();
		attn = rs.getString("name");
		if (attn == null) attn = "";
		from = rs.getString("user");
		rfiNum = rs.getString("rfi_num");
		request = rs.getString("request");
		if (request==null) request = "";
		urgency = rs.getString("urgency");
		if (urgency == null) urgency = "";
		company = rs.getString("company_name");
		address = rs.getString("address");
		city = rs.getString("city");
		state = rs.getString("state");
		zip = rs.getString("zip");
		phone = rs.getString("phone");
		fax = rs.getString("fax");
		reply = rs.getString("reply");
		if (reply==null) reply="";
		Document document = new Document(PageSize.LETTER, 15, 15, 36 ,36);
		SimpleDateFormat formatter = new SimpleDateFormat("MMMM d, yyyy");
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		document.open();

		Phrase p1 = new Phrase();
		Table table1=new Table(2,2);
		table1.setBorderWidth(0);
		int[] widths= {60,40};
		table1.setWidths(widths);
		toplogo.scalePercent(20);
		Chunk ch1= null; //new Chunk(toplogo, -10, -50);
		//p1.add(ch1);
		Cell cell=new Cell(toplogo);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		table1.addCell(cell);
		cell = new Cell();
		if(jobName.length()<27) jobName ="\n" + jobName;
		cell.add(new Phrase(jobName, new Font(Font.TIMES_ROMAN, 16)));
		cell.add(new Phrase("\nRFI: ", new Font(Font.TIMES_ROMAN, 12, Font.BOLD)));
		cell.add(new Phrase(rfiNum, new Font(Font.TIMES_ROMAN, 12)));
		cell.add(new Phrase("\n" + formatter.format(new java.util.Date()), new Font(Font.HELVETICA, 8, Font.ITALIC)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setLeading(16);
		cell.setBorderWidth(0);
		table1.addCell(cell);
		document.add(table1);

		Table spacer=new Table(1,1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		Cell cellblank=new Cell();
		cellblank.add(new Chunk("", new Font(Font.TIMES_ROMAN, 1, Font.BOLD, new Color(255, 255, 255))));
		cellblank.setBorderWidth(0);
		cellblank.setLeading(0);
		spacer.addCell(cellblank);

		//document.add(spacer);

		table1=new Table(1,2);
		table1.setOffset(10);
		table1.setPadding(3);
		//table1.setDefaultCellBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setBorder(0);
		p1=new Phrase();
		p1.add(new Chunk("Request For Information", new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell = new Cell(p1);
		cell.setLeading(17);
		cell.setUseDescender(true);
		cell.setBorder(0);
		cell.setBackgroundColor(new Color(191, 191, 191));
		cell.setVerticalAlignment("top");
		cell.setHorizontalAlignment("center");
		table1.addCell(cell);
		document.add(table1);

		document.add(spacer);

		table1=new Table(2,1);
		table1.setBorder(0);
		int[] colwidths={45, 55};
		table1.setWidths(colwidths);
		table1.setSpacing(5);
		table1.setPadding(5);
		//table1.setDefaultCellBorder(0);
		//table1.setDefaultCellBorderWidth(0);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		p1=new Phrase("          " +company + "\n          " + address + "\n          " + city + ", " + state + " " + zip + "\n\nPhone:   " + phone + "\t\tFax:   " + fax, new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
		cell.setHorizontalAlignment("left");
		cell.add(p1);
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new Cell();
		cell.setBackgroundColor(new Color(255, 255,255));
		cell.setBorderWidth(0);
		p1=new Phrase("          Attention:\n               " + attn + "\n\n          From:\n               " + from, new Font(Font.TIMES_ROMAN, 12, Font.NORMAL));
		cell.setLeading(12);
		cell.setHorizontalAlignment("left");
		cell.add(p1);
		table1.addCell(cell);

		document.add(table1);
		document.add(spacer);

		table1=new Table(2,3);
		table1.setBorderWidth(1);
		table1.setPadding(3);
		colwidths[0]=2;
		colwidths[1]=98;
		table1.setWidths(colwidths);
		cell=new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorderWidth(0);
		cell.setColspan(2);
		p1=new Phrase("Request: ", new Font(Font.TIMES_ROMAN, 12, Font.BOLD));
		cell.add(p1);
		table1.addCell(cell);

		Image blank2_5 = Image.getInstance(in.path + "/jsp/images/blank2_5.jpg");
		cell = new Cell();
		cell.setBorderWidth(0);
		cell.add(blank2_5);
		table1.addCell(cell);

		cell = new Cell(new Phrase(request, new Font(Font.TIMES_ROMAN, 10)));
		cell.setVerticalAlignment("top");
		cell.setBorderWidth(0);
		cell.setLeading(12);
		table1.addCell(cell);
		Image checked= Image.getInstance(in.path + "/jsp/images/checked.jpg");
		Image unchecked= Image.getInstance(in.path + "/jsp/images/unchecked.jpg");
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorderWidth(1);
		cell.setColspan(2);
		p1=new Phrase("Urgency:   ", new Font(Font.TIMES_ROMAN, 10));
		if (urgency.equals("Work Stopped!"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1.add(ch1);
		p1.add(new Chunk(" Work Stopped!   "));
		if (urgency.equals("As Soon As Possible"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1.add(ch1);
		p1.add(new Chunk(" As Soon As Possible   "));
		if (urgency.equals("At Next Visit"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1.add(ch1);
		p1.add(new Chunk(" At Next Visit   "));
		if (urgency.equals("At Your Convenience"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1.add(ch1);
		p1.add(new Chunk(" At Your Convenience   "));
		cell.add(p1);
		table1.addCell(cell);
		document.add(table1);

		document.add(spacer);
		document.add(spacer);

		table1=new Table(2,3);
		table1.setBorderWidth(1);
		table1.setPadding(3);
		table1.setWidths(colwidths);
		cell=new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorderWidth(0);
		cell.setColspan(2);
		p1 = new Phrase("Please Reply:", new Font(Font.TIMES_ROMAN, 12, Font.BOLD));
		cell.add(p1);
		table1.addCell(cell);

		cell = new Cell();
		cell.setBorderWidth(0);
		cell.add(blank2_5);
		table1.addCell(cell);

		cell = new Cell(new Phrase(reply, new Font(Font.TIMES_ROMAN, 10)));
		cell.setLeading(12);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorderWidth(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorderWidth(0);
		cell.setColspan(2);
		p1 = new Phrase("\n                                                                                               Signed:                                                                          Date:", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		cell.add(p1);
		table1.addCell(cell);
		document.add(table1);

		PdfContentByte cb = writer.getDirectContent();
		Barcode39 code39 = new Barcode39();
		code39.setCode("RF" + rs.getString("rfi_id"));
		code39.setStartStopText(false);
		Image image39 = code39.createImageWithBarcode(cb, null, null);

		image39.setAbsolutePosition(30, 30);;
		document.add(image39);

		int orgPages = writer.getPageNumber();
		
		Attachments.addImageAttachments(rs.getString("rfi_id"), "RF", writer, document);
		
		document.close();

		return Attachments.addPDFAttachmentsAndStamp(rs.getString("rfi_id"), "RF", orgPages, baos.toByteArray());
	}

}
