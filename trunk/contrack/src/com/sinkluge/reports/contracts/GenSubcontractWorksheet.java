package com.sinkluge.reports.contracts;

/*
 This file generates the form for subcontractors to submit a monthly payment request.
 it's in the subcontracts section.
 */
import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Vector;

import com.lowagie.text.Cell;
import com.lowagie.text.Chunk;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

//import com.joe.db.*;

public class GenSubcontractWorksheet extends Report {
	
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
	
	Vector<String> submittalVector = new Vector<String>();
	
	String jobName, shortName;
	
	String agreementDate = "<agreement date goes here>";
	
	String contract_id;
	
	ResultSet contractRS;
	
	ResultSet companyRS;
	
	ResultSet jobRS;
	
	ResultSet ownerRS;
	
	ResultSet architectRS;
	
	ResultSet submittalRS;
	
	ResultSet rs;
	
	SimpleDateFormat formatter = new SimpleDateFormat("EEEEEEEEE, MMM dd, yyyy");
	
	DecimalFormat df = new DecimalFormat("$###,###,###.00");
	
	String costCodeID = "None";
	
	String subName = "<subcontractor name>";
	
	String subAddress = "<sub address>";
	
	String subCityStateZip = "< sub city, state zip>";
	
	String projectName = "<project name>";
	
	String projectAddress = "<project address>";
	
	String projectCityStateZip = "< project city, state zip>";
	
	String reqOwnerTraining = "n";
	
	String reqTechSubmittals = "n";
	
	String reqWarranty = "n";
	
	String reqSpecialty = "";
	
	String customNotes = "";
	
	String ownerName = "<owner name>";
	
	String ownerAddress = "<owner address>";
	
	String ownerCityStateZip = "< owner city, state zip>";
	
	String telephone = "<telephone>";
	
	String fax = "<fax>";
	
	String mobile_phone = "<mobile_phone>";
	
	String email = "<email>";
	
	//String amount = "<contract amount>";
	double amount = 123456.05;
	
	String amountString = "<contract amount to string>";
	
	String contractDescription = "<description goes here.>";
	
	private void evaluateVariables() throws SQLException {
		if (contractRS.next()) {
			java.util.Date d = contractRS.getDate("agreement_date");
			if (!(d == null)) {
				agreementDate = formatter.format(d);
			} else {
				agreementDate = "(no agreement date yet)";
			}
			contractDescription = contractRS.getString("description");
			amount = (double) contractRS.getFloat("amount");
			costCodeID = Long.toString(contractRS.getLong("cost_code_id"));
			reqOwnerTraining = contractRS.getString("req_owner_training");
			reqTechSubmittals = contractRS.getString("req_tech_submittals");
			reqWarranty = contractRS.getString("req_warranty");
			reqSpecialty = contractRS.getString("req_specialty");
			if (reqSpecialty == null)
				reqSpecialty = "";
			
			customNotes = contractRS.getString("tracking_notes");
		}
		
		if (ownerRS.next()) {
			ownerName = ownerRS.getString("company_name");
		}
		if (companyRS.next()) {
			subName = companyRS.getString("company_name");
			subName += companyRS.getString("name")!=null?"\n" + companyRS.getString("name"):"";
			subAddress = companyRS.getString("contacts.address");
			if (subAddress == null) subAddress = companyRS.getString("company.address");
			subCityStateZip = companyRS.getString("contacts.city") + ", " + companyRS.getString("contacts.state") + "   " + companyRS.getString("contacts.zip");
			if (companyRS.getString("contacts.city") == null) subCityStateZip = companyRS.getString("company.city") + ", " + companyRS.getString("company.state") + "   " + companyRS.getString("company.zip");
			telephone = companyRS.getString("contacts.phone");
			if (telephone==null) telephone = companyRS.getString("company.phone");
			if (telephone== null) telephone = "";
			fax = companyRS.getString("contacts.fax");
			if (fax==null) fax = companyRS.getString("company.fax");
			if (fax == null) fax = "";
			mobile_phone = companyRS.getString("contacts.mobile_phone");
			if (mobile_phone == null) mobile_phone="";
			email = companyRS.getString("contacts.email");
			if (email == null) email="";
		}
		if (jobRS.next()) {
			projectName = jobRS.getString("job_name");
			jobName = projectName;
			projectAddress = jobRS.getString("address");
			projectCityStateZip = jobRS.getString("city") + ", "
			+ jobRS.getString("state") + "   " + jobRS.getString("zip");
		}
		while (submittalRS.next()) {
			submittalVector.addElement(submittalRS.getString("description"));
		}
		
	}

	public void doCleanup(Database db) throws SQLException {
		if (contractRS != null) contractRS.getStatement().close();
		contractRS = null;
		if (companyRS != null) companyRS.getStatement().close();
		companyRS = null;
		if (jobRS != null) jobRS.getStatement().close();
		jobRS = null;
		if (ownerRS != null) ownerRS.getStatement().close();
		ownerRS = null;	
		if (rs != null) rs.getStatement().close();
		rs = null;
		if (submittalRS != null) submittalRS.getStatement().close();
		submittalRS = null;
	}
	
