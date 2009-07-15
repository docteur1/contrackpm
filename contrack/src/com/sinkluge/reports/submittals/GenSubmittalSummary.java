package com.sinkluge.reports.submittals;

import java.awt.Color;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenSubmittalSummary extends Report {

	ResultSet info;
	String job;
	String shortName;
	
	public GenSubmittalSummary(ResultSet info, String job, String shortName){
		this.info = info;
		this.job = job;
		this.shortName = shortName;
	}//constructor
	
	public static String getQuery(int id, String sort) {
		String sql =  "select submittals.job_id, phase_code, submittals.description, submittal_num, attempt, company_name, "
		+ "submittal_type, submittals.date_received, date_to_architect, date_from_architect, submittal_status, "
		+ "cost_code, division, date_to_sub, alt_cost_code from submittals "
		+ "left join contracts using (contract_id) join job_cost_detail on job_cost_detail.cost_code_id = submittals.cost_code_id left join company "
		+ "using (company_id) where submittals.job_id = " + id + " order by " + sort;
		return sql;
	}
 
	public void doCleanup(Database db) {	}
	
	public void create(Info in, Image logo) throws Exception {
		init(PageSize.LETTER.rotate(), -80, -80, 36, 36);
		int count=0;
		String submittal_num, submittal_type, submittal_status, company_name;
		String description, date_received, date_to_architect, date_from_architect, date_to_sub;
		SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy");

		Cell blank = new Cell(new Phrase("", new Font(Font.HELVETICA, 6)));
		blank.setBorder(0);
		Table spacer=new Table(1,1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		spacer.addCell(blank);

		/*
		Table table = new Table(1,1);
		table.setBorder(0);
		table.setPadding(2);
		table.setDefaultCellBorder(0);

		Cell cell = new Cell(new Phrase("Submittals Report- " + job, new Font(Font.TIMES_ROMAN, 16)));
		cell.setBackgroundColor(new Color(191,191,191));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		table.addCell(cell);

		document.add(table);
		*/

		Table table= new Table(12,1);
		table.setBorder(0);
		//table.setDefaultCellBorder(0);
		table.setOffset(0);
		int[] widths2 = {6, 3, 19, 5, 3, 20, 10, 6, 6, 6, 10, 6};
		table.setWidths(widths2);

		Cell cell = new Cell(new Phrase("Submittals:   " + job, new Font(Font.TIMES_ROMAN, 16)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBackgroundColor(new Color(191,191,191));
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setColspan(12);
		table.addCell(cell);

		cell = new Cell(new Phrase("", new Font(Font.TIMES_ROMAN, 6)));
		cell.setBackgroundColor(new Color(191,191,191));
		cell.setColspan(12);
		table.addCell(cell);

		/*
		cell = new Cell(new Phrase(sdf.format(new java.util.Date()), new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("top");
		cell.setHorizontalAlignment("center");
		cell.setColspan(3);
		table.addCell(cell);
		*/

		cell = new Cell(new Phrase("\nCode", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("\nPhase", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("\nDescription", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("Submt'l\nNumber", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("\nTry #", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("\nCompany Name", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("\nSubmittal Type", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("Original\nReceived", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("Forward\nto Arch", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("Returned\nto EPCO", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("Architect\nReview Status", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		cell = new Cell(new Phrase("Returned\nto Sub.", new Font(Font.TIMES_ROMAN, 7)));
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		table.addCell(cell);

		document.add(table);
		Table table1 = new Table(12,1);
		table1.setWidths(widths2);
		table1.setPadding(1);

		int limits=34;
		while(info.next()){
			if (count==limits||(count%(limits+2)==limits&&count>limits)) {
				document.add(table1);
				document.newPage();
				document.add(table);
				table1 = new Table(12,1);
				table1.setWidths(widths2);
				table1.setPadding(1);
			}
			count++;
			submittal_num = info.getString("submittal_num");

			try{ date_received = sdf.format(info.getDate("date_received"));}catch(NullPointerException e){date_received = "---";}
			try{ date_to_architect = sdf.format(info.getDate("date_to_architect"));} catch(NullPointerException e){date_to_architect = "---";}
			try{ date_from_architect = sdf.format(info.getDate("date_from_architect")); } catch(NullPointerException e) {date_from_architect = "---";}
			try{ date_to_sub = sdf.format(info.getDate("date_to_sub"));}catch(NullPointerException e) {date_to_sub = "---";}
			if (date_received.equals("Nov 30, 0002")) date_received = "---";
			if (date_to_architect.equals("Nov 30, 0002")) date_to_architect = "---";
			if (date_from_architect.equals("Nov 30, 0002")) date_from_architect = "---";
			if (date_to_sub.equals("Nov 30, 0002")) date_to_sub = "---";
			submittal_type = info.getString("submittal_type");
			if (submittal_type ==null) submittal_type = "---";
			submittal_status = info.getString("submittal_status");
			if (submittal_status==null)submittal_status="---";
			description = info.getString("description");
			if (description == null) description = "---";
			description = description.replaceAll("\n"," / ");
			description = description.replaceAll("\r","");
			if (description.length()>45) description = description.substring(0,45);
			company_name = info.getString("company_name");
			if (company_name==null) company_name = shortName;
			else if (company_name.length()>45) company_name = company_name.substring(0,45);
			String costCode = info.getString("alt_cost_code");
			if (costCode == null || "".equals(costCode)) costCode = info.getString("division") + " " 
				+ info.getString("cost_code"); 
			cell = new Cell(new Phrase(costCode, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(info.getString("phase_code"), new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(description, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			table1.addCell(cell);
			cell = new Cell(new Phrase(submittal_num, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(info.getString("attempt"), new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(company_name, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			table1.addCell(cell);
			cell = new Cell(new Phrase(submittal_type, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			table1.addCell(cell);
			cell = new Cell(new Phrase(date_received, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(date_to_architect, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(date_from_architect, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
			cell = new Cell(new Phrase(submittal_status, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			table1.addCell(cell);
			cell = new Cell(new Phrase(date_to_sub, new Font(Font.TIMES_ROMAN, 7)));
			cell.setVerticalAlignment("top");
			cell.setHorizontalAlignment("center");
			table1.addCell(cell);
		}
		document.add(table1);

	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}
}
