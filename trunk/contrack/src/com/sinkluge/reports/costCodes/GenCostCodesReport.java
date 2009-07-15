package com.sinkluge.reports.costCodes;

import java.awt.Color;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;

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
import com.sinkluge.database.Database;
import com.sinkluge.reports.DocHelper;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

public class GenCostCodesReport extends Report {

	private ResultSet rs;
	private ResultSet div;
	private Hashtable<String, String> phases;
	private Hashtable<String, Integer> pL;
	private String job_name;
	private DecimalFormat df;
	private double contract_amount, owner_co, int_co;
	private int numP;

	public GenCostCodesReport (ResultSet rs, ResultSet div, Hashtable<String,String> phases, 
			String job_name, double contract_amount, double owner_co, double int_co,
			int job_id) {
		id = Integer.toString(job_id);
		type = com.sinkluge.Type.PROJECT;
		this.rs = rs;
		this.job_name = job_name;
		this.div = div;
		this.contract_amount = contract_amount;
		this.phases = phases;
		df = new DecimalFormat("#,##0.00");
		numP = phases.size();
		this.owner_co = owner_co;
		this.int_co = int_co;
		initPL();
		this.type = com.sinkluge.Type.PROJECT;
	}
	
	private void initPL() {
		pL = new Hashtable<String, Integer>(numP);
		Enumeration<String> e = phases.keys();
		for (int i = 0; e.hasMoreElements(); i++) {
			pL.put(e.nextElement(), new Integer(i));
		}
	}
	
	private int lookup(String p) {
		return pL.get(p).intValue();
	}
	
	public static Hashtable<String, String> getPhases(Database db) throws Exception {
		ResultSet rs = db.dbQuery("select letter, description from cost_types");
		Hashtable<String,String> ht = new Hashtable<String,String>();
		while (rs.next()) ht.put(rs.getString("letter"), rs.getString("description"));
		if (rs != null) rs.getStatement().close();
		rs = null;
		return ht;
	}
	
	public void doCleanup(Database db) throws Exception {
	}

	public static String getQuery(int jobId) {
		return "select division, cost_code, left(code_description, 25) as description, "
			+ "phase_code, estimate, budget, sum(ch.amount) as changes, cost_to_complete, "
			+ "percent_complete, pm_cost_to_date, sum(c.amount) as amount, "
			+ "sum(ch.fees) as fees, sum(ch.bonds) as bonds "
			+ "from job_cost_detail as jcd left join contracts as c on jcd.cost_code_id = "
			+ "c.cost_code_id left join changes as ch on jcd.cost_code_id = "
			+ "ch.cost_code_id where jcd.job_id = " + jobId + " group by jcd.cost_code_id "
			+ "order by costorder(division), "
			+ "costorder(cost_code), costorder(phase_code)";
	}
	
	public static String getQuery2(int jobId) {
		return "select division, description from job_divisions where job_id = " + jobId 
			+ " order by costorder(division)";
	}
	
	public static String getQuery3(int jobId) {
		return "select contract_amount_start from job where job_id = " + jobId;
	}
	
	public static String getQuery4(int jobId) {
		return "select sum(amount + fees + bonds) as amount from changes where job_id = " + jobId;
	}
	
	public static String getQuery5(int jobId) {
		return "select sum(crd.amount) as amount from change_request_detail as crd "
			+ "join contracts as c using(contract_id) left join change_requests as cr "
			+ "using(cr_id) where authorization = 1 and cr.title is null and "
			+ "c.job_id = " + jobId;
	}
	
	private PdfPTable getTable () throws Exception {
		int[] widths = {6,25,7,7,7,7,7,7,7,7,7,7};
		PdfPTable t = new PdfPTable(12);
		t.setWidthPercentage(100);
		t.setWidths(widths);
		//t.setBorderWidth(0);
		//t.setDefaultCellPadding(2);
		//t.setOffset(0);
		return t;
	}

