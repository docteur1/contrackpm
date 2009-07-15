package com.sinkluge.reports.changes;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
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

public class GenChangeRequestSummary extends Report {

	private ResultSet info;
	private String jobName;
	private Date orginal;
	private Date actual;
	private Date subOrginal;
	private Date subActual;
	private double contract;
	private boolean isProjectSummary;

	public void doCleanup(Database db) throws SQLException {
		if (info != null) info.getStatement().close();
		info = null;
	}
	
	public GenChangeRequestSummary(Database db, int jobId, String id) throws Exception {
		String query = "select num, title, co_description, description, sum(amount + fee + bonds) as amount,  days_added, "
			+ "approved_date, date, submit_date, status, result, co_num from change_requests as cr left join "
			+ "change_request_detail as crd using(cr_id) left join change_orders as co using(co_id) where "
			+ "cr.job_id = " + jobId + (id != null ? " and co_id = " + id : "") 
			+ " group by cr.cr_id order by num asc";
		info = db.dbQuery(query);
		isProjectSummary = id == null;
		if (id == null) {
			type = Type.PROJECT;
			this.id = Integer.toString(jobId);
		} else {
			type = Type.CO;
			this.id = id;
		}
		query = "select job_name, end_date, substantial_completion_date, contract_amount_start from job "
			+ "where job_id = " + jobId;
		ResultSet rs = db.dbQuery(query);
		if (rs.first()) {
			jobName = rs.getString("job_name");
			orginal = rs.getDate("end_date");
			subOrginal = rs.getDate("substantial_completion_date");
			contract = rs.getDouble("contract_amount_start");
			if (rs != null) rs.getStatement().close();
			GregorianCalendar cal = new GregorianCalendar ();
			GregorianCalendar subCal = new GregorianCalendar ();
			cal.setTime(orginal);
			subCal.setTime(subOrginal);
			query = "select sum(days_added) as days from change_requests where job_id = " + jobId;
			rs = db.dbQuery(query);
			if (rs.first()) {
				cal.add(Calendar.DAY_OF_YEAR, rs.getInt("days"));
				subCal.add(Calendar.DAY_OF_YEAR, rs.getInt("days"));
			}
			actual = cal.getTime();
			subActual = subCal.getTime();
		}
		if (rs != null) rs.getStatement().close();
		rs = null;
	}//constructor
	
	public void create(Info in, Image logo) throws Exception {
		

		Font tnr = new Font(Font.TIMES_ROMAN, 9);
		Font tnrb = new Font(Font.TIMES_ROMAN, 9, Font.BOLD);
		
		Phrase p = new Phrase(jobName + " Change Request Summary      Page:  ", tnr);
		HeaderFooter footer = new HeaderFooter(p, true);
		footer.setAlignment(Element.ALIGN_CENTER);
		footer.setBorder(Rectangle.NO_BORDER);
		init(PageSize.LETTER.rotate(), footer);

		PdfPCell blank = new PdfPCell(new Phrase("", new Font(Font.HELVETICA, 6)));
		blank.setBorder(0);
		PdfPTable spacer = new PdfPTable(1);
		spacer.addCell(blank);

		PdfPTable table= new PdfPTable(9);
		int[] widths2 = {5, 22, 9, 9, 9, 9, 9, 5, 23};
		table.setWidths(widths2);
		table.setWidthPercentage(100);

		PdfPCell cell;
		
		if (isProjectSummary) 
			cell = new PdfPCell(new Phrase("Change Requests:   " + jobName, new Font(Font.TIMES_ROMAN, 16)));
		else {
			info.first();
			cell = new PdfPCell(new Phrase("Change Order " + info.getString("co_num") + " (" +
				info.getString("co_description") + "):   " + jobName, new Font(Font.TIMES_ROMAN, 16)));
			info.beforeFirst();
		}
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBackgroundColor(new Color(191,191,191));
		cell.setUseDescender(true);
		//cell.setLeading(17);
		cell.setColspan(9);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase("CR #", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Title", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Amount", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Date", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Sent", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Approved", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Status", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("CO #", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Description", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);
		
		table.setHeaderRows(2);

		DecimalFormat df = new DecimalFormat("$#,##0.00");
		
		double amount = 0;
		double daysAdded = 0;
		while(info.next()){
			amount += info.getDouble("amount");
			daysAdded += info.getDouble("days_added");
			
			cell = new PdfPCell(new Phrase(info.getString("num"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("title"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(df.format(info.getDouble("amount")), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(DocHelper.date(info.getDate("date")), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(DocHelper.date(info.getDate("submit_date")),
					tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(DocHelper.date(info.getDate("approved_date")),
					tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("status") + "\n" + info.getString("result"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("co_num"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("description"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			table.addCell(cell);
		}
		document.add(table);
		
		PdfPTable table2 = new PdfPTable(isProjectSummary ? 4 : 3);
		//table2.setWidths(widths3);
		table2.setWidthPercentage(60);
		table2.setSpacingBefore(10);
		
		table2.addCell(" ");
		
		cell = new PdfPCell(new Phrase("Amount", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		table2.addCell(cell);
		
		cell = new PdfPCell(new Phrase(id != null ? "Days Added" : "Completion", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		table2.addCell(cell);
		
		if (isProjectSummary) {
		
			cell = new PdfPCell(new Phrase("Sub Comp", tnrb));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Original", tnrb));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(contract), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(DocHelper.date(orginal), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(DocHelper.date(subOrginal), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table2.addCell(cell);
		
		}
		
		cell = new PdfPCell(new Phrase(!isProjectSummary ? "Total CO" : "Changes", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		table2.addCell(cell);
		
		cell = new PdfPCell(new Phrase(df.format(amount), tnr));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		table2.addCell(cell);
		
		cell = new PdfPCell(new Phrase(daysAdded + " days", tnr));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		table2.addCell(cell);
		
		if (isProjectSummary) {
		
			cell = new PdfPCell(new Phrase(daysAdded + " days", tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Current", tnrb));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(contract + amount), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(DocHelper.date(actual), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(DocHelper.date(subActual), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table2.addCell(cell);
		}
		
		table2.setKeepTogether(true);
		
		document.add(table2);
		
	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}
	
}
