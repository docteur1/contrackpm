package com.sinkluge.reports.contracts;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Vector;

import com.lowagie.text.Cell;
import com.lowagie.text.Chunk;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;
import com.sinkluge.utilities.BigString;

public class GenSubcontract extends Report {
	
	public ReportContact getReportContact(String id, Database db) throws Exception {
		String query = "select contact_id, company_id from contracts "
			+ "where contract_id = " + id;
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

	ResultSet contract, item;

	Vector<String> submittalVector = new Vector<String>();

	String jobName;
	
	BigString text;

	String submittal_copies;

	String agreementDate;

	String contract_id;

	ResultSet contractRS;

	ResultSet companyRS;

	ResultSet jobRS;

	ResultSet ownerRS;

	ResultSet architectRS;

	ResultSet submittalRS;
	
	Attributes attr;

	SimpleDateFormat formatter = new SimpleDateFormat("EEEEEEEEE, MMM dd, yyyy");

	DecimalFormat df = new DecimalFormat("#,##0.00");

	DecimalFormat df2 = new DecimalFormat("0.0#");

	String subName = "<subcontractor name>";
	
	String contactName;

	String subAddress = "<sub address>";

	String subCityStateZip = "< sub city, state zip>";
	
	String mobile, email;
	
	String title, cTitle;

	String projectName = "<project name>";

	String projectAddress = "<project address>";

	String projectCityStateZip = "< projectb city, state zip>";

	String architectName = "<architect name>";

	String architectAddress = "<architect address>";

	String architectCityStateZip = "< architect city, state zip>";

	String ownerName = "<owner name>";

	String ownerAddress = "<owner address>";

	String ownerCityStateZip = "< owner city, state zip>";

	String federal_id = "<federal_id>";

	String license_number = "<license_no>";

	String telephone = "<telephone>";

	String fax = "<fax>";

	//String amount = "<contract amount>";
	double amount = 123456.05;

	float retention = 0.05f;
	
	boolean insure = false;

	String amountString = "<contract amount to string>";

	String bidDocuments = "<bid documents go here>\n example: \n1.1  Stuff \n1.2  More stuff \n1.3 All the stuff\n\n\n\n\n\n";

	String contractDescription = "<description goes here.> Describe the contract here.  please.  pretty please?\n\n\n\n\n\n\n\n\n\n";

	String dueDate = "<agreement date + 30 days>";

	String costCodeID = "<cost_code_id>";

	String omSubmittals = "<omSubmittals>";

	String fullWarranty = "<fullWarranty>";

	String lienReleases = "<lienReleases>";

	String signedTraining = "<signedTraining>";

	String specialtyItems = "<specialtyItems>";

	String otherItems = "<otherItems>";

	public void evaluateVariables() throws SQLException {
		if (jobRS.next()) {
			projectName = jobRS.getString("job_name");
			submittal_copies = jobRS.getString("submittal_copies");
			if (projectName == null)
				projectName = "";
			jobName = projectName;
			projectAddress = jobRS.getString("address");
			if (projectAddress == null)
				projectAddress = "";
			projectCityStateZip = jobRS.getString("city") + ", "
					+ jobRS.getString("state") + "   " + jobRS.getString("zip");
			if (projectCityStateZip == null)
				projectCityStateZip = "";
			bidDocuments = jobRS.getString("bid_documents");
			if (bidDocuments == null)
				bidDocuments = "";
		}

		if (contractRS.next()) {
			java.util.Date d = contractRS.getDate("agreement_date");
			if (!(d == null)) {
				agreementDate = formatter.format(d);
				Calendar cal = Calendar.getInstance();
				cal.setTime(d);
				cal.add(Calendar.DAY_OF_YEAR, 30);
				dueDate = formatter.format(cal.getTime());
			} else {
				agreementDate = "(no agreement date yet)";
				dueDate = "(the agreement date + 30 days)";
			}

			retention = contractRS.getFloat("retention_rate");
			contractDescription = contractRS.getString("description");
			if (contractDescription == null)
				contractDescription = "";
			amount = contractRS.getDouble("amount");
			costCodeID = contractRS.getString("cost_code_id");

			omSubmittals = contractRS.getString("req_tech_submittals").equals(
					"n") ? "Nothing required"
					: "Full technical, parts, and manufacturing submittals, "
							+ submittal_copies + " copies required";
			fullWarranty = contractRS.getString("req_warranty").equals("n") ? "Nothing required"
					: "Complete labor, materials, and equipment warranties";
			lienReleases = "Unconditional Lien Release for all monies received to-date from the " + cTitle + " and its subcontractors and suppliers";
			signedTraining = contractRS.getString("req_owner_training").equals(
					"n") ? "No training required"
					: "Thorough training of approved Owner's representatives and a completed, signed training form";
			specialtyItems = contractRS.getString("req_specialty");
			if (specialtyItems == null)
				specialtyItems = "n";
			if (specialtyItems.equals("n"))
				specialtyItems = "None";
			otherItems = contractRS.getString("tracking_notes");
			if (otherItems == null)
				otherItems = "";
		}

		if (ownerRS.next()) {
			ownerName = ownerRS.getString("company_name");
			if (ownerName == null)
				ownerName = "";
			ownerAddress = ownerRS.getString("address");
			if (ownerAddress == null)
				ownerAddress = "";
			ownerCityStateZip = ownerRS.getString("city") + ", "
					+ ownerRS.getString("state") + "   "
					+ ownerRS.getString("zip");
			if (ownerCityStateZip == null)
				ownerCityStateZip = "";
		}
		if (architectRS.next()) {
			architectName = architectRS.getString("company_name");
			if (architectName == null)
				architectName = "";
			architectAddress = architectRS.getString("address");
			if (architectAddress == null)
				architectAddress = "";
			architectCityStateZip = architectRS.getString("city")
					+ ", " + architectRS.getString("state") + "   "
					+ architectRS.getString("zip");
			if (architectCityStateZip == null)
				architectCityStateZip = "";
		}
		if (companyRS.next()) {
			subName = companyRS.getString("company_name");
			if (subName == null)
				subName = "";
			contactName = companyRS.getString("name");
			if (contactName == null) contactName = "";
			mobile = companyRS.getString("mobile_phone");
			if (mobile == null) mobile = "";
			email = companyRS.getString("email");
			if (email == null) email = "";
			subAddress = companyRS.getString("address");
			if (subAddress == null)
				subAddress = "";
			subCityStateZip = companyRS.getString("city") + ", "
					+ companyRS.getString("state") + "   "
					+ companyRS.getString("zip");
			if (subCityStateZip == null)
				subCityStateZip = "";
			telephone = companyRS.getString("contacts.phone");
			if (telephone == null) telephone = companyRS.getString("company.phone");
			if (telephone == null) telephone = "";
			fax = companyRS.getString("contacts.fax");
			if (fax == null) fax = companyRS.getString("company.fax");
			if (fax == null) fax = "";
			federal_id = companyRS.getString("federal_id");
			if (federal_id == null)
				federal_id = "";
			license_number = companyRS.getString("license_number");
			if (license_number == null)
				license_number = "";
		}

		while (submittalRS.next()) {
			submittalVector.addElement("30 days    "
					+ submittalRS.getString("description"));
		}
		
		text.replaceAll("%a", "$" + df.format(amount));
		text.replaceAll("%A", DocHelper.numberToText(amount));
		text.replaceAll("%r", df2.format(retention*100));
		text.replaceAll("%n", projectName);
		text.replaceAll("%d", attr.get("address"));
		text.replaceAll("%c", attr.get("city"));
		text.replaceAll("%s", attr.get("state"));
		text.replaceAll("%z", attr.get("zip"));
		text.replaceAll("%p", attr.get("phone"));
		
	}

	public GenSubcontract(String contract_id, int job_id, Database db, Attributes attr) throws Exception {
		this.contract_id = contract_id;
		id = contract_id;
		type = Type.SUBCONTRACT;
		this.attr = attr;
		String query = "select company.*, contacts.name, contacts.fax, contacts.phone, mobile_phone, email "
			+ "from company join contracts using(company_id) left join contacts using (contact_id) where "
			+ "contract_id = " + contract_id;
		companyRS = db.dbQuery(query);
		query = "select company.* from company join job_contacts using (company_id) where isDefault = 1 "
			+ "and type = 'Owner' and job_id = " + job_id;
		ownerRS = db.dbQuery(query);
		query = "select company.* from company join job_contacts using (company_id) where isDefault = 1 "
			+ "and type = 'Architect' and job_id = " + job_id;
		architectRS = db.dbQuery(query);
		query = "select job_name, address, city, state, zip, bid_documents, submittal_copies "
			+ "from job where job_id = " + job_id;
		jobRS = db.dbQuery(query);
		query = "select description from submittals where contract_id = " + contract_id;
		submittalRS = db.dbQuery(query);
		query = "select * from contracts where contract_id = " + contract_id;
		contractRS = db.dbQuery(query);
		query = "select contract, contract_title, contractee_title, site_work from cost_types join job_cost_detail "
			+ "on phase_code = letter join contracts using(cost_code_id) join job on contracts.job_id = job.job_id "
			+ "and job.site_id = cost_types.site_id where contract_id = " + contract_id;
		ResultSet rs = db.dbQuery(query);
		if (rs.first()) {
			text = new BigString(rs.getString("contract"));
			title = rs.getString("contract_title");
			cTitle = rs.getString("contractee_title");
			insure = rs.getBoolean("site_work");
		}
		evaluateVariables();
		doCleanup(db);
	}//constructor
	
	public void doCleanup(Database db) throws SQLException {
		if (companyRS != null) {
			companyRS.getStatement().close();
			companyRS = null;
			ownerRS.getStatement().close();
			ownerRS = null;
			architectRS.getStatement().close();
			architectRS = null;
			jobRS.getStatement().close();
			jobRS = null;
			submittalRS.getStatement().close();
			submittalRS = null;
			contractRS.getStatement().close();
			contractRS = null;
		}
	}

	public void create(Info in, Image toplogo) throws Exception {

		//for the unchecked box
		Image checkbox = Image.getInstance(in.path
				+ "/WEB-INF/images/unchecked.jpg");
		Chunk ch2 = new Chunk(checkbox, -7, -7);
		Phrase checkboxPhrase = new Phrase();
		checkboxPhrase.add(ch2);

		Font tnr8 = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL);
		
		Image iBox = Image.getInstance(in.path
				+ "/WEB-INF/images/initialsBox.jpg");//(in.path + "/jsp/dev/images/epcologo3.jpg");
		Chunk ch3 = new Chunk(iBox, -3, -3);
		Phrase initialsBoxPhrase = new Phrase();
		initialsBoxPhrase.add(ch3);

		Phrase footerPhrase = new Phrase(attr.get("full_name") + ", "
				+ attr.get("address") + ", " + attr.get("city") + ", " + attr.get("state") + " "
				+ attr.get("zip") + "\nPhone: " + attr.get("phone") + "   Fax: " + attr.get("fax")
				+ "   " + attr.get("url") + "   Page: ", new Font(Font.TIMES_ROMAN,
				7, Font.BOLD | Font.ITALIC));
		
		HeaderFooter footer = new HeaderFooter(footerPhrase, true);
		footer.setBorder(0);
		footer.setAlignment(Element.ALIGN_CENTER);
		init(40, 40, 40, 40, footer);
		
		Phrase underLinePhrase = new Phrase(
				"  ___________________________________________________________________________________________  ",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD));
		int[] twoC = { 30, 70 };
		int[] twoD = { 5, 95 };
		int[] twoF = { 10, 90 };
		int[] twoE = { 25, 75 };
		int[] twoG = { 40, 60 };
		int[] threeD = { 4, 11, 85 };
		int[] threeB = { 70, 15, 15 };
		//int[] threeC = { 47, 5, 48 };
		int[] five = { 18, 25, 14, 18, 25 };

