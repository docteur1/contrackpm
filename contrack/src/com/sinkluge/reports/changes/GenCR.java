package com.sinkluge.reports.changes;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;

import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.User;
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenCR extends Report {

	private ResultSet rs = null;
	private ResultSet who = null;
	private ResultSet rsd = null;
	private String shortName = null;

	public void doCleanup(Database db) throws SQLException {
		if (rs != null) rs.getStatement().close();
		rs = null;
		if (who != null) who.getStatement().close();
		who = null;
		if (rsd != null) rsd.getStatement().close();
		rsd = null;
	}
	
	public ReportContact getReportContact(String id, Database db) throws Exception {
		String query = "select contact_id, company_id from change_requests join job_contacts on "
			+ "to_id = job_contact_id where cr_id = " + id;
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
	
	public GenCR(Database db, String crId, String shortName) throws Exception {
		String sql = "select job_name, job_num, cr.* from change_requests as cr join job using (job_id) "
			+ "where cr_id = " + crId;
		id = crId;
		type = Type.CR;
		rs = db.dbQuery(sql);
		this.shortName = shortName;
		if (rs.first()) {
			sql = "select company_name, name, n.address, n.city, n.state, n.zip, n.fax, n.phone from "
				+ "contacts as n join job_contacts as jc using(contact_id) join company as c on jc.company_id "
				+ "= c.company_id where jc.job_contact_id = " + rs.getString("to_id");
			who = db.dbQuery(sql);
			if (!who.first()) {
				who.getStatement().close();
				sql = "select null as name, company_name, address, city, state, zip, fax, phone from company "
					+ "join job_contacts using(company_id) where job_contact_id = " + rs.getString("to_id");
				who = db.dbQuery(sql);
			}
			sql = "select company_name, crd.* from change_request_detail as crd left join contracts "
				+ "using(contract_id) left join company using(company_id) where cr_id = " + crId
				+ " order by company_name";
			rsd = db.dbQuery(sql);
		}
	}//constructor
	
	public void create(Info in, Image logo) throws Exception {
		if (rs.first()) {
			init();
			Font tnr = new Font(Font.TIMES_ROMAN, 11);
			Font tnrb = new Font(Font.TIMES_ROMAN, 11, Font.BOLD);
			DecimalFormat df = new DecimalFormat("$#,##0.00");
			
			Phrase p = new Phrase(rs.getString("job_name") + " Change Request #" + rs.getString("num") 
					+ "      Page:  ", tnr);
			HeaderFooter footer = new HeaderFooter(p, true);
			footer.setAlignment(Element.ALIGN_CENTER);
			footer.setBorder(Rectangle.NO_BORDER);
			document.setFooter(footer);
			
			document.open();
			
			PdfPTable table = new PdfPTable(3);
			int[] wTop = {55, 5, 40};
			table.setWidths(wTop);
			logo.scalePercent(20);
			table.setWidthPercentage(100);
			
			PdfPCell blank = new PdfPCell(new Phrase(" "));
			blank.setBorder(0);			
			
			PdfPCell cell = new PdfPCell(logo);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setBorder(0);
			table.addCell(cell);
			
			table.addCell(blank);
			
			Paragraph para = new Paragraph(new Phrase(rs.getString("job_name"), new Font(Font.TIMES_ROMAN, 14)));
			para.add(new Phrase("\n" + rs.getString("job_num") + "   CR: " + rs.getString("num"), 
					new Font(Font.TIMES_ROMAN, 12)));
			cell = new PdfPCell(para);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setBorder(0);
			table.addCell(cell);
			
			table.setSpacingAfter(7);
			
			document.add(table);
			
			table = new PdfPTable(3);
			int[] wTitle = {60, 5, 35};
			table.setWidths(wTitle);
			table.setWidthPercentage(100);
			
			cell = new PdfPCell(new Phrase("CHANGE REQUEST", new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
			cell.setColspan(3);
			cell.setBackgroundColor(new Color(191, 191, 191));
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);
			cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
			cell.setBorder(0);
			cell.setPaddingBottom(8);
			table.addCell(cell);
			
			// Add the address information...
			String temp = "ERROR";
			if (who.first()) {
				temp = who.getString("name");
				if (temp == null) temp = who.getString("company_name");
				else temp += "\n" + who.getString("company_name");
				temp += "\n" + who.getString("address");
				temp += "\n" + who.getString("city") + ", " + who.getString("state") + " " + who.getString("zip");
				//temp += "\nPhone: " + who.getString("phone") + "  Fax: " + who.getString("fax");
			}
			
			cell = new PdfPCell(new Phrase(temp, tnr));
			cell.setPaddingTop(15);
			cell.setPaddingBottom(5);
			cell.setBorder(0);
			table.addCell(cell);
			
			table.addCell(blank);
			
			temp = "Date: " + DocHelper.longDate(rs.getDate("date"));
			temp += "\nPhone: " + who.getString("phone") + "  \nFax: " + who.getString("fax");
			User user = User.getUser(rs.getInt("signed_id"));
			
			temp += "\n\nFrom: " + (user != null ? user.getFullName() : "Unknown"); 
			
			cell = new PdfPCell(new Phrase(temp, tnr));
			cell.setPaddingTop(15);
			cell.setPaddingBottom(5);
			cell.setBorder(0);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(rs.getString("title"), new Font(Font.TIMES_ROMAN, 14, Font.BOLD)));
			cell.setPaddingTop(15);
			cell.setColspan(3);
			cell.setPaddingBottom(5);
			cell.setBorder(Rectangle.BOTTOM);
			cell.setBorderWidth(2);
			table.addCell(cell);
			
			
			cell = new PdfPCell(new Phrase("We request your approval to perform the work or issue a change "
					+ "authorization to the appropriate subcontractor(s) for the following:", tnr));
			cell.setPaddingTop(15);
			cell.setColspan(3);
			cell.setPaddingBottom(5);
			cell.setBorder(Rectangle.BOTTOM);
			cell.setBorderWidth(0.5f);
			table.addCell(cell);
				
			cell = new PdfPCell(new Phrase(rs.getString("description"), tnr));
			cell.setPaddingTop(15);
			cell.setColspan(3);
			cell.setBorder(0);
			table.addCell(cell);
			
			document.add(table);
			
			table = new PdfPTable(4);
			int[] wBody = {5, 35, 50, 15};
			table.setWidths(wBody);
			table.setWidthPercentage(100);
			table.setSpacingBefore(30);
			
			double amount = 0, fee = 0, bonds = 0;
			
			while (rsd.next()) {
				table.addCell(blank);
				
				temp = rsd.getString("company_name");
				
				cell = new PdfPCell(new Phrase(temp == null ? shortName : temp, tnr));
				cell.setPaddingBottom(3);
				cell.setBorder(0);
				table.addCell(cell);
				
				cell = new PdfPCell(new Phrase(rsd.getString("work_description"), tnr));
				cell.setPaddingBottom(3);
				cell.setBorder(0);
				table.addCell(cell);
				
				amount += rsd.getDouble("amount");
				fee += rsd.getDouble("fee");
				bonds += rsd.getDouble("bonds");
				
				cell = new PdfPCell(new Phrase(df.format(rsd.getDouble("amount")), tnr));
				cell.setPaddingBottom(3);
				cell.setBorder(0);
				cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
				table.addCell(cell);
			}
			
			cell = new PdfPCell(new Phrase("Subtotal", tnrb));
			cell.setColspan(3);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setPaddingBottom(3);
			cell.setPaddingTop(10);
			cell.setBorder(0);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(amount), tnr));
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			cell.setPaddingTop(10);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Fees", tnrb));
			cell.setColspan(3);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(fee), tnr));
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Bonds", tnrb));
			cell.setColspan(3);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(bonds), tnr));
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase("TOTAL", tnrb));
			cell.setColspan(3);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(amount + fee + bonds), tnrb));
			cell.setPaddingBottom(3);
			cell.setBorder(0);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table.addCell(cell);
			
			document.add(table);
			
			para = new Paragraph("Contract time will increase by " + rs.getString("days_added") + " days.", tnr);
			
			document.add(para);
			
			table = new PdfPTable(3);
			int[] wFooter = {47, 6, 47};
			table.setWidths(wFooter);
			table.setWidthPercentage(100);
			table.setSpacingBefore(40);
			
			cell = new PdfPCell(new Phrase(" "));
			cell.setBorder(Rectangle.BOTTOM);
			table.addCell(cell);
			
			table.addCell(blank);
			
			cell = new PdfPCell(new Phrase(" "));
			cell.setBorder(Rectangle.BOTTOM);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Architect/Owner Signature         Date", tnr));
			cell.setBorder(0);
			table.addCell(cell);
			
			table.addCell(blank);
			
			cell = new PdfPCell(new Phrase(shortName + " Project Manager         Date", tnr));
			cell.setBorder(0);
			table.addCell(cell);
			
			document.add(table);
		}
	}
	
}
