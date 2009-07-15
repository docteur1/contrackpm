package com.sinkluge.reports.transmittals;

import java.awt.Color;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.lowagie.text.Chunk;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenTransmittal extends Report {
	ResultSet info;
	String jobName;

	public void doCleanup(Database db) {}
	
	public ReportContact getReportContact(String id, Database db) throws Exception {
		String query = "select contact_id, company_id from transmittal where id = " + id;
		ResultSet rs = null;
		ReportContact rp = new ReportContact();
		rs = db.dbQuery(query);
		if (rs.next()) {
			if (rs.getInt(1) != 0) {
				rp.setContactId(rs.getInt(1));
				rp.setCompanyId(rs.getInt(2));
			} else rp.setCompanyId(rs.getInt(2)); 
		}

		if (rs != null) rs.getStatement().close();
		rs = null;
		return rp;
	}
	
	public static String getQuery(String id) {
		return "select t.*, c.*, n.*, u.first_name, u.last_name from transmittal as t join users as u "
			+ "on t.user_id = u.id left join company as c on "
			+ "t.company_id = c.company_id left join contacts as n using(contact_id) where t.id = " + id;
	}
	
	
	public GenTransmittal(ResultSet info, String jobName){
		this.info = info;
		this.jobName = jobName;
		type = Type.TRANSMITTAL;
	}//constructor
	
	public void create(Info in, Image toplogo) throws Exception {
		init(15, 15, 36, 36);
		info.next();
		id = info.getString("id");
		Font tnr10 = new Font(Font.TIMES_ROMAN, 10, Font.NORMAL);
		Font tnr14 = new Font(Font.TIMES_ROMAN, 12, Font.NORMAL);
		toplogo.scalePercent(20);
		Image checked= Image.getInstance(in.path + "/jsp/images/checked.jpg");
		Image unchecked= Image.getInstance(in.path + "/jsp/images/unchecked.jpg");
		Image blank1_0 = Image.getInstance(in.path + "/jsp/images/blank1_0.jpg");
		blank1_0.scalePercent(85);
		SimpleDateFormat sdf = new SimpleDateFormat("E MMM d yyyy   h:mm a");
		int[] colwidths2={45, 55};
		int[] colwidths4={45, 35, 20};

		PdfPTable table1=new PdfPTable(3);
		//table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		int[] widths = {60,2,40};
		table1.setWidths(widths);
		Chunk ch1 = null; //new Chunk(toplogo, -10, -60);
		Phrase p1 = null; // new Phrase();
		//p1.setLeading(8);
		//p1.add(ch1);
		PdfPCell cell=new PdfPCell(toplogo);
		cell.setBorder(0);
		cell.setHorizontalAlignment(Element.ALIGN_CENTER);
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		table1.addCell(cell);

		cell = new PdfPCell(blank1_0);
		cell.setBorder(0);
		//cell.add();
		table1.addCell(cell);


		//int jobNum = info.getInt("job_num");
		String attachment_desc = info.getString("description");
		if (jobName == null || info.getBoolean("my")) jobName = "";
		if (attachment_desc == null) attachment_desc = "None";
		Paragraph prgh = new Paragraph(new Phrase(jobName + "\n",new Font(Font.TIMES_ROMAN, 16, Font.NORMAL)));
		p1 = new Phrase("\n" + sdf.format(info.getTimestamp("t.created")), new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		prgh.add(p1);
		cell=new PdfPCell(prgh);
		cell.setBorder(0);
		cell.setHorizontalAlignment(Element.ALIGN_CENTER);
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		table1.addCell(cell);

		document.add(table1);

		//spacer table
		PdfPTable spacer=new PdfPTable(1);
		//spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		//spacer.setPadding(0);
		//spacer.setSpacing(0);
		PdfPCell cellblank=new PdfPCell(new Phrase("", new Font(Font.TIMES_ROMAN, 1, Font.BOLD)));
		//cellblank.add();
		cellblank.setBorderWidth(0);
		//cellblank.setLeading(0);
		spacer.addCell(cellblank);
		document.add(spacer);

		//title bar and Addressing
		table1=new PdfPTable(3);
		//table1.setPadding(2);
		//table1.setSpacing(2);
		//table1.setBorder(0);
		table1.setWidths(colwidths4);
		//table1.setDefaultCellBorder(0);
		//table1.setDefaultCellBorderWidth(0);
		cell = new PdfPCell(new Phrase("LETTER OF TRANSMITTAL", new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell.setBackgroundColor(new Color(191, 191, 191));
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		cell.setHorizontalAlignment(Element.ALIGN_CENTER);
		cell.setColspan(3);
		cell.setUseDescender(true);
		//cell.setLeading(17);
		cell.setBorder(0);
		table1.addCell(cell);
		int pages = info.getInt("pages");
		
		String companyName;
		String name;
		String address;
		String city;
		String state;
		String zip;
		String phone;
		String fax;
		
		if (info.getString("company_id") == null) { 
			companyName = info.getString("t.company_name");
			name = info.getString("attn");
			address = info.getString("t.address");
			city = info.getString("t.city");
			state = info.getString("t.state");
			zip = info.getString("t.zip");
			phone = info.getString("t.phone");
			fax = info.getString("t.fax");
		} else {
			companyName = info.getString("c.company_name");
			name = info.getString("name");
			if (info.getString("contact_id") == null) {
				address = info.getString("c.address");
				city = info.getString("c.city");
				state = info.getString("c.state");
				zip = info.getString("c.zip");
				phone = info.getString("c.phone");
				fax = info.getString("c.fax");
			} else {
				address = info.getString("n.address");
				city = info.getString("n.city");
				state = info.getString("n.state");
				zip = info.getString("n.zip");
				phone = info.getString("n.phone");
				fax = info.getString("n.fax");
			}
		}

		if (address == null) address = "";
		if (city == null) city = "";
		if (state == null) state = "";
		if (zip == null) zip = "";
		if (phone == null) phone = "";
		if (fax == null) fax = "";
		if (name == null) name = "";
		String user = info.getString("first_name") + " " + info.getString("last_name");
		if (user == null) user = "";
		sdf.applyPattern("MMddyyyy");
		Date temp = info.getDate("respond_by");
		String respond_by = "";
		if (temp == null) respond_by = "";
		else {
			sdf.applyPattern("EEE MMM d, yyyy");
			respond_by = "RESPOND BY: " + sdf.format(temp);
		}

		p1 = new Phrase(companyName + "\n" + address + "\n" + city + ", " + state + " " + zip + "\n\nPhone:   " + phone + "\t\tFax:   " + fax, new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
		//p1.setLeading(16);
		cell = new PdfPCell(p1);
		cell.setBorder(0);
		cell.setPaddingTop(15);
		table1.addCell(cell);

		cell = new PdfPCell(new Phrase("Attention:\n" + name + "\n\nFrom:\n" + user, tnr10));
		cell.setBorder(0);
		cell.setPaddingTop(15);
		table1.addCell(cell);

		if (pages != 0) {
			cell = new PdfPCell(new Phrase("Total Pages:\n" + pages, tnr10));
			cell.setBorder(0);
			cell.setPaddingTop(15);
			table1.addCell(cell);
		} else table1.addCell(cellblank);
		//table1.complete();

		document.add(table1);

		//document.add(spacer);
		//document.add(spacer);
		//document.add(spacer);

		//"The following items are:" with a whole lot of checkboxes
		table1=new PdfPTable(4);
		table1.setSpacingBefore(15);
		//table1.setBorderWidth(0);
		//table1.setDefaultCellBorderWidth(0);
		//table1.setDefaultColspan(1);

		p1=new Phrase("THE FOLLOWING ITEMS ARE", tnr10);
		cell = new PdfPCell(p1);
		cell.setHorizontalAlignment(Element.ALIGN_LEFT);
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		cell.setColspan(2);
		cell.setBorderWidth(0);
		cell.setPaddingBottom(8);
		table1.addCell(cell);



		//if(respond_by == null) p1=new Phrase("", tnr10);
		//else p1=new Phrase("RESPOND BY: " + sdf.format(respond_by), tnr10);
		p1=new Phrase(respond_by, tnr10);
		cell = new PdfPCell(p1);
		cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		cell.setColspan(2);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		//first row
		String sending = info.getString("attachments");
		if (sending==null) sending = "";
		if (sending.equals("Attached"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Attached", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (sending.equals("Under Separate Cover"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Under Separate Cover", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (sending.equals("Prints/Plans"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Prints/Plans", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (sending.equals("Shop Drawings"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Shop Drawings", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		//second row
		if (sending.equals("Copy Of Letter"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Copy of Letter", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (sending.equals("Samples"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Samples", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (sending.equals("Specifications"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Specifications", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (sending.equals("Submittals"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Submittals", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		//third row
		if (sending.equals("Change Order"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Change Order", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);


		if (sending.equals("Other"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Other", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		cell.setColspan(3);
		table1.addCell(cell);

		if(!attachment_desc.equals("")){
			prgh = new Paragraph(new Phrase("\nDetails: ",new Font(Font.TIMES_ROMAN,10,Font.BOLD)));
			prgh.add(new Phrase(attachment_desc, tnr10));
			cell = new PdfPCell(prgh);
			cell.setBorderWidth(0);
			cell.setColspan(4);
			table1.addCell(cell);
		}

		document.add(table1);//end checkboxes



		//document.add(spacer);

		//another round of checkboxes
		String whatfor = info.getString("purpose");
		if (whatfor == null) whatfor = "";
		table1 = new PdfPTable(3);
		table1.setSpacingBefore(15);
		//table1.setBorderWidth(0);
		p1=new Phrase("TRANSMITTED AS FOLLOWS", tnr10);
		cell = new PdfPCell(p1);
		cell.setColspan(3);
		cell.setBorderWidth(0);
		cell.setPaddingBottom(8);
		table1.addCell(cell);

		//first row
		if (whatfor.equals("For Your Use"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  For Your Use", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Approved as Submitted"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Approved as Submitted", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Returned corrected"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Returned corrected ____ prints", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		//second row
		if (whatfor.equals("For Your Approval"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  For Your Approval", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Approved As Noted"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Approved As Noted", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Amend & resubmit"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Amend & resubmit ____ copies", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		//third row
		if (whatfor.equals("For Review And Comment"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  For review & comment", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("To Be Resubmitted"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  To Be Resubmitted", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Rejected resubmit"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Rejected resubmit ____ copies", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		//fourth row
		if (whatfor.equals("Per Your Request"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Per Your Request", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Submit copies"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Submit ____ copies for dist.", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		if (whatfor.equals("Other"))ch1=new Chunk(checked, 0, 0);
		else ch1=new Chunk(unchecked, 0, 0);
		p1 = new Phrase(ch1);
		p1.add(new Chunk("  Other__________________", tnr10));
		cell = new PdfPCell(p1);
		cell.setBorderWidth(0);
		table1.addCell(cell);

		document.add(table1);                   //end of second round of checkboxes

		//document.add(spacer);
		//document.add(spacer);

		table1=new PdfPTable(2);
		table1.setSpacingBefore(20);
		//table1.setBorderWidth(1);
		//table1.setPadding(3);
		colwidths2[0]=2;
		colwidths2[1]=98;
		table1.setWidths(colwidths2);
		p1 = new Phrase("REMARKS:", new Font(Font.TIMES_ROMAN, 12, Font.BOLD));
		cell=new PdfPCell(p1);
		cell.setHorizontalAlignment(Element.ALIGN_LEFT);
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		cell.setBorderWidth(1);
		cell.setBorder(Rectangle.LEFT | Rectangle.RIGHT | Rectangle.TOP);
		cell.setColspan(2);
		cell.setPadding(2);
		table1.addCell(cell);

		cell = new PdfPCell(new Phrase(""));
		cell.setFixedHeight(240);
		cell.setBorder(Rectangle.LEFT);
		cell.setBorderWidth(1);
		table1.addCell(cell);

		String remarks =info.getString("remarks");
		if (remarks!=null && !remarks.equals(""))	p1 = new Phrase(remarks, tnr10);
		else {
			p1 = new Phrase("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________", tnr14);
		}
		cell = new PdfPCell(p1);
		cell.setHorizontalAlignment(Element.ALIGN_LEFT);
		cell.setVerticalAlignment(Element.ALIGN_TOP);
		cell.setBorderWidth(1);
		cell.setBorder(Rectangle.RIGHT);
		cell.setPaddingRight(10);
		table1.addCell(cell);
		p1 = new Phrase("Signed:                                                                                               Date:", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		cell = new PdfPCell(p1);
		cell.setHorizontalAlignment(Element.ALIGN_LEFT);
		cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
		cell.setBorderWidth(1);
		cell.setBorder(Rectangle.LEFT | Rectangle.RIGHT | Rectangle.BOTTOM);
		cell.setUseDescender(true);
		cell.setColspan(2);
		table1.addCell(cell);
		document.add(table1);

	}


}
