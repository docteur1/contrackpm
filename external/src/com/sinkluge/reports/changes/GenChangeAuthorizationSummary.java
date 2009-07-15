package com.sinkluge.reports.changes;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;

import org.apache.commons.io.output.ByteArrayOutputStream;

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

public class GenChangeAuthorizationSummary implements Report {

	ResultSet info;
	String jobName;
	boolean hasSummary = false;
	double original = 0;

	public void doCleanup(Database db) throws SQLException {
		if (info != null) info.getStatement().close();
		info = null;
	}
	
	public GenChangeAuthorizationSummary(Database db) throws Exception {
		String query;
		hasSummary = true;
		query = "select amount from contracts where contract_id = " + db.contract_id;
		info = db.dbQuery(query);
		if (info.first()) original = info.getDouble(1);
		info.getStatement().close();
		query = "select num, change_auth_num, work_description, crd.amount, "
			+ "crd.created, sent_date, sub_ca_num, company_name, cost_code, phase_code, division "
			+ "from change_request_detail as crd left join change_requests as cr using(cr_id) left join "
			+ "contracts using(contract_id) left join company using(company_id) left join job_cost_detail as jcd "
			+ "on crd.cost_code_id = jcd.cost_code_id where crd.contract_id = " + db.contract_id
			+ " and authorization = 1 order by change_auth_num";
		info = db.dbQuery(query);
		query = "select job_name from job where job_id = " + db.job_id;
		ResultSet rs = db.dbQuery(query);
		if (rs.first()) jobName = rs.getString("job_name");
		if (rs != null) rs.getStatement().close();
		rs = null;
	}//constructor
	
	public ByteArrayOutputStream create(Info in, Image logo) throws Exception {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		Document document = new Document(PageSize.LETTER.rotate(), 36, 36, 36, 36);
		PdfWriter writer = PdfWriter.getInstance(document, baos);
		writer.setEncryption(null, "3p(0pdf".getBytes(), PdfWriter.ALLOW_COPY | 
				PdfWriter.ALLOW_PRINTING, PdfWriter.STANDARD_ENCRYPTION_128);
		
		Font tnr = new Font(Font.TIMES_ROMAN, 9);
		Font tnrb = new Font(Font.TIMES_ROMAN, 9, Font.BOLD);
		
		Phrase p = new Phrase(jobName + " Change Authorization Summary      Page:  ", tnr);
		HeaderFooter footer = new HeaderFooter(p, true);
		footer.setAlignment(Element.ALIGN_CENTER);
		footer.setBorder(Rectangle.NO_BORDER);
		document.setFooter(footer);
		
		document.open();

		PdfPCell blank = new PdfPCell(new Phrase("", new Font(Font.HELVETICA, 6)));
		blank.setBorder(0);
		PdfPTable spacer = new PdfPTable(1);
		spacer.addCell(blank);

		PdfPTable table= new PdfPTable(9);
		int[] widths2 = {5, 5, 5, 8, 25, 9, 9, 9, 25};
		table.setWidths(widths2);
		table.setWidthPercentage(100);

		PdfPCell cell = new PdfPCell(new Phrase("Change Authorizations:   " 
				+ jobName, new Font(Font.TIMES_ROMAN, 16)));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setBackgroundColor(new Color(191,191,191));
		cell.setUseDescender(true);
		cell.setColspan(9);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase("CA #", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("CR #", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Sub #", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		table.addCell(cell);
		
		cell = new PdfPCell(new Phrase("Code", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Company", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Amount", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Created", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Sent", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);

		cell = new PdfPCell(new Phrase("Description", tnrb));
		cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);;
		//cell.setUseDescender(true);
		table.addCell(cell);
		
		table.setHeaderRows(2);

		DecimalFormat df = new DecimalFormat("$#,##0.00");
		double amount = 0;
		while(info.next()){
			amount += info.getDouble("amount");
			
			cell = new PdfPCell(new Phrase(info.getString("change_auth_num"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(DocHelper.string(info.getString("num")), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("sub_ca_num"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("division") + " " 
					+ info.getString("cost_code") + "-" + info.getString("phase_code"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(DocHelper.string(info.getString("company_name")),
					tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			table.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(info.getDouble("amount")),
					tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(DocHelper.date(info.getDate("created")), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(DocHelper.date(info.getDate("sent_date")), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_CENTER);
			table.addCell(cell);
			cell = new PdfPCell(new Phrase(info.getString("work_description"), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			table.addCell(cell);
		}
		
		cell = new PdfPCell(new Phrase("Total", tnrb));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		cell.setColspan(5);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase(df.format(amount), tnr));
		cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
		cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
		table.addCell(cell);
		cell = new PdfPCell(new Phrase(" "));
		cell.setColspan(3);
		table.addCell(cell);
		document.add(table);
		
		
		if (hasSummary) {
			PdfPTable table2 = new PdfPTable(2);
			int[] widths3 = {50, 50};
			table2.setWidths(widths3);
			table2.setWidthPercentage(30);
			table2.setSpacingBefore(10);
			
			cell = new PdfPCell(new Phrase("Orginal Contract", tnrb));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(original), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Changes", tnrb));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(amount), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase("Current Contract", tnrb));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			cell = new PdfPCell(new Phrase(df.format(amount + original), tnr));
			cell.setVerticalAlignment(Rectangle.ALIGN_TOP);
			cell.setHorizontalAlignment(Rectangle.ALIGN_RIGHT);
			table2.addCell(cell);
			
			table2.setKeepTogether(true);
			document.add(table2);
		}
		
		document.close();

		return baos;
	}
	
}
