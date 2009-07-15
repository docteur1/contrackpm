package com.sinkluge.reports.contracts;

import java.awt.Color;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.Phrase;
import com.lowagie.text.Table;
import com.sinkluge.Info;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.attributes.LienWaiver;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;
import com.sinkluge.utilities.BigString;

public class GenLienWaiver extends Report {
	
	private BigString txt;
	private LienWaiver lw;
	private String jobName, fullName;

	public GenLienWaiver(Attributes attr, Database db) throws Exception {
		lw = attr.getLienWaiver();
		id = lw.getId();
		type = lw.getDocType();
		jobName = attr.getJobName();
		fullName = attr.get("full_name");
		ResultSet rs = db.dbQuery("select txt from reports where id = 'lien" + lw.getType() + "'");
		if (rs.next()) txt = new BigString(rs.getString(1));
		if (rs != null) rs.getStatement().close();
		rs = null;
	}//constructor
	
	public void doCleanup(Database db) throws SQLException {
		//attr.setLienWaiver(null);
	}

	public void create(Info in, Image toplogo) throws Exception {
		init(15, 15, 36, 36);
		
		String company = lw.getCompanyName();
		String address1 = lw.getAddress();
		String address2 = lw.getCity() + ", " + lw.getState() + " " + lw.getZip();
		String phone = lw.getPhone();
		String fax = lw.getFax();

		DecimalFormat df = new DecimalFormat("$#,##0.00");

		Cell blank = new Cell(new Phrase("", new Font(Font.HELVETICA, 6)));
		blank.setBorder(0);
		Table spacer=new Table(1,1);
		spacer.setBorderWidth(0);
		//spacer.setDefaultCellBorderWidth(0);
		spacer.setWidth(100);
		spacer.setPadding(0);
		spacer.setSpacing(0);
		spacer.addCell(blank);

		Phrase p1 = new Phrase();
		Table table1=new Table(2,2);
		int[] widths= {60,40};
		table1.setWidths(widths);
		table1.setBorderWidth(0);
		//table1.setDefaultCellBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);
		toplogo.scalePercent(20);
		//Chunk ch1=new Chunk(toplogo, -10, -60);
		//p1.add(ch1);
		Cell cell=new Cell(toplogo);
		cell.setBorderWidth(0);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		table1.addCell(cell);

		cell= new Cell();
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("middle");
		cell.add(new Phrase("\n\n" + jobName + "\n\n ", new Font(Font.TIMES_ROMAN, 11, Font.BOLD)));
		cell.setBorder(0); table1.addCell(cell);

		p1=new Phrase(lw.getType().toUpperCase() + " LIEN WAIVER", new Font(Font.TIMES_ROMAN, 16, Font.BOLD));
		cell=new Cell(p1);
		cell.setHorizontalAlignment("center");
		cell.setVerticalAlignment("top");
		cell.setUseDescender(true);
		cell.setBackgroundColor(new Color(191, 191, 191));
		cell.setColspan(2);
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(2);
		table1.addCell(blank);
		blank.setColspan(1);

		cell = new Cell(new Phrase(company + "\n" + address1 + "\n" + address2, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setBorder(0); table1.addCell(cell);

		cell = new Cell(new Phrase("Phone:\t " + phone + "\nFax:\t" + fax, new Font(Font.TIMES_ROMAN, 12)));
		cell.setVerticalAlignment("middle");
		cell.setHorizontalAlignment("right");
		cell.setBorder(0); table1.addCell(cell);

		blank.setColspan(2);
		table1.addCell(blank);
		blank.setColspan(1);

		document.add(table1);

		table1 = new Table(1,1);
		//table1.setDefaultCellBorder(0);
		table1.setBorder(0);
		table1.setPadding(2);
		table1.setSpacing(2);

		blank.setBackgroundColor(new Color(225, 225, 225));
		table1.addCell(blank);
		blank.setBackgroundColor(new Color(255, 255, 255));

		SimpleDateFormat sdf = new SimpleDateFormat("EEEE, MMMM d, yyyy");
		txt.replaceAll("%c", fullName);
		txt.replaceAll("%n", jobName);
		txt.replaceAll("%y", lw.getJobCity());
		txt.replaceAll("%t", lw.getJobState());
		txt.replaceAll("%a", df.format(lw.getAmount()));
		txt.replaceAll("%d", sdf.format(lw.getDate()));
		txt.replaceAll("%s", company);
		
		cell = new Cell(new Phrase(txt.toString(), new Font(Font.TIMES_ROMAN, 12)));
		cell.setHorizontalAlignment("left");
		cell.setBorder(0); table1.addCell(cell);
		cell = new Cell(new Phrase("\n\n____________________________________________________________________________________________________________\n                 Signature                                                                  Title                                                              Date", new Font(Font.TIMES_ROMAN, 8)));
		cell.setHorizontalAlignment("center");
		cell.setBorder(0); table1.addCell(cell);

		document.add(table1);
	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}
}
