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
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenSubJobsiteSummary extends Report  {

	ResultSet contract, item;
	Vector<String> submittalVector = new Vector<String>();
	String jobName;
	String agreementDate = "<agreement date goes here>";
	
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
	}

	ResultSet contractRS;
	ResultSet companyRS;
	ResultSet jobRS;
	ResultSet ownerRS;
	ResultSet rs;
	SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMM dd, yyyy");
	DecimalFormat df = new DecimalFormat("#,##0.00");
	String subName="<subcontractor name>";
	String subAddress = "<sub address>";
	String subCityStateZip = "< sub city, state zip>";
	String projectName="<project name>";
	String projectAddress = "<project address>";
	String projectCityStateZip = "< project city, state zip>";

	String ownerName="<owner name>";
	String ownerAddress = "<owner address>";
	String ownerCityStateZip = "< owner city, state zip>";

	String telephone = "<telephone>";
	String fax = "<fax>";
	String mobile_phone = "<mobile_phone>";
	String email = "<email>";
	String title, cTitle;

	//String amount = "<contract amount>";
	double amount = 123456.05;
	String amountString = "<contract amount to string>";
	String shortName, fullName;

	String contractDescription = "<description goes here.> Describe the contract here.  please.  pretty please?\n\n\n\n\n\n\n\n\n\n";


	private void evaluateVariables()throws SQLException{
		if (contractRS.next()){
			java.util.Date d = contractRS.getDate("agreement_date");
			if (!(d==null)){
				agreementDate = formatter.format(d);
			}
			else{
				agreementDate = "(no agreement date yet)";
			}
			contractDescription = contractRS.getString("description");
			amount = contractRS.getDouble("amount");
		}


		if (ownerRS.next()){
			ownerName=ownerRS.getString("company_name");
		}
		if (companyRS.next()){
			subName=companyRS.getString("company_name");
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
		if (jobRS.next()){
			projectName=jobRS.getString("job_name");
			jobName = projectName;
			projectAddress = jobRS.getString("address");
			projectCityStateZip = jobRS.getString("city") + ", " + jobRS.getString("state") + "   " + jobRS.getString("zip");
		}
		if (rs.first()) {
			title = rs.getString("contract_title");
			cTitle = rs.getString("contractee_title");
		}

	}

	public GenSubJobsiteSummary (String contract_id, Database db, String shortName, String fullName) throws Exception{
		id = contract_id;
		
		this.shortName = shortName;
		this.fullName = fullName;
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
				+ "using(cost_code_id) join cost_types on phase_code = letter where contract_id = "
				+ contract_id);
		this.contractRS = db.dbQuery("select * from contracts where contract_id = " + contract_id);
		evaluateVariables();
		doCleanup(db);
		type = Type.SUBCONTRACT;
	}//constructor

	public void create(Info in, Image toplogo) throws Exception {
		init();

		//blank spacer for keeping tables apart
		Table spacer = new Table(1,1);
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

		//add image
		Phrase p1 = new Phrase();
		Table table1=new Table(2,1);
		table1.setWidth(100);
		int[]widths = {60,40};
		table1.setWidths(widths);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		toplogo.scalePercent(20);
		Cell cell=new Cell(toplogo);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);
		p1 = new Phrase("WARNING!  This contract summary is printed only as the version that is proposed to the " + cTitle.toLowerCase() + ".  "
			+ "If you must question or enforce the scope of work for a " + cTitle.toLowerCase() + " please contact the main office and confirm that this "
			+ "proposal is unchanged. Some agreements are changed by the " + cTitle.toLowerCase() + " and accepted by " + shortName
			+ ". Very often these changes are NOT forwarded to the jobsite!",new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		p1.setLeading(8);
		cell = new Cell(p1);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setLeading(10);
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);
		document.add(spacer);

		table1=new Table(1,1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidth(100);
		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(title.toUpperCase() + " JOBSITE SUMMARY", new Font(Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBackgroundColor(Color.lightGray);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1=new Table(1,1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(1);
		table1.setSpacing(1);
		table1.setWidth(100);
		cell= new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setLeading(10);
		p1 = new Phrase("\n            This " + title + " Agreement entered into this " + agreementDate + ", by and between " + fullName + ", a corporation, hereinafter known as \"Contractor\" and "+ subName+ ", " + subAddress+", " + subCityStateZip+ ", hereinafter known as \"" + cTitle + "\"."
			+ "\n            WHEREAS, the Contractor has entered into a contract, hereinafter called the \"Principle Contract,\" with " + ownerName+ ", hereinafter called the \"Owner,\" for the construction of " + jobName + ", located at " + projectAddress + ", " + projectCityStateZip+ ", and:\n\n", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		p1.setLeading(10);
		cell.add(p1);
		cell.setBorder(0); table1.addCell(cell);
		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("The following is the scope of work as PROPOSED in Article 1 (page 1):", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setUseDescender(true);
		cell.setLeading(10);
		cell.setBackgroundColor(Color.lightGray);
		cell.setBorder(0); table1.addCell(cell);
		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Furthermore, the " + cTitle + " agrees to perform, under the terms of this Agreement, all of the work as follows:", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		/*
		table1=new Table(1,1);
		table1.setBorderWidth(1);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setSpacing(0);
		table1.setOffset(3);
		table1.setWidth(100);
		cell = new Cell();
		cell.setBorder(0); table1.addCell(cell);
		cell= new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		*/
		p1 = new Phrase("\n" + contractDescription + "\n", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		p1.setLeading(10);
		document.add(p1);
		//cell.add(p1);
		//cell.setBorder(0); table1.addCell(cell);
		//document.add(table1);

		table1=new Table(1,1);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(1);
		table1.setSpacing(0);
		table1.setOffset(3);
		table1.setWidth(100);
		cell= new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setLeading(10);
		p1 = new Phrase("\nThe work to be performed by " + cTitle + " shall be completed in strict conformace with all Contract Documents for the construction of " + projectName+ ".  Contractor reserves the right to issue additional and supplemental change orders which shall be deemed incorporated into this agreement.\n\n", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		p1.setLeading(10);
		cell.add(p1);
		cell.setBorder(0); table1.addCell(cell);
		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("The following is the PROPOSED dollar value from Article IV of the " + title.toLowerCase() + " agreement (page 4):\n", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setLeading(10);
		cell.setUseDescender(true);
		cell.setBorder(0); table1.addCell(cell);
		cell= new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		p1 = new Phrase("          In consideration of the complete and timely performance of all work under this " + title.toLowerCase() + " agreement, Contractor shall pay to " + cTitle + " the sum of  " + DocHelper.numberToText(amount)+ "; amount stated includes all applicable federal, state, and local taxes.  All pay requests under this " + cTitle + " Agreement shall be rounded to the nearest dollar.\n\n", new Font(Font.TIMES_ROMAN, 8, Font.BOLD));
		p1.setLeading(10);
		cell.add(p1);
		p1 = new Phrase("          " + cTitle + " will be paid only after Contractor receives payment specifically designated for the work and materials provided by " + cTitle + ".  Contractor's recept of payment from Owner is an express condition precedent to Contractor's payment obligations hereunder and the source of payment. " + cTitle + " expressly accepts this condition for all payments or reimbursements and accepts all risks this may imply for compensation for any and all costs expended in the performance of the " + title + " Agreement.\n\n", new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
		p1.setLeading(10);
		cell.add(p1);
		cell.setBorder(0); table1.addCell(cell);
		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Description of Contract Changes, if any:", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setUseDescender(true);
		cell.setLeading(10);
		cell.setBorder(0); table1.addCell(cell);
		/*
		cell= new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Describe Contract Changes here.\n", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		*/
		document.add(table1);

	}

	public static void main(String[] args)throws Exception{
		/*
			String subName = "The Sinkluge Group";
			String jobName = "Project--Get the Kluge Out";
			String address = "My Address";
			String city = "Whatever city";
			String state = "This State";
			String zip = "ZipCode";
			String phone = "1234567";
			String fax = "12309874";

			String contractID = "1938220";
			ResultSet companyInfo = null;
			ResultSet submittalRS = null;
			ResultSet contractRS = null;
			GenSubcontract g = new GenSubcontract(subName, jobName, address, city, state, zip, phone, fax, contractID, companyInfo, submittalRS, contractRS);
			System.out.println(g.create());*/
	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}
}