		//blank spacer for keeping tables apart
		Table spacer = new Table(1, 1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		Cell blank = new Cell();
		blank.add(new Chunk("", new Font(Font.TIMES_ROMAN, 8, Font.BOLD,
				new Color(255, 255, 255))));
		blank.setBorderWidth(0);
		//blank.setLeading(0);
		spacer.addCell(blank);

		//start of document
		//document.setFooter(footer);

		//document.setFooter(footer);

		//add image
		Phrase p1 = new Phrase();
		Table table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		toplogo.scalePercent(20);
		//Chunk ch1=new Chunk(toplogo, -36, -55);
		//p1.add(ch1);
		Cell cell = new Cell(toplogo);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		table1.addCell(cell);

		document.add(table1);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);
		document.add(spacer);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setLeading(19);
		cell
				.add(new Phrase(
						title.toUpperCase() + " AGREEMENT BETWEEN CONTRACTOR AND " + cTitle.toUpperCase() + "\n",
						new Font(Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setUseDescender(true);
		cell.setBackgroundColor(Color.lightGray);
		cell.setBorder(0);
		table1.addCell(cell);
		document.add(table1);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setSpacing(0);
		cell = new Cell();
		cell.add(underLinePhrase);
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("\nDOCUMENTS CONTAINED HEREIN:\n", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);
		document.add(table1);

		table1 = new Table(3, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(threeD);
		table1.setPadding(0);
		table1.setSpacing(0);
		table1.addCell(blank);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Page 1", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Agreement Declaration", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.add(new Phrase(
						"    Initial boxes below to indicate complete review of this agreement.",
						new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);

		table1.addCell(blank);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Page 2", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell
				.add(new Phrase(
						"Articles of " + title + " Agreement and Standard Provisions",
						tnr8));
		cell.add(new Phrase("    Sign the concluding page.", new Font(
				Font.TIMES_ROMAN, 8, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);

		table1.addCell(blank);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Exhibit \"A\"", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
				"List of Contract Documents, Plans, Specifications, Etc.",
				tnr8));
		cell.setBorder(0);
		//cell.add(new Phrase("    Read and initial each page.", new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
		table1.addCell(cell);

		table1.addCell(blank);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Exhibit \"B\"", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(cTitle + "'s Scope of Work", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);

		table1.addCell(blank);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");

		cell.add(new Phrase("Exhibit \"C\"", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");

		cell
				.add(new Phrase(
						cTitle + "'s Special Provisions and Procedure Requirements",
						tnr8));
		cell
				.add(new Phrase(
						"    Read and complete \"Release Authorization\" information.",
						new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);
		table1.addCell(blank);
		if (insure) {
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase("Exhibit \"D\"", new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL)));
			cell.setBorder(0);
			table1.addCell(cell);
		
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase(cTitle + " Cost Breakdown", new Font(
					Font.TIMES_ROMAN, 8, Font.NORMAL)));
			cell.add(new Phrase("    Complete and return with signed contract",
					new Font(Font.TIMES_ROMAN, 8, Font.ITALIC)));
			cell.setBorder(0);
			table1.addCell(cell);
	
			table1.addCell(blank);
		}
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setColspan(2);
		cell.add(new Phrase("NOTE OTHERS HERE:", new Font(Font.TIMES_ROMAN,
				8, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);

		document.add(table1);

		table1 = new Table(3);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setWidths(threeB);
		table1.addCell(blank);
		cell = new Cell();
		cell.setColspan(2);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
				"(Initial) Entire agreement thoroughly reviewed:\n",
				new Font(Font.TIMES_ROMAN, 6, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);

		table1.addCell(blank);

		cell = new Cell();

		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Contractor: ________", new Font(
				Font.TIMES_ROMAN, 6, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(cTitle + ": ________", new Font(
				Font.TIMES_ROMAN, 6, Font.ITALIC)));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setColspan(3);
		cell.add(underLinePhrase);
		cell.setBorder(0);
		table1.addCell(cell);
		document.add(table1);

		table1 = new Table(1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("AGREEMENT", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		cell.add(new Phrase(" made as of " + agreementDate, new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		cell.add(new Phrase("BETWEEN", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		cell.add(new Phrase(" the Contractor: \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + attr.get("full_name") + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + attr.get("address") + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + attr.get("city") + ", " + attr.get("state") + " "
				+ attr.get("zip"), new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase(
				"                (hereinafter known as \"Contractor\")\n",
				new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		cell.add(new Phrase("AND",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.add(new Phrase(" the " + cTitle + ": \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + subName + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + subAddress + "\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + subCityStateZip, new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell
				.add(new Phrase(
						"                (hereinafter known as \"" + cTitle + "\")\n",
						new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		cell.add(new Phrase("FOR",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.add(new Phrase(" the the fixed sum of  "
				+ DocHelper.numberAndText(amount) + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		//cell.add(new Phrase("     " + amountString + " \n", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		cell.add(new Phrase("FOR",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.add(new Phrase(" the Project known as:\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + projectName + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + projectAddress + "\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + projectCityStateZip, new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase(
				"                (hereinafter known as \"Project\")\n",
				new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		cell
				.add(new Phrase("BY", new Font(Font.TIMES_ROMAN, 10,
						Font.BOLD)));
		cell.add(new Phrase(" the Architect:\n", new Font(Font.TIMES_ROMAN,
				10, Font.NORMAL)));
		cell.add(new Phrase("     " + architectName + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + architectAddress + "\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + architectCityStateZip, new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase(
				"                (hereinafter known as \"Architect\")\n",
				new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		cell.add(new Phrase("FOR",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.add(new Phrase(" the Project owner:\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + ownerName + " \n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + ownerAddress + "\n", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase("     " + ownerCityStateZip, new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.add(new Phrase(
				"                (hereinafter known as \"Owner\")\n",
				new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("WHEREFORE", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		cell
				.add(new Phrase(
						" the Contractor and " + cTitle + " agree as follows:\n\n\n",
						new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);
/*
		table1 = new Table(1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
	
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		//cell.add(new Phrase("\n", new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		cell.setBorder(Rectangle.BOTTOM | Rectangle.TOP);
		cell.setBorderWidth(1.1f);
		cell.add(footerPhrase);
		cell.add(new Phrase(" 1\n ",
				new Font(Font.TIMES_ROMAN, 6, Font.NORMAL)));
		//cell.add(footerPhrase2);
		
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);
*/
		document.newPage();

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(title.toUpperCase() + " AGREEMENT\n", new Font(
				Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setLeading(19);
		cell.setUseDescender(true);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		
		Paragraph para = new Paragraph(8, "\n\n" + text.toString(), tnr8);
		
		document.add(para);
		
		Phrase p;
		
		
		document.add(spacer);
		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setWidths(twoC);
		table1.setPadding(0);
		p = new Phrase("Date:\n\n", new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);
		p = new Phrase("Signed:\n\n", new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);

		p = new Phrase("_______________________", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);
		p = new Phrase(
				"_________________________________________________________________",
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);

		table1.addCell(blank);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell
				.add(new Phrase(
						"            General Contractor                                               Title\n",
						tnr8));
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setColspan(2);
		cell
				.add(new Phrase(
						"\nThis " + title + " Agreement supercedes all other proposals, documents, and negotiations whether written or verbal\n\n",
						new Font(Font.TIMES_ROMAN, 8, Font.BOLDITALIC)));
		cell.setBorder(0); table1.addCell(cell);

		p = new Phrase("Date:\n\n", new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);
		p = new Phrase("Signed:\n\n", new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);

		p = new Phrase("_______________________", new Font(
				Font.TIMES_ROMAN, 10, Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);
		p = new Phrase(
				"_________________________________________________________________",
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(p);
		cell.setBorder(0); table1.addCell(cell);

		table1.addCell(blank);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell
				.add(new Phrase(
						"            " +cTitle + "                                                       Title\n",
						tnr8));
		cell.setBorder(0); table1.addCell(cell);
		table1.setCellsFitPage(true);
		table1.setTableFitsPage(true);
		document.add(table1);

		document.newPage();

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(cTitle.toUpperCase() + " INFORMATION\n", new Font(
				Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setLeading(19);
		cell.setUseDescender(true);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		document.add(new Phrase("\n"));

		table1 = new Table(5, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(1);
		table1.setWidths(five);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");

		cell.add(new Phrase("Federal I.D. : ", new Font(Font.TIMES_ROMAN,
				10, Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.add(new Phrase(federal_id, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");

		cell.add(new Phrase("(Both Required)", new Font(Font.TIMES_ROMAN,
				8, Font.BOLD)));

		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("License Number : ", new Font(Font.TIMES_ROMAN,
				10, Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.add(new Phrase(license_number, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		
		cell.add(new Phrase("Contact : ", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.setUseDescender(true);
		cell.add(new Phrase(contactName, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Company : ", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.add(new Phrase(subName,
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setUseDescender(true);
		table1.addCell(cell);	
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Telephone : ", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.setUseDescender(true);
		cell.add(new Phrase(telephone, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("Fax : ", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.add(new Phrase(fax,
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");

		cell.add(new Phrase("Mobile phone : ", new Font(Font.TIMES_ROMAN,
				10, Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.add(new Phrase(mobile, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("", new Font(Font.TIMES_ROMAN, 8, Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("E-mail : ", new Font(Font.TIMES_ROMAN, 10,
				Font.BOLD)));
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.setBorder(15);
		cell.add(new Phrase(email, new Font(Font.TIMES_ROMAN, 10,
				Font.NORMAL)));
		cell.setUseDescender(true);
		table1.addCell(cell);
		document.add(table1);

		//document.add(spacer);

		table1 = new Table(1, 1);
		//table1.setBorderWidth(4);
		//table1.setBorderColor(Color.lightGray);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setBorder(0);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		if (insure) cell.add(new Phrase(
						"Please attach a COPY of your current state license to this page:",
						new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		else cell.add(new Phrase("", new Font(Font.TIMES_ROMAN, 12, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		document.add(spacer);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		if (insure) cell.add(new Phrase("\n\nAttach\nCopy of\nContractor's\nLicense\nHere\n(If Applicable)",
						new Font(Font.TIMES_ROMAN, 24, Font.NORMAL, Color.lightGray)));
		else cell.add(new Phrase("",
				new Font(Font.TIMES_ROMAN, 24, Font.NORMAL, Color.lightGray)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);


		//document.setMargins(72, 72, 36, 36);
		document.newPage();

		table1 = new Table(1, 1);
		table1.setOffset(0);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidth(100);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(title.toUpperCase() + " EXHIBIT \"A\"\n", new Font(
				Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setLeading(6);
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(new Phrase("\n", new Font(Font.TIMES_ROMAN, 8)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell
				.add(new Phrase(
						"CONTRACT DOCUMENTS, PLANS,\nSPECIFICATIONS, ADDENDUMS, ETC.\n",
						new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBackgroundColor(Color.lightGray);
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
						"\n"
								+ subName
								+ " is responsible to verify versions, dates, and completeness of documents that were used in the preparation of the " +cTitle + "'s bid proposal before signing this " + title + " Agreement\n",
						tnr8));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
						"This " + title + " Agreement includes, but is not limited to the following items:",
						new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setUseDescender(true);
		cell.setBorder(Rectangle.BOTTOM);
		cell.setBorderWidth(0.5f);
		table1.addCell(cell);
		document.add(table1);

		Paragraph prgh = new Paragraph("\n" + bidDocuments + "\n",
				tnr8);
		prgh.setLeading(10);
		document.add(prgh);
		
		document.add(spacer);
		/*
		 p = new Phrase("\n"+bidDocuments, new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
		 p.setLeading(10);
		 cell= new Cell(p);
		 cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
		 cell.setBorderWidth(0.5f);
		 //cell.setBorderColor(Color.lightGray);
		 cell.setHorizontalAlignment("left");
		 cell.setVerticalAlignment("middle");
		 //cell.setLeading(10);
		 cell.setUseDescender(true);
		 table1.addCell(cell);
		 */
		
		table1 = new Table(1, 1);
		table1.setOffset(0);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setWidth(100);
		table1.setTableFitsPage(true);
		p = new Phrase(
				"\nPlease note below all verbal conditions or instructions, if any, that the " + cTitle + " has received during the bid process which might affect the scope of work as required by the contract documents",
				new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
		p.setLeading(10);
		cell = new Cell(p);
		cell.setBorder(Rectangle.TOP);
		cell.setBorderWidth(0.5f);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		table1.addCell(cell);

		document.add(table1);

		document.newPage();

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setOffset(0);
		table1.setWidth(100);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(title.toUpperCase() + " EXHIBIT \"B\"\n", new Font(
				Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setLeading(6);
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell(new Phrase("\n", new Font(Font.TIMES_ROMAN, 8)));
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("SCOPE OF WORK\n", new Font(Font.TIMES_ROMAN,
				16, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBorder(0);
		table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell
				.add(new Phrase(
						"\nThis " + title + " Agreement includes, but is not limited to the following items:\n\n",
						new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		cell.setBorder(Rectangle.BOTTOM);
		cell.setBorderWidth(0.5f);
		table1.addCell(cell);

		document.add(table1);

		prgh = new Paragraph("\n" + contractDescription + "\n", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL));
		prgh.setLeading(10);
		document.add(prgh);
		//cell= new Cell(prgh);
		//cell.setBorder(Rectangle.TOP | Rectangle.BOTTOM);
		//cell.setBorderWidth(0.5f);
		//cell.setBorderColor(Color.lightGray);
		//cell.setHorizontalAlignment("left");
		//cell.setVerticalAlignment("middle");
		//cell.setLeading(10);
		//cell.setUseDescender(true);
		//table1.addCell(cell);
		
		document.add(spacer);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setOffset(0);
		table1.setWidth(100);
		table1.setTableFitsPage(true);

		p = new Phrase(
				"\nAll " + cTitle + " bid proposal conditions that are outside of, in addition to or are limiting of conditions contained in the Contract Documents are of no effect and are invalid to the " + title + " Agreement unless expressly included in the description above.",
				tnr8);
		p.setLeading(10);
		cell = new Cell(p);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.setBorder(Rectangle.TOP);
		cell.setBorderWidth(0.5f);
		table1.addCell(cell);

		document.add(table1);

		//document.setMargins(10, 10, 30, 30);

		document.newPage();

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setOffset(0);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(title.toUpperCase() + " EXHIBIT \"C\"\n", new Font(
				Font.TIMES_ROMAN, 20, Font.BOLD)));
		cell.setLeading(6);
		cell.setBorder(0);
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(new Phrase("\n", new Font(Font.TIMES_ROMAN, 8)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(
				cTitle.toUpperCase() + " SPECIAL PROVISIONS AND REQUIREMENTS\n",
				new Font(Font.TIMES_ROMAN, 16, Font.BOLD)));
		cell.setBackgroundColor(Color.lightGray);
		cell.setUseDescender(true);
		cell.setLeading(17);
		cell.setBorder(0); table1.addCell(cell);
		
		document.add(table1);
		
		int count = 1;
		
		if (insure) {
			
			table1 = new Table(1, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(0);
			table1.setOffset(4);
			cell = new Cell();
			cell.add(new Phrase("1.     Insurance Provisions (If Applicable)", new Font(
					Font.TIMES_ROMAN, 10, Font.BOLD)));
			//cell.setLeading(6);
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
			count++;
			table1 = new Table(2, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(0);
			table1.setWidths(twoD);
			table1.setOffset(0);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.setLeading(6);
			cell
					.add(new Phrase(
							"a.  The " + cTitle + " is required to name the following as additional Primary-Insured:",
							tnr8));
			table1.addCell(blank);
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
	
			table1 = new Table(2, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(0);
			table1.setWidths(twoE);
			table1.setOffset(0);
			cell = new Cell();
			cell.setHorizontalAlignment("right");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase("Contractor:  ", new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase(attr.get("full_name"), new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("right");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase("Owner:  ", new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase(ownerName, new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("right");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase("Other:  ", new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL)));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase("_______________________________________",
					tnr8));
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
	
			table1 = new Table(2, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(0);
			table1.setWidths(twoD);
			table1.setOffset(4);
			p = new Phrase(
					"b.  The " + cTitle + " must provide verification of current Worker's Compensation coverage with reference to "
							+ jobName + " on the policy.", new Font(
							Font.TIMES_ROMAN, 8, Font.NORMAL));
			p.setLeading(8);
			cell = new Cell(p);
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.setLeading(8);
			table1.addCell(blank);
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
		}

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setOffset(4);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(count + ".     Release Authorizations", new Font(
				Font.TIMES_ROMAN, 10, Font.BOLD)));
		count++;
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		table1 = new Table(2, 1);
		table1.setOffset(4);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setWidths(twoD);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		p = new Phrase(
				"List any Owners, Partners, and/or Corporate Officers who are legally authorized to sign for "
						+ subName
						+ " and who will be signing the MONTHLY REQUEST FOR PAYMENT, FINAL REQUEST FOR PAYMENT, and LIEN WAIVER documents:\n\n",
				tnr8);
		p.setLeading(8);
		p1 = new Phrase(
				"       ______________________________________________________________________          ______________________________________________________________________\n",
				new Font(Font.TIMES_ROMAN, 6, Font.ITALIC));
		//p1.setLeading(0);
		Phrase p2 = new Phrase(
				"       Printed name and title                                                                                                                   Signature\n\n",
				new Font(Font.TIMES_ROMAN, 6, Font.ITALIC));
		//cell.setLeading(8);
		cell.add(p);
		cell.add(p1);
		cell.add(p2);
		cell.add(p1);
		cell.add(p2);
		cell.add(p1);
		cell.add(p2);
		table1.addCell(blank);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		table1.setOffset(0);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(count + ".     Shop Drawings - Samples - Submittals",
				new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		count++;

		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setWidths(twoD);
		table1.setOffset(2);
		p = new Phrase(
				"All shop drawings, materials samples, and submittals shall be submitted to the Contractor within 30 days of the issuance of this " + title + " Agreement unless specifically noted below.  All submitted items shall be in number and type as per the contract documents including, but not limited to, the following:",
				tnr8);
		p.setLeading(8);
		cell = new Cell(p);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		table1.addCell(blank);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setWidths(twoF);
		table1.setOffset(4);

		p = new Phrase("--The number of copies of each submittal for "
				+ jobName + " is " + submittal_copies
				+ ".\n--All submittals, of any type, are due on or before "
				+ dueDate + " unless specifically noted otherwise.\n",
				tnr8);
		p.setLeading(8);
		cell = new Cell(p);
		table1.addCell(blank);
		cell.setBorder(0); table1.addCell(cell);
		String submittals = "";
		if (!submittalVector.isEmpty()) {
			p = new Phrase("            Due Date:\n", new Font(
					Font.TIMES_ROMAN, 8, Font.BOLD));
			p.setLeading(8);
			cell = new Cell(p);
			cell.setColspan(2);
			cell.setBorder(0); table1.addCell(cell);
			for (int i = 0; i < submittalVector.size(); i++) {
				submittals += (String) submittalVector.elementAt(i) + "\n";
			}
			p = new Phrase(submittals, new Font(Font.TIMES_ROMAN, 8,
					Font.NORMAL));
			p.setLeading(8);
			cell = new Cell(p);
			table1.addCell(blank);
			cell.setBorder(0); table1.addCell(cell);
		} else {
			p = new Phrase(
					"\nSubmittals required per contract documents and specifications.\n",
					new Font(Font.TIMES_ROMAN, 8, Font.BOLD));
			p.setLeading(8);
			cell = new Cell(p);
			table1.addCell(blank);
			cell.setBorder(0); table1.addCell(cell);
		}
		p = new Phrase(
				"\n("
						+ subName
						+ " is responsible for all submittals required in the Contract Documents as pertaining to labor and materials included in the scope of this " + title + " Agreement regardless of items listed, not listed, or incorrectly listed above.)",
				new Font(Font.TIMES_ROMAN, 6, Font.ITALIC));
		p.setLeading(8);
		cell = new Cell(p);

		table1.addCell(blank);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(1);
		table1.setWidths(twoD);
		table1.setOffset(2);
		p = new Phrase(
				cTitle.toUpperCase() + " acknowledges that review and approval of any type of submittal which deviates from the Project Plans and Specifications does NOT relieve the " + cTitle + " from costs, penalties and all other remedies required to meet the published specifications where the " + cTitle + " failed to notify the Owner/Architect/Contractor in writing of the variations from the specifications and failed to obtain written approval for EACH variation from the published specifications.",
				tnr8);
		p.setLeading(8);
		cell = new Cell(p);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(8);
		table1.addCell(blank);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(1, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setOffset(2);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase(count + ".     Project Close-out", new Font(
				Font.TIMES_ROMAN, 10, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);
		count++;
		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setOffset(4);
		table1.setWidths(twoD);
		p = new Phrase(
				"All project close-out documents, materials, and Owner-training required by the Contract Documents shall be submitted to the Contractor PRIOR to payment of the " + cTitle + "'s 90% completion payment request.  The requirements shall include, but not be limited to, the following:",
				tnr8);
		p.setLeading(8);
		cell = new Cell(p);
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("middle");
		//cell.setLeading(8);
		table1.addCell(blank);
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		table1 = new Table(2, 1);
		table1.setBorderWidth(0); table1.setWidth(100);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(0);
		table1.setOffset(0);
		table1.setWidths(twoG);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("\"O & M\" Submittals: ", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(omSubmittals, new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Full Warranty: ", new Font(Font.TIMES_ROMAN,
				8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(fullWarranty, new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Up-to-date Lien Release(s): ", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(lienReleases, new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Signed Training Form: ", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(signedTraining, new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Materials-Equip-Specialty Items: ", new Font(
				Font.TIMES_ROMAN, 8, Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(specialtyItems, new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("right");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase("Other Items: ", new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell();
		cell.setHorizontalAlignment("left");
		cell.setVerticalAlignment("top");
		cell.add(new Phrase(otherItems, new Font(Font.TIMES_ROMAN, 8,
				Font.NORMAL)));
		cell.setBorder(0); table1.addCell(cell);
		document.add(table1);

		if (insure) {
			table1 = new Table(1, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(3);
			table1.setOffset(2);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase(count + ".     " + cTitle + " Safety Program (If Applicable)",
					new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
			table1 = new Table(2, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(0);
			table1.setOffset(2);
			table1.setWidths(twoD);
			p = new Phrase(
					cTitle + " will submit one copy of the " + cTitle + "'s job-specific safety program to "
							+ attr.get("full_name")
							+ " before any equipment, manpower, or materials are brought onto the Project site.  ",
					tnr8);
			p.setLeading(8);
			cell = new Cell(p);
			p = new Phrase(
					cTitle + " will require it's " + cTitle.toLowerCase() + "s to have in place a job-specific safety program before they enter the Project site.",
					tnr8);
			p.setLeading(8);
			cell.add(p);
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			//cell.setLeading(8);
	
			table1.addCell(blank);
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
		}
		
		if (insure) {
			document.newPage();
	
			table1 = new Table(1, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(3);
			table1.setOffset(0);
			cell = new Cell();
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase(title.toUpperCase() + " EXHIBIT \"D\"", new Font(
					Font.TIMES_ROMAN, 20, Font.BOLD)));
			cell.setLeading(6);
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell(new Phrase("\n", new Font(Font.TIMES_ROMAN, 8)));
			cell.setBorder(0);
			table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			cell.add(new Phrase(cTitle.toUpperCase() + "'S COST BREAKDOWN\n", new Font(				
					Font.TIMES_ROMAN, 16, Font.BOLD)));
			cell.setBackgroundColor(Color.lightGray);
			cell.setUseDescender(true);
			cell.setLeading(17);
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
			table1 = new Table(1, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setPadding(0);
			table1.setOffset(2);
			p = new Phrase(
					"The following information is to be supplied by "
							+ subName
							+ " for "
							+ jobName
							+ ". List all SUPPLIERS and SUBCONTRACTORS for approval and payment confirmation (attach additional pages if needed):",
					new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
			p.setLeading(12);
			cell = new Cell(p);
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell
					.add(new Phrase(
							"     Name                                        City                                  Phone                                                                            Estimated Dollar Amount",
							tnr8));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			p = new Phrase(
					"________________________________________________________________________  $___________________\n",
					new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			for (int i = 0; i < 10; i++) {
				cell.add(p);
			}
			cell.setBorder(0); table1.addCell(cell);
	
			p = new Phrase(
					"Supplier accepts full responsibility for acts and omissions of his subcontractors and suppliers.  No suppliers or subcontractors are to be added or deleted without prior notification to "
							+ attr.get("full_name") + ".", new Font(Font.TIMES_ROMAN, 8,
							Font.ITALIC));
			p.setLeading(10);
			cell = new Cell(p);
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.setLeading(15);
			cell.setBorder(0); table1.addCell(cell);
			p = new Phrase(
					"List the primary phases of your contracted scope of work and the associated costs.  This information may be released to the Owner if disputes arise over future billings and progress payments.",
					new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
			p.setLeading(12);
			cell = new Cell(p);
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell.setLeading(15);
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			cell
					.add(new Phrase(
							"Description/Phase of Work                     Labor                      Material                    Equipment/Tools       Sub-subcontractor     Total",
							tnr8));
			cell.setBorder(0); table1.addCell(cell);
			cell = new Cell();
			p = new Phrase(
					"________________________  $____________ $____________ $____________ $____________ $____________ \n",
					new Font(Font.TIMES_ROMAN, 10, Font.NORMAL));
			cell.setHorizontalAlignment("left");
			cell.setVerticalAlignment("middle");
			for (int i = 0; i < 13; i++) {
				cell.add(p);
			}
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
	
			document.add(spacer);
	
			table1 = new Table(1, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setOffset(2);
			table1.setPadding(1);
			cell = new Cell();
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			//cell.setLeading(10);
			cell.add(new Phrase(subName, new Font(Font.TIMES_ROMAN, 10,
					Font.UNDERLINE)));
			cell.add(new Phrase("\n" + cTitle, new Font(Font.TIMES_ROMAN,
					6, Font.ITALIC)));
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
			document.add(spacer);
			document.add(spacer);
	
			table1 = new Table(1, 1);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			table1.setOffset(0);
			cell = new Cell();
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			//cell.setLeading(10);
			cell.add(new Phrase("By:____________________________", new Font(
					Font.TIMES_ROMAN, 10, Font.NORMAL)));
			cell.add(new Phrase("\nPrint Name of Authorized Company Officer",
					new Font(Font.TIMES_ROMAN, 6, Font.ITALIC)));
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);
			document.add(spacer);
			document.add(spacer);
			table1 = new Table(1, 1);
			table1.setOffset(0);
			table1.setBorderWidth(0); table1.setWidth(100);
			//table1.setDefaultCellBorder(0);
			cell = new Cell();
			cell.setHorizontalAlignment("center");
			cell.setVerticalAlignment("middle");
			//cell.setLeading(10);
			cell.add(new Phrase("By:____________________________", new Font(
					Font.TIMES_ROMAN, 10, Font.NORMAL)));
			cell.add(new Phrase("\nAuthorized Signature", new Font(
					Font.TIMES_ROMAN, 6, Font.ITALIC)));
			cell.setBorder(0); table1.addCell(cell);
			document.add(table1);

		}

	}

	public static void main(String[] args) throws Exception {
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
}
