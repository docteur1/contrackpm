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
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenCA extends Report {

	private ResultSet rs = null;
	private ResultSet who = null;
	private String shortName = null;
	private String from = null;

	public void doCleanup(Database db) throws SQLException {
		if (rs != null) rs.getStatement().close();
		rs = null;
		if (who != null) who.getStatement().close();
		who = null;
	}
	
	public ReportContact getReportContact(String id, Database db) throws Exception {
		String query = "select contact_id, company_id from change_request_detail join contracts "
			+ "using(contract_id) where contract_id = " + id;
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
	
	public GenCA(Database db, String crdId, String shortName, String from) throws Exception {
		this.shortName = shortName;
		this.from = from;
		id = crdId;
		type = Type.CRD;
		String sql = "select job_name, job_num, crd.*, cr.*, company_id, contact_id from change_request_detail as crd "
			+ "join job using (job_id) join contracts using(contract_id) left join "
			+ "change_requests as cr using (cr_id) where crd_id = " + crdId;
		rs = db.dbQuery(sql);
		if (rs.first()) {
			sql = "select company_name, name, n.address, n.city, n.state, n.zip, n.fax, n.phone from "
				+ "contacts as n join company as c using(company_id) where contact_id = " + rs.getString("contact_id");
			who = db.dbQuery(sql);
			if (!who.first()) {
				who.getStatement().close();
				sql = "select null as name, company_name, address, city, state, zip, fax, phone from company "
					+ "where company_id = " + rs.getString("company_id");
				who = db.dbQuery(sql);
			}
		}
	}//constructor
	
	public void create(Info in, Image logo) throws Exception {
		init();
		if (rs.first()) {
			Font tnr = new Font(Font.TIMES_ROMAN, 11);
			Font tnrb = new Font(Font.TIMES_ROMAN, 11, Font.BOLD);
			DecimalFormat df = new DecimalFormat("$#,##0.00");
			
			Phrase p = new Phrase(rs.getString("job_name") + " Change Authorization #" 
					+ rs.getString("change_auth_num") + "      Page:  ", tnr);
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
			para.add(new Phrase("\n" + rs.getString("job_num") + "   CA: " + rs.getString("change_auth_num"), 
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
			
			cell = new PdfPCell(new Phrase("CHANGE AUTHORIZATION", new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
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
			
			temp = "Date: " + DocHelper.longDate(rs.getDate("crd.created"));
			temp += "\nPhone: " + who.getString("phone") + "  \nFax: " + who.getString("fax");
			temp += "\n\nFrom: " + from + "\n";
			
			cell = new PdfPCell(new Phrase(temp, tnr));
			cell.setPaddingTop(15);
			cell.setPaddingBottom(15);
			cell.setBorder(0);
			table.addCell(cell);
			
			if (rs.getString("num") != null) {
				cell = new PdfPCell(new Phrase("CR: " + rs.getString("num") + " " + rs.getString("title"),
						new Font(Font.TIMES_ROMAN, 14, Font.BOLD)));
				cell.setPaddingTop(5);
				cell.setColspan(3);
				cell.setPaddingBottom(5);
				cell.setBorder(Rectangle.BOTTOM);
				cell.setBorderWidth(2);
				table.addCell(cell);
			}
			
			cell = new PdfPCell(new Phrase("You are hereby authorized to proceed with the following in strict "
					+ "accordance with all the terms of " + shortName + " Purchase Order or Subcontract Agreement "
					+ "for the " + rs.getString("job_name") + " project:", tnr));
			cell.setPaddingTop(15);
			cell.setColspan(3);
			cell.setPaddingBottom(5);
			cell.setBorderWidthBottom(0.5f);
			if (rs.getString("num") == null) {
				cell.setBorder(Rectangle.BOTTOM | Rectangle.TOP);
				cell.setBorderWidthTop(2);
			} else cell.setBorder(Rectangle.BOTTOM);
			table.addCell(cell);
				
			cell = new PdfPCell(new Phrase(rs.getString("work_description"), tnr));
			cell.setPaddingTop(15);
			cell.setColspan(3);
			cell.setBorder(0);
			table.addCell(cell);
			
			document.add(table);
			
			para = new Paragraph(new Phrase("Contract Change: " + df.format(rs.getDouble("amount")), tnrb));
			para.setSpacingBefore(25);
			
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
			
			cell = new PdfPCell(new Phrase("Accepted by " + who.getString("company_name") + "        Date", tnr));
			cell.setBorder(0);
			table.addCell(cell);
			
			table.addCell(blank);
			
			cell = new PdfPCell(new Phrase("Approved by         Date", tnr));
			cell.setBorder(0);
			table.addCell(cell);
			
			document.add(table);
			
		}
	}
	
}
