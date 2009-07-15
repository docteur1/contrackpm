package com.sinkluge.reports.contracts;

import java.awt.Color;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;

import com.lowagie.text.Cell;
import com.lowagie.text.Chunk;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenContractChecklist extends Report {
	
	String companyName, jobName, agreementDate, currentDate, title, cTitle, shortName;
	boolean insure;
	
	public void doCleanup(Database db) {}
	
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

	public static String getQuery(String id) {
		return "select company_name from company join contracts using (company_id) where contract_id = " + id;
	}
	
	public static String getQuery2(String id) {
		return "select contract_id, site_work, contract_title, contractee_title from cost_types "
			+ "join job_cost_detail on phase_code = letter join contracts using(cost_code_id) "
			+ "where contract_id = " + id;
	}
	
	public GenContractChecklist(String companyName, String jobName, String add, String contract, 
			String contractee, boolean insure, String shortName, String id) {
		this.id = id;
		type = Type.SUBCONTRACT;
		this.companyName = companyName;
		this.jobName = jobName;
		Calendar cal = new GregorianCalendar();
		SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
		currentDate = sdf.format(cal.getTime());
		cal.add(Calendar.DAY_OF_YEAR, Integer.parseInt(add));
		agreementDate = sdf.format(cal.getTime());
		this.title = contract;
		this.cTitle = contractee;
		this.insure = insure;
		this.shortName = shortName;
		
	}//constructor
	
	public void create(Info in, Image toplogo) throws Exception {
	
		//adds the unchecked box
		Image checkbox= Image.getInstance(in.path + "/WEB-INF/images/unchecked.jpg");
		Chunk ch2=new Chunk(checkbox, -10, -10);
		Phrase checkboxPhrase = new Phrase();
		checkboxPhrase.add(ch2);
		int [] two = {10,90};//sets the widths of the columns(2) with checkboxes
		
		
		//blank spacer for keeping tables apart
		Table spacer=new Table(1,1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		Cell blank=new Cell();
		blank.add(new Chunk("", new Font(Font.TIMES_ROMAN, 1, Font.BOLD, new Color(255, 255, 255))));
		blank.setBorderWidth(0);
		blank.setLeading(0);
		spacer.addCell(blank);
		
		init();
		//document.setMargins(left, right, top, bottom);
		//add image
		Phrase p1 = new Phrase();
		int[] widths = {60, 40};
		Table table1=new Table(2,1);
		table1.setWidths(widths);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		toplogo.scalePercent(20);
		//Chunk ch1=new Chunk(toplogo, -10, -80);
		Cell cell=new Cell(toplogo);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);
		//just added image
		
		//add title on right side
		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("\n" + title + " Checklist", new Font(Font.TIMES_ROMAN, 18, Font.BOLD)));
		cell.add(new Phrase("\n" +currentDate, new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		
		//add "To:" and "Re:"
		table1=new Table(1,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		cell=new Cell();
		p1 = new Phrase("To:", new Font(Font.TIMES_ROMAN, 14, Font.BOLD));
		cell.setVerticalAlignment("middle");
		cell.add(p1);
		cell.add(new Phrase("\t\t" + companyName, new Font(Font.TIMES_ROMAN, 14, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Re:", new Font(Font.TIMES_ROMAN, 14, Font.BOLD)));
		cell.add(new Phrase("\t\t" + jobName, new Font(Font.TIMES_ROMAN, 14, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Enclosed:", new Font(Font.TIMES_ROMAN, 14, Font.BOLD)));
		cell.add(new Phrase("\t\t" + title + " Agreement", new Font(Font.TIMES_ROMAN, 14, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		document.add(spacer);
		
		
		//add Instructions
		table1=new Table(1,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		cell=new Cell();
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("In order to finalize your agreement with " + shortName + ", please complete all items as outlined below. "
				+ " It is essential to be finalized no later than ", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.add(new Phrase(agreementDate+".  ", new Font(Font.TIMES_ROMAN, 12, Font.BOLDITALIC)));
		cell.setBorder(0); table1.addCell(cell);
		//p1 = new Phrase("Subcontractor Change Order Overview Report", new Font(Font.TIMES_ROMAN, 8, Font.BOLD));
		cell = new Cell();
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("A subcontract is considered finalized and ready to activate when all of the attached items outlined below "
				+ "are completed, signed, and returned to " + shortName + ". Do not make any changes directly to the contract documents."
				+ " Any alterations or amendments must be negotiated and mutually agreed upon in advance. If necessary, a new, "
				+ "updated contract will be sent. Contract negotiations are best in person and can be accomplished following the pre-"
				+ "construction conference.", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		document.add(spacer);
		
		//add "Checklist:"
		table1=new Table(1,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		cell=new Cell();
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Checklist: ", new Font(Font.TIMES_ROMAN, 12, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		//add "Business Information"
		table1=new Table(2,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidths(two);
		
		cell=new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setBorder(0); table1.addCell(cell);
		
		cell=new Cell();
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Business Information", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.add(new Phrase(" (* indicates required information)", new Font(Font.TIMES_ROMAN, 12, Font.ITALIC)));
		
		cell.add(new Phrase("\n     * Business Telephone Number", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("\n        Primary Contact Name", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("\n        Business Fax Number", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("\n        Mobile Telephone Number", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("\n        Email Address", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("\n     * Federal ID # or Social Security Number", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		if (insure) {
			cell.add(new Phrase("\n     * Contractor's License Number", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
			cell.add(new Phrase("\n     * Attach copy of current contractor's license", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		}
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		//add "Sign and Date the Agreement"
		table1=new Table(2,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidths(two);
		
		cell=new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);
		
		cell=new Cell();
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Sign and date the agreement", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		
		document.add(table1);
		
		//add "initial all pages"
		table1=new Table(2,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidths(two);
		
		cell=new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);
		
		cell=new Cell();
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Initial front page where indicated", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		
		document.add(table1);
		
		//add "provide signatures"
		table1=new Table(2,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidths(two);
		
		cell=new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);
		
		cell=new Cell();
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Provide appropriate signatures at Exhibit \"C\", Item #2", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		
		document.add(table1);
		
		//add "complete and sign exhibit d"
		if (insure) {
			table1=new Table(2,1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(3);
			table1.setWidths(two);
			
			cell=new Cell(checkboxPhrase);
			cell.setBorderWidth(0);
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			cell.setBorder(0); table1.addCell(cell);
			
			cell=new Cell();
			cell.setVerticalAlignment("bottom");
			cell.add(new Phrase("Complete and sign Exhibit \"D\"", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			
			document.add(table1);
			
			//add "Forward"
			table1=new Table(2,1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(3);
			table1.setWidths(two);
			
			cell=new Cell(checkboxPhrase);
			cell.setBorderWidth(0);
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			cell.setBorder(0); table1.addCell(cell);
			
			cell=new Cell();
			cell.setVerticalAlignment("bottom");
			cell.add(new Phrase("Forward the required insurance certificates (per article 7 and Exhibit \"C\") to " + shortName, new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			
			document.add(table1);
		}
		
		//add "return all pages"
		table1=new Table(2,1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidths(two);
		
		cell=new Cell(checkboxPhrase);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);
		
		cell=new Cell();
		cell.setVerticalAlignment("bottom");
		cell.add(new Phrase("Return all pages of both completed copies of your " + title + " agreement.  Do not remove any pages.", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		
		document.add(table1);
		
	}
}
