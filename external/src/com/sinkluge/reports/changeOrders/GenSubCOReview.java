package com.sinkluge.reports.changeOrders;

import java.awt.Color;
import org.apache.commons.io.output.ByteArrayOutputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.sinkluge.Info;
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;

public class GenSubCOReview implements Report {

	private ResultSet contract;
	private ResultSet item;
	
	public void doCleanup(Database db) {
		try {
			if (contract != null) contract.getStatement().close();
			if (item != null) item.getStatement().close();
		} catch (SQLException e) {}
	}
	
	public GenSubCOReview (Database db) throws SQLException {
		String query1 = "select job.job_name, company.company_name, division, jcd.cost_code, jcd.phase_code," +
		" contracts.amount from contracts, company, job, job_cost_detail as jcd where job.job_id= "
		+ "contracts.job_id and contracts.company_id = company.company_id and "
		+ "jcd.cost_code_id = contracts.cost_code_id and contracts.contract_id = " + db.contract_id;
		contract = db.dbQuery(query1);
		query1 = "select change_orders.change_order_num, change_orders.description, change_order_detail.change_order_id, "
			+ "change_order_detail.sub_co_number, change_order_detail.item_number, change_order_detail.subject, change_orders.job_id, job.job_num, "
			+ "job.job_name, change_order_detail.status, change_order_detail.unit_amount, change_order_detail.unit_quantity, "
			+ "change_order_detail.bonds_and_insurance, change_order_detail.epco_markup, change_order_detail.item_tax from change_orders, "
			+ "change_order_detail, job where change_orders.change_order_id = change_order_detail.change_order_id and change_order_detail.contract_id = "
			+ db.contract_id + " and job.job_id = change_orders.job_id order by sub_co_number";
		item = db.dbQuery(query1);
	}
	
	
	public ByteArrayOutputStream create(Info in, Image toplogo) throws Exception{
		DocHelper dh = new DocHelper();
		Document document = new Document(PageSize.LETTER);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		writer.setEncryption(PdfWriter.STRENGTH128BITS, "","3p(0pdf", PdfWriter.AllowCopy | PdfWriter.AllowPrinting);
		//when creating based off this document, cut out from here---------------------
		
		contract.next();
		float amount = contract.getFloat("amount");
		String job_name = contract.getString("job_name");
		String company = contract.getString("company_name");
		String costCode = contract.getString("division") + " " + contract.getString("cost_code");
		String phaseCode = contract.getString("phase_code");

		float change_order_num = 0;
		int sub_co_number = 0;
		String item_number = "0";
		String co_desc, subject, status;
		float unit_amount = 0, unit_quantity = 0, net_cost =0;
		float total=0;
		DecimalFormat df = new DecimalFormat("$###,###,##0.00");
		DecimalFormat codf = new DecimalFormat("0.##");
		SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");

		//blank spacer for keeping tables apart
		PdfPTable spacer=new PdfPTable(1);
		/*
		spacer.setBorderWidth(0);
		spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		*/
		PdfPCell blank=new PdfPCell(new Phrase("", new Font(Font.TIMES_ROMAN, 1, Font.BOLD, new Color(255, 255, 255))));
		blank.setBorderWidth(0);
		//blank.setLeading(0);
		spacer.addCell(blank);

		//start of document
		Phrase p1 = new Phrase("Printed: " + sdf.format(new java.util.Date()),new Font(Font.TIMES_ROMAN, 8, Font.ITALIC));
		HeaderFooter footer = new HeaderFooter(p1,false);
		footer.setAlignment(Element.ALIGN_CENTER);
		footer.setBorder(Rectangle.NO_BORDER);
		document.setFooter(footer);
		document.open();


		Image blank1_0 = Image.getInstance(in.path + "/jsp/images/blank1_0.jpg");
		blank1_0.scalePercent(60);
		toplogo.scalePercent(20);


		/*
		Table table1=new Table(1,1);
		table1.setBorderWidth(0);
		table1.setDefaultCellBorder(0);
		table1.setPadding(3);
		*/

		PdfPTable table1 = new PdfPTable(2);
		//t.setBorder(0);
		//t.setDefaultPdfPCellBorder(0);
		table1.setWidthPercentage(100);

		PdfPCell cell = new PdfPCell(toplogo);
		dh.top(cell);
		cell.setPaddingBottom(4);
		cell.setBorder(0);
		table1.addCell(cell);

		Phrase name = new Phrase(job_name + "\n", dh.font(16));
		name.add(new Phrase("Subcontract CO Report", dh.font(14)));
		cell = new PdfPCell(name);
		dh.middle(cell);
		dh.center(cell);
		cell.setBorder(0);
		table1.addCell(cell);

		document.add(table1);

		table1 = new PdfPTable(1);
		table1.setWidthPercentage(100);

		p1 = new Phrase (costCode + "-" + phaseCode + ": " + company, dh.font(16, Font.BOLD));
		cell = new PdfPCell(p1);
		cell.setUseDescender(true);
		dh.center(cell);
		dh.middle(cell);
		dh.gray(cell);
		cell.setBorder(0);
		table1.addCell(cell);
		document.add(table1);
		document.add(spacer);

		//header cells
		table1=new PdfPTable(5);
		int[] widths1 = {5, 5, 57, 15, 15};
		table1.setWidths(widths1);
		table1.setWidthPercentage(100);

		//data cells
		float grand_total = 0;
		while (item.next()) {
			change_order_num = item.getFloat("change_order_num");
			sub_co_number = item.getInt("sub_co_number");
			co_desc = item.getString("description");
			if (co_desc==null) co_desc="";
			item_number = item.getString("item_number");
			subject = item.getString("subject");
			if (subject==null) subject = "";
			unit_amount = item.getFloat("unit_amount");
			unit_quantity = item.getFloat("unit_quantity");
			status = item.getString("status");
			//bonds_and_insurance = item.getFloat("bonds_and_insurance");
			//item_tax = item.getFloat("item_tax");
			//epco_markup = item.getFloat("epco_markup");

			net_cost = (unit_amount*unit_quantity);
			if (status.equals("Approved"))  {
				total += net_cost;
				grand_total += net_cost;
			}

			//first row
			table1.addCell(blank);

			
			if (change_order_num == -1) co_desc = "Backcharge";
			if (change_order_num == 0) co_desc = "";
			p1 = new Phrase(Integer.toString(sub_co_number), new Font(Font.TIMES_ROMAN, 8, Font.NORMAL));
			cell = new PdfPCell(p1);
			dh.top(cell);
			cell.setBackgroundColor(new Color(225, 225, 225));
			cell.setBorder(0);table1.addCell(cell);

			cell = new PdfPCell(new Phrase(co_desc, new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
			cell.setColspan(2);
			dh.top(cell);
			cell.setBackgroundColor(new Color(225, 225, 225));
			cell.setBorder(0);table1.addCell(cell);

			cell = new PdfPCell(new Phrase("CO# " + codf.format(change_order_num) + "-" + item_number, new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
			dh.top(cell);
			dh.right(cell);
			cell.setBackgroundColor(new Color(225, 225, 225));
			cell.setBorder(0);table1.addCell(cell);

			table1.addCell(blank);
			table1.addCell(blank);

			cell = new PdfPCell(new Phrase(subject, new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
			dh.top(cell);
			cell.setBorder(0);table1.addCell(cell);

			cell = new PdfPCell(new Phrase(df.format(net_cost), new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
			dh.right(cell);
			dh.top(cell);
			cell.setBorder(0);table1.addCell(cell);

			cell = new PdfPCell(new Phrase(status, new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)));
			dh.right(cell);
			dh.top(cell);
			cell.setBorder(0);table1.addCell(cell);
		}//end while
		//Spit out final total row


		document.add(table1);
		document.add(spacer);

		table1 = new PdfPTable(3);
		int[] widths2={72, 15, 12};
		table1.setWidths(widths2);
		cell = new PdfPCell(new Phrase("Total Approved Change Orders:", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		dh.right(cell);
		dh.middle(cell);
		cell.setBorder(0);table1.addCell(cell);

		cell = new PdfPCell(new Phrase(df.format(grand_total), new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		dh.right(cell);
		dh.middle(cell);
		cell.setBorder(0);table1.addCell(cell);

		table1.addCell(blank);
		
		cell = new PdfPCell(new Phrase("Original Contract Amount:", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		dh.right(cell);
		dh.middle(cell);
		cell.setBorder(0);
		table1.addCell(cell);

		cell = new PdfPCell(new Phrase(df.format(amount), new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		dh.right(cell);
		dh.middle(cell);
		cell.setBorder(0);
		table1.addCell(cell);

		table1.addCell(blank);


		cell = new PdfPCell(new Phrase("Current Approved Total:", new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)));
		dh.right(cell);
		dh.middle(cell);
		cell.setBorder(0);
		table1.addCell(cell);
		

		
		grand_total += amount;
		cell = new PdfPCell(new Phrase(df.format(grand_total), new Font(Font.TIMES_ROMAN, 10, Font.BOLD)));
		dh.right(cell);
		dh.middle(cell);
		cell.setBorder(0);
		table1.addCell(cell);
		table1.addCell(blank);
		document.add(table1);
		
		if (contract != null) contract.getStatement().close();
		contract = null;
		if (item != null) item.getStatement().close();
		item = null;
			// -----------------------to here--------------------

		document.close();
		return baos;
	}
/*
	public static void main(String[] args)throws Exception{
			database d = new database();
			d.connect();
			String success= "";
			String query1 = "select job.job_name, contracts.amount, company.company_name, contracts.description, contracts.cost_code_id, job_cost_detail.code_description from job_cost_detail, contracts, company, job where job.job_num=contracts.job_num and contracts.company_id = company.company_id and contracts.contract_id = 1231 and job_cost_detail.cost_code_id = contracts.cost_code_id";
			d.setQuery(query1);
			ResultSet contract = d.dbQuery();
			query1 = "select change_order.change_order_num, change_order.description, change_order_detail.category, change_order_detail.change_order_id, change_order_detail.sub_co_number, change_order_detail.item_number, change_order_detail.subject, change_order_detail.cost_code_id, change_order_detail.status, change_order_detail.unit_amount, change_order_detail.unit_quantity, change_order_detail.bonds_and_insurance, change_order_detail.epco_markup, change_order_detail.item_tax from change_order, change_order_detail where change_order.change_order_id = change_order_detail.change_order_id and change_order_detail.contract_id = 1231 order by sub_co_number desc, change_order_num, item_number";
			d.setQuery(query1);
			ResultSet item = d.dbQuery();
	    try{
	    	GenSubCOReview rfi = new GenSubCOReview(contract, item, 3);
		success = rfi.create();
		if (success.equals("success")) System.out.println("Success!");
		else System.out.println("There was an error:\n" + success);
    }catch(Exception e){
    	System.out.println("error!!!");
    	System.out.println(e.toString());
    }
	d.disconnect();
	}
	*/
}