	public GenSubcontractWorksheet(String contract_id, Database db, String shortName) throws Exception {
		this.contract_id = contract_id;
		id = contract_id;
		type = Type.SUBCONTRACT;
		this.shortName = shortName;
		this.companyRS = db.dbQuery("select company.*, contacts.* from contracts join company on "
				+ "contracts.company_id = company.company_id left join contacts using(contact_id) where "
				+ "contract_id = " + contract_id);
		this.ownerRS = db.dbQuery("select company.*, contacts.* from contracts join job_contacts on job_contacts.job_id = "
				+ "contracts.job_id join company on job_contacts.company_id = company.company_id left join contacts on "
				+ "job_contacts.contact_id = contacts.contact_id where contract_id = " + contract_id + " and "
				+ "job_contacts.isDefault = 1 and job_contacts.type = 'Owner'");
		this.jobRS = db.dbQuery("select job_name, address, city, state, zip, bid_documents from job join "
				+ "contracts using(job_id) where contract_id = " + contract_id);
		rs = db.dbQuery("select contract_title, contractee_title from contracts join job_cost_detail "
				+ "using(cost_code_id) join job on contracts.job_id = job.job_id join cost_types on "
				+ "phase_code = letter and job.site_id = cost_types.site_id  where contract_id = "
				+ contract_id);
		this.contractRS = db.dbQuery("select * from contracts where contract_id = " + contract_id);
		submittalRS = db.dbQuery("select description from submittals where contract_id = " + contract_id);
		evaluateVariables();
		doCleanup(db);
	}//constructor
	
	public void create(Info in, Image logo) throws Exception {
		init();
		int[] fourA = { 20, 5, 45, 30 };
		int[] fourB = { 45, 5, 45, 5 };
		int[] fourC = { 25, 10, 20, 45 };
		
		//blank spacer for keeping tables apart
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
		
		//start of document
		//document.setFooter(footer);
		
		//add image
		Table table1 = new Table(2, 1);

		document.add(spacer);
		
		table1 = new Table(1, 1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidth(100);
		Cell cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(projectName, new Font(Font.TIMES_ROMAN, 20,
				Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		table1 = new Table(4, 1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(fourA);
		table1.setPadding(0);
		table1.setOffset(4);
		table1.setWidth(100);
		//table1.setSpacing(2)
		
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Company:", new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(" "));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(subName + "\n" + subAddress + "\n"
				+ subCityStateZip,
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(8);
		cell.add(new Phrase("Phone: " + telephone + "\nFax: " + fax
				+ "\nMobile: " + mobile_phone + "\nPager:\nEmail: " + email
				+ "\n", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Contract Amount:", new Font(Font.TIMES_ROMAN,
				10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(df.format(amount), new Font(Font.TIMES_ROMAN,
				10, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		//document.add(spacer);
		
		table1 = new Table(1, 1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setSpacing(0);
		table1.setOffset(12);
		table1.setWidth(100);
		cell = new Cell(new Phrase(
				"Scope of Work / Contract Description\n", new Font(
						Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setBorder(Rectangle.TOP);
		cell.setBorderWidth(0.5f);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		//cell= new Cell();
		//cell.setHorizontalAlignment("left");
		//cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		Phrase p = new Phrase("\n" + contractDescription + "\n", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL));
		p.setLeading(10);
		document.add(p);
		//cell.setBorder(0); table1.addCell(cell);
		//document.add(table1);
		
		table1 = new Table(4, 1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(fourC);
		table1.setPadding(1);
		table1.setSpacing(1);
		table1.setWidth(100);
		table1.setOffset(6);
		table1.setTableFitsPage(true);
		cell = new Cell();
		cell.setColspan(4);
		if (!submittalVector.isEmpty()) {
			cell.add(new Phrase("Requested Submittals:\n", new Font(
					Font.TIMES_ROMAN, 10, Font.BOLD)));
			for (int i = 0; i < submittalVector.size(); i++) {
				cell
				.add(new Phrase((String) submittalVector
						.elementAt(i)
						+ "\n", new Font(Font.TIMES_ROMAN, 10,
								Font.NORMAL)));
			}
		} else {
			cell
			.add(new Phrase(
					"\nSubmittals required per contract documents and specifications.\n",
					new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		}
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(new Phrase("\nClose Out Requirements:", new Font(
				Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setColspan(4);
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase("Req Owner Training:", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase(reqOwnerTraining.equals("n") ? "No"
				: "Yes", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase("Req Specialty:", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase(reqSpecialty, new Font(Font.TIMES_ROMAN,
				10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase("Req Tech Submittals:", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase(reqTechSubmittals.equals("n") ? "No"
				: "Yes", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase("Custom Notes:", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase(customNotes, new Font(Font.TIMES_ROMAN,
				10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase("Req Warranty:", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(1);
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);
		
		cell = new Cell(new Phrase(reqWarranty.equals("n") ? "No" : "Yes",
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setColspan(3);
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		table1 = new Table(1, 1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(1);
		table1.setSpacing(1);
		table1.setWidth(100);
		cell = new Cell(
				new Phrase(
						"\nMost contracts (especially design build) require some "
						+ shortName
						+ " help:  layout, unloading equipment, touching up or cleaning, etc.  These costs should be added to the low bid as presented to the owner.\n",
						new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		table1 = new Table(4, 1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(fourB);
		table1.setPadding(2);
		//table1.setSpacing(2);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Rental Equipment:", new Font(Font.TIMES_ROMAN,
				8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Temp Water:", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Operator/Laborer:", new Font(Font.TIMES_ROMAN,
				8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Other:", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Construction Prep.:", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Other:", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Contractor Provided Materials:", new Font(Font.TIMES_ROMAN,
				8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Other:", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Shoring or Bracing:", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Other:", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Temp Heat or Power:", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.BOTTOM);
		cell.add(new Phrase("Overhead Profit:", new Font(Font.TIMES_ROMAN,
				8, Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(" "));
		cell.setBorder(0); table1.addCell(cell);
		
		document.add(table1);
		
	}
	
}