	private PdfPTable getHeaderTable (PdfPTable ht) throws Exception {
		if (ht == null) ht = getTable();
		ht.addCell(getHeaderCell("Phase", "right"));
		ht.addCell(getHeaderCell("Description"));
		ht.addCell(getHeaderCell("Estimate", "right"));
		ht.addCell(getHeaderCell("Budget", "right"));
		ht.addCell(getHeaderCell("Contract", "right"));
		ht.addCell(getHeaderCell("Changes", "right"));
		ht.addCell(getHeaderCell("Fees", "right"));
		ht.addCell(getHeaderCell("Revised Budget", "right"));
		ht.addCell(getHeaderCell("Cost to Date", "right"));
		ht.addCell(getHeaderCell("Cost to Complete", "right"));
		ht.addCell(getHeaderCell("Est. Total Cost", "right"));
		ht.addCell(getHeaderCell("Perform", "right"));
		//ht.setTableFitsPage(true);
		//ht.setCellsFitPage(true);
		return ht;
	}

	private PdfPTable getHeaderTable() throws Exception {
		PdfPTable t = null;
		return getHeaderTable(t);
	}

	private PdfPCell getHeaderCell(String text, String horizontal_align) throws Exception {
		PdfPCell c = new PdfPCell(new Phrase(text, new Font(Font.HELVETICA, 8, Font.BOLD)));
		int align = Element.ALIGN_LEFT;
		if (horizontal_align.equals("right")) align = Element.ALIGN_RIGHT;
		c.setHorizontalAlignment(align);
		c.setBorder(Rectangle.BOTTOM);
		c.setBorderWidth(2);
		c.setVerticalAlignment(Element.ALIGN_MIDDLE);
		return c;
	}

	private PdfPCell getCell(String text, String horizontal_align, float size, int style, Color font_color, int border) throws Exception {
		PdfPCell c = new PdfPCell(new Phrase(text, new Font(Font.TIMES_ROMAN, size, style, font_color)));
		int align = Element.ALIGN_LEFT;
		if (horizontal_align.equals("right")) align = Element.ALIGN_RIGHT;
		c.setHorizontalAlignment(align);
		c.setBorder(border);
		//c.setLeading(7);
		c.setVerticalAlignment(Element.ALIGN_MIDDLE);
		return c;
	}

	private PdfPCell getCell(String text, Color font_color) throws Exception {
		return getCell(text, "right", 8, Font.NORMAL, font_color, Rectangle.NO_BORDER);
	}

	private PdfPCell getCell(String text, float size, int style, Color font_color) throws Exception {
		return getCell(text, "right", size, style, font_color, Rectangle.NO_BORDER);
	}

	private PdfPCell getCell(String text, float size, int style) throws Exception {
		return getCell(text, "right", size, style, Color.black, Rectangle.NO_BORDER);
	}

	private PdfPCell getCell(double num, float size, int style, Color font_color) throws Exception {
		return getCell(df.format(num), size, style, font_color);
	}

	private PdfPCell getCell(double num, float size, int style) throws Exception {
		return getCell(df.format(num), size, style);
	}

	private PdfPCell getCell(String text, int style) throws Exception {
		return getCell(text, 8, style);
	}

	private PdfPCell getCell(double num, int style) throws Exception {
		return getCell(df.format(num), style);
	}

	private PdfPCell getCell(double num, Color font_color) throws Exception {
		return getCell(df.format(num), font_color);
	}

	private PdfPCell getCell(String text, String horizontal_align) throws Exception {
		return getCell(text, horizontal_align, 8, Font.NORMAL, Color.black, Rectangle.BOTTOM);
	}

	private PdfPCell getCell(String text) throws Exception {
		return getCell(text, "right");
	}

	private PdfPCell getCell(double num) throws Exception {
		return getCell(df.format(num));
	}

	private PdfPCell getHeaderCell(String text) throws Exception {
		return getHeaderCell(text, "left");
	}

	private PdfPTable getHeaderTable (String division) throws Exception {
		PdfPTable ht = getTable();
		Phrase p = new Phrase(division, new Font(Font.TIMES_ROMAN, 8, Font.BOLD, Color.white));
		PdfPCell c = new PdfPCell(p);
		c.setColspan(13);
		c.setVerticalAlignment(Element.ALIGN_MIDDLE);
		c.setBackgroundColor(new Color(0, 102,0));
		c.setBorderWidth(0);
		//c.setLeading(7);
		ht.addCell(c);
		//ht.setTableFitsPage(true);
		//ht.setOffset(0);
		return ht;
	}

	private double[][] addArrays(double[][] one, double[][] two) {
		double[][] temp = new double[one.length][numP];
		for (int j = 0; j < numP; j++) {
			for (int i = 0; i < one.length; i++) temp[i][j] = one[i][j] + two[i][j];
		}
		return temp;
	}
	
