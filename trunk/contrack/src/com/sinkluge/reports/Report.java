package com.sinkluge.reports;

import org.apache.commons.io.output.ByteArrayOutputStream;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.HeaderFooter;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.PdfCopy;
import com.lowagie.text.pdf.PdfWriter;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;

public abstract class Report {
	
	protected ByteArrayOutputStream stream = null;
	protected Document document = null;
	protected PdfWriter writer = null;
	public String id;
	public Type type = null;
	public boolean attachments = true;
	
	public Report() {}
	
	public void init() throws DocumentException {
		init(36, 36, 36, 36);
	}
	
	public void init(Rectangle ps, HeaderFooter footer) throws DocumentException {
		init(ps, 36, 36, 36, 36, footer, null);
	}
	
	public void init(Rectangle ps, HeaderFooter footer, HeaderFooter header) throws DocumentException {
		init(ps, 36, 36, 36, 36, footer, header);
	}
	
	public void init(float arg0, float arg1, float arg2, float arg3) 
			throws DocumentException {
		init(PageSize.LETTER, arg0, arg1, arg2, arg3);
	}
	
	public void init(float arg0, float arg1, float arg2, float arg3, HeaderFooter footer) 
		throws DocumentException {
		init(PageSize.LETTER, arg0, arg1, arg2, arg3, footer, null);
	}
	
	public void init(Rectangle ps, float arg0, float arg1, float arg2, float arg3) 
			throws DocumentException {
		init(ps, arg0, arg1, arg2, arg3, null, null);	
	}
	
	public void init(Rectangle ps, float arg0, float arg1, float arg2, float arg3, HeaderFooter footer,
			HeaderFooter header) throws DocumentException {
		init(new Document(ps, arg0, arg1, arg2, arg3), footer, header);	
	}
	
	private void init(Document document, HeaderFooter footer, HeaderFooter header) throws DocumentException {
		this.document = document;
		stream = new ByteArrayOutputStream();
		writer = PdfWriter.getInstance(document, stream);
		if (footer != null) document.setFooter(footer);
		if (header != null) document.setHeader(header);
		document.open();
	}
	
	public void init(Rectangle ps) throws DocumentException {
		init(new Document(ps), null, null);
	}
	
	public PdfCopy getPdfCopy() throws DocumentException {
		stream = new ByteArrayOutputStream();
		document = new Document(PageSize.LETTER);
		PdfCopy copy = new PdfCopy(document, stream);
		document.open();
		return copy;
	}
	
	public ByteArrayOutputStream getStream(){
		if (stream != null && document != null && document.isOpen()) document.close();
		return stream != null ? stream.size() > 0 ? stream : null : null;
	}
	
	public abstract void create(Info in, Image logo) throws Exception;
	public abstract void doCleanup(Database db) throws Exception;
	public abstract ReportContact getReportContact(String id, Database db) throws Exception;

}