	private double[] addArrays(double[][] one, double[] two) {
		double[] temp = new double[one.length];
		for (int i = 0; i < one.length; i++){
			for (int j = 0; j < numP; j++) temp[i] += one[i][j] + two[i];
		}
		return temp;
	}
	
	private double[][] addArrays(double[][] one, double[] two , int index) {
		double[][] temp = new double[one.length][numP];
		for (int j = 0; j < numP; j++) {
			for (int i = 0; i < one.length; i++) temp[i][j] = one[i][j];
		}
		for (int i = 0; i < one.length; i++) temp[i][index] = one[i][index] + two[i];
		return temp;
	}

	public void create(Info in, Image logo) throws Exception {

		
		SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");

		Phrase 	p = new Phrase(job_name + "          " + sdf.format(new Date()) + "          Page ", DocHelper.font(12, Font.BOLD));
		HeaderFooter header = new HeaderFooter(p, true);
		header.setAlignment(Element.ALIGN_CENTER);
		header.setBorder(Rectangle.BOTTOM);
		header.setBorderWidth(2);
		init(PageSize.LETTER.rotate(), 36, 42, 36, 36, null, header);

		final int ESTIMATE = 0;
		final int BUDGET = 1;
		final int CONTRACT = 2;
		final int CHANGE = 3;
		final int FEE = 4;
		final int REV_BUDGET = 5;
		final int CTD = 6;
		final int CTC = 7;
		final int ETC = 8;
		final int OVER = 9;

		double[][] array = new double[10][numP];
		double[][] totalTypeArray = new double[10][numP];
		double[] tempArray = new double[10];
		double[] totalArray = new double[10];

		String new_div = null, old_div = null, division, phase, cost_code;

		PdfPTable t = null;
		
		final Color[] COLOR = {/* Purple */ new Color(153,0,153), /* Blue */ new Color(51,0,255), 
			/* Yellow */ new Color(153,51,0), /* Green */ new Color(0,153,153)};

		PdfPCell c;
		int i = 0;
		Enumeration<String> e;
		String curP;

		boolean hasDivisionInfo = false;

		while (rs.next()) {
			cost_code = rs.getString("cost_code");
			new_div = rs.getString("division");
			if (new_div == null || new_div.equals("")) new_div = "01";
			// Are we in a new division?
			if (!new_div.equals(old_div)) {
				hasDivisionInfo = false;
				//Finish and spit out table
				if (t != null) {
					//t.complete();
					document.add(t);
				}
				// Unless as we are going through this the first time lets spit out some totals
				if (old_div != null) {
					// compute running totals
					totalTypeArray = addArrays(array, totalTypeArray);

					totalArray = new double[10];
					totalArray = addArrays(array, totalArray);

					t = getTable();
					//t.setTableFitsPage(true);
					// Spit out totals
					e = phases.keys();
					for (int cl = 0; e.hasMoreElements(); cl++) {
						curP = e.nextElement();
						c = getCell(phases.get(curP), COLOR[cl%4]);
						c.setColspan(2);
						t.addCell(c);
						for (i = 0; i < 10; i++) t.addCell(getCell(array[i][lookup(curP)], COLOR[cl%4]));
					}

					//t.complete();

					c = getCell("Division Total:", Font.BOLD);
					c.setColspan(2);
					t.addCell(c);
					for (i = 0; i < 10; i++) t.addCell(getCell(totalArray[i], Font.BOLD));

					//t.complete();

					c = getCell("");
					c.setColspan(13);
					t.addCell(c);

					//if (!writer.fitsPage(t)) document.newPage();
					t.setKeepTogether(true);
					document.add(t);

					// Zero out these array
					array = new double[10][numP];
				}
				// Does the division exist?
				while (div.next()) {
					division = div.getString("division");
					// Do we have the current division information spit out headers...
					if (new_div.equals(division)) {
						hasDivisionInfo = true;
						document.add(getHeaderTable("Division " + division + " - " + div.getString("description")));
						t = getHeaderTable();
						t.setHeaderRows(1);
						//t.endHeaders();
						break;
					}
				}
				// The division information doesn't exist but we still need to spit out the lines

				if (!hasDivisionInfo) {
					document.add(getHeaderTable("Division " + new_div));
					t = getHeaderTable();
					//t.endHeaders();
				}
				old_div = new_div;
			}

			phase = rs.getString("phase_code");
			tempArray[ESTIMATE] = rs.getDouble("estimate");
			tempArray[BUDGET] = rs.getDouble("budget");
			tempArray[CONTRACT] = rs.getDouble("amount");
			tempArray[CHANGE] = rs.getDouble("changes");
			tempArray[FEE] = rs.getDouble("fees") + rs.getDouble("bonds");
			tempArray[REV_BUDGET] = tempArray[BUDGET] + tempArray[CHANGE];
			tempArray[CTD] = rs.getDouble("pm_cost_to_date");
			tempArray[CTC] = rs.getDouble("cost_to_complete");
			tempArray[ETC] = tempArray[CTD] + tempArray[CTC];
			tempArray[OVER] = tempArray[REV_BUDGET] - tempArray[ETC];

			t.addCell(getCell(cost_code + "-" + phase));
			t.addCell(getCell(rs.getString("description"), "left"));
			for (i = 0; i < 10; i++) t.addCell(getCell(tempArray[i]));

			array = addArrays(array, tempArray, lookup(phase));

		}

		// spit out the last division totals if the table exists
		if (t != null) {
			document.add(t);
			totalTypeArray = addArrays(array, totalTypeArray);

			totalArray = new double[10];
			totalArray = addArrays(array, totalArray);

			t = getTable();
			//t.setTableFitsPage(true);
			// Spit out totals
			e = phases.keys();
			for (int cl = 0; e.hasMoreElements(); cl++) {
				curP = e.nextElement();
				c = getCell(phases.get(curP), COLOR[cl%4]);
				c.setColspan(2);
				t.addCell(c);
				for (i = 0; i < 10; i++) t.addCell(getCell(array[i][lookup(curP)], COLOR[cl%4]));
			}
			//t.complete();

			c = getCell("Total:", Font.BOLD);
			c.setColspan(2);
			t.addCell(c);
			for (i = 0; i < 10; i++) t.addCell(getCell(totalArray[i], Font.BOLD));
			//t.complete();

			c = getCell("");
			c.setColspan(13);
			t.addCell(c);

			document.add(t);

		}
		// Now spit out the end totals.

		t = getHeaderTable("GRAND TOTAL:");
		t = getHeaderTable(t);

		totalArray = new double[10];
		totalArray = addArrays(totalTypeArray, totalArray);

		// Spit out totals
		e = phases.keys();
		for (int cl = 0; e.hasMoreElements(); cl++) {
			curP = e.nextElement();
			c = getCell(phases.get(curP), COLOR[cl%4]);
			c.setColspan(2);
			t.addCell(c);
			for (i = 0; i < 10; i++) t.addCell(getCell(totalTypeArray[i][lookup(curP)], COLOR[cl%4]));
		}
		//t.complete();

		c = getCell("Total:", Font.BOLD);
		c.setColspan(2);
		t.addCell(c);
		for (i = 0; i < 10; i++) t.addCell(getCell(totalArray[i], Font.BOLD));
		//t.complete();

		c = getCell("");
		c.setColspan(13);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("Budget Performance:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		if (totalArray[OVER] < 0) c = getCell(totalArray[OVER], 12, Font.BOLD, Color.red);
		else c = getCell(totalArray[OVER], 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		c = getCell("");
		c.setColspan(5);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("Estimate Performance:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		double est_perform = totalArray[ESTIMATE] - totalArray[ETC];
		if (est_perform < 0) c = getCell(est_perform, 12, Font.BOLD, Color.red);
		else c = getCell(est_perform, 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		c = getCell("");
		c.setColspan(5);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("Orginal Contract:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		c = getCell(contract_amount, 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		c = getCell("");
		c.setColspan(5);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("Owner Approved Changes:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		c = getCell(owner_co, 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);


		c = getCell("");
		c.setColspan(5);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("Total Contract:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		c = getCell(contract_amount + owner_co, 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		c = getCell("");
		c.setColspan(5);
		c.setBorder(0);
		t.addCell(c);
		
		c = getCell("Internal Changes:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		c = getCell(int_co, 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		c = getCell("");
		c.setColspan(5);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("Estimated Total Final Cost:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		c = getCell(totalArray[ETC], 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		c = getCell("");
		c.setBorder(0);
		c.setColspan(5);
		t.addCell(c);

		c = getCell("Operating Income:", 12, Font.BOLD);
		c.setColspan(6);
		t.addCell(c);

		c = getCell(contract_amount + totalArray[CHANGE] + totalArray[FEE] - totalArray[ETC], 12, Font.BOLD);
		c.setColspan(2);
		t.addCell(c);

		if (contract_amount != 0) c = getCell(df.format((contract_amount + totalArray[CHANGE] + totalArray[FEE] 
              - int_co - totalArray[ETC])*100/contract_amount) + "%");
		else c = getCell("");
		c.setColspan(2);
		c.setBorder(0);
		t.addCell(c);

		c = getCell("");
		c.setColspan(3);
		c.setBorder(0);
		t.addCell(c);

		document.add(t);
	}

	public static void main(String[] args) {
		/*
		System.out.println("\nCreating PDF...\n\n");
		Database db = new Database();
		ResultSet rs = null;
		ResultSet div = null;
		String query = null;
		try{
			db.connect();

			String job_name = "Job Name";
			float contract_amount = 0;
			String job_num = "484";
			query = "select job_name, contract_amount_start from job where job_num = " + job_num;
			rs = db.dbQuery(query);
			if (rs.next()) {
				job_name = rs.getString("job_name");
				contract_amount = rs.getFloat("contract_amount_start");
			}
			if (rs !=null) rs.close();
			rs = null;

			// Build the rs
			query = "create temporary table co_temp (index(cost_code_id)) type = heap select cost_code_id, "
				+ "sum(unit_quantity * unit_amount + item_tax) as co_amount, sum(epco_labor + epco_markup + bonds_and_insurance) as co_add from change_order_detail as coi, "
				+ "change_orders as co where co.change_order_id = coi.change_order_id and job_num = " + job_num + " and status = 'Approved' and contingency_id = 0 "
				+ "group by cost_code_id";
			db.dbInsert(query);
			query = "create temporary table cont_temp (index(cost_code_id)) type = heap select cost_code_id, "
				+ "sum(unit_amount*unit_quantity + item_tax) as cont_amount, sum(epco_labor + epco_markup + bonds_and_insurance) as cont_add from change_order_detail as coi, "
				+ "change_orders as co where co.change_order_id = coi.change_order_id and job_num = " + job_num + " and status = 'Approved' and contingency_id "
				+ "!= 0 group by cost_code_id";
			db.dbInsert(query);
			query = "create temporary table cont_deduct (index(contingency_id)) type = heap select contingency_id, "
				+ "sum(unit_quantity * unit_amount + item_tax + epco_markup + epco_labor + bonds_and_insurance) as cont_deduct from change_order_detail as coi, "
				+ "change_orders as co where co.change_order_id = coi.change_order_id and job_num = " + job_num + " and status = 'Approved' and contingency_id "
				+ "!= 0 group by contingency_id";
			db.dbInsert(query);
			query = "select jcd.cost_code_id, cost_code, left(jcd.code_description, 30) as description, phase_code, estimate, budget, co_amount, "
				+ "cost_to_complete, percent_complete, pm_cost_to_date, c.amount, c.contract_id, contingency, co_amount, co_add, cont_amount, cont_add, cont_deduct from (((job_cost_detail as jcd left join contracts as c "
				+ "on jcd.cost_code_id = c.cost_code_id) left join co_temp on jcd.cost_code_id = co_temp.cost_code_id) left join cont_temp on jcd.cost_code_id = "
				+ "cont_temp.cost_code_id) left join cont_deduct on jcd.cost_code_id = cont_deduct.contingency_id where jcd.job_num = " + job_num + " order by jcd.cost_code_id";
			rs = db.dbQuery(query);

			query = "select division, description from divisions order by division";
			div = db.dbQuery(query);


			GenCostCodesReport gccr = new GenCostCodesReport(rs, div, job_name, contract_amount, 0);
			gccr.create();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) rs.close();
				rs = null;
				if (div != null) div.close();
				div = null;
				query = "drop table co_temp";
				db.dbInsert(query);
				query = "drop table cont_temp";
				db.dbInsert(query);
				query = "drop table cont_deduct";
				db.dbInsert(query);
				db.disconnect();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			System.out.println("\nComplete...\n");

		}
		*/

	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}

}
