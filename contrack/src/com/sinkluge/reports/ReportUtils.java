package com.sinkluge.reports;

import java.io.IOException;
import java.io.InputStream;
import java.sql.ResultSet;

import javax.servlet.http.HttpSession;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.log4j.Logger;

import com.lowagie.text.DocumentException;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.BadPdfFormatException;
import com.lowagie.text.pdf.Barcode39;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfCopy;
import com.lowagie.text.pdf.PdfImportedPage;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;
import com.lowagie.text.pdf.PdfWriter;
import com.sinkluge.database.Database;
import com.sinkluge.reports.documents.KFWImage;
import com.sinkluge.servlets.FileServlet;

public class ReportUtils {
	
	private static Logger log = Logger.getLogger(ReportUtils.class);

	public static Report getAppendableReport() {
		return new BlankReport();
	}
	
	public static void add(Report append, Report appendee, boolean stmp,
			byte[] pdfKey) throws DocumentException, IOException {
		PdfReader newPages = new PdfReader(new RandomAccessArray(append.getStream()), null);
		PdfReader original = null;
		PdfCopy copy;
		int originalPages = 0;
		int totalPages = 0;
		if (appendee.getStream() != null) {
			log.debug("Appendable report found");
			original = new PdfReader(new RandomAccessArray(appendee.getStream()), null);
			if (!original.isOpenedWithFullPermissions()) {
				original.close();
				original = new PdfReader(new RandomAccessArray(appendee.getStream()), pdfKey);
			}
			originalPages = original.getNumberOfPages();
			totalPages = originalPages;
			copy = appendee.getPdfCopy();
			addPages(copy, original);
		} else {
			log.debug("No appendable report found");
			copy = appendee.getPdfCopy();
		}
		totalPages += addPages(copy, newPages);
		
		log.debug("add: original report: " + originalPages + " new total: " + totalPages);
		
		if (stmp || pdfKey != null) {
			original = new PdfReader(new RandomAccessArray(appendee.getStream()), null);
			log.debug("add: ready to stamp " + original.getNumberOfPages() + " pages");
			appendee.stream = new ByteArrayOutputStream();
			PdfStamper stamp;
			if (original != null) 
				stamp = new PdfStamper(original, appendee.stream);
			else stamp = new PdfStamper(newPages, appendee.stream);
			if (pdfKey != null)
				stamp.setEncryption(null, pdfKey, PdfWriter.ALLOW_COPY
						| PdfWriter.ALLOW_PRINTING,
						PdfWriter.STANDARD_ENCRYPTION_128);
			PdfContentByte under;
			float offset = 0;
			Image image39 = null;
			if (stmp && append.type != null && append.id != null) {
				PdfContentByte fake = stamp.getOverContent(1);
				Barcode39 code39 = new Barcode39();
				code39.setCode(append.type.getCode() + append.id);
				code39.setStartStopText(false);
				image39 = code39.createImageWithBarcode(fake, null, null);
				image39.setRotationDegrees(270);
				offset = image39.getScaledWidth() + 10;
				for (int i = originalPages == 0 ? 1 : originalPages; i <= totalPages; i++) {
					under = stamp.getOverContent(i);
					image39.setAbsolutePosition(stamp.getReader()
							.getPageSizeWithRotation(i).getWidth()
							- offset, 10);
					under.addImage(image39);
				}
			}
			stamp.close();
		}
		if (original != null) original.close();
		newPages.close();
	}
	
	private static int addPages(PdfCopy copy, PdfReader reader) 
			throws BadPdfFormatException, IOException {
		PdfImportedPage pi;
		int pages = reader.getNumberOfPages();
		for (int i = 1; i <= pages; i++) {
			log.debug("addPages: importing page: " + i + " of " + pages);
			pi = copy.getImportedPage(reader, i);
			copy.addPage(pi);
		}
		copy.freeReader(reader);
		return pages;
	}
	
	public static void addAttachments(Report r, Database db, byte[] pdfKey, boolean encrypt, HttpSession session) 
			throws Exception {
		addAttachments(r, db, pdfKey, encrypt, true, session);
	}
	
	public static void addAttachments(Report r, Database db, byte[] pdfKey, 
			boolean encrypt, boolean stamp, HttpSession session) throws Exception {
		if (r.type != null && r.id != null) {
			PdfReader original = new PdfReader(new RandomAccessArray(r.getStream()), null);
			int orgPages = original.getNumberOfPages();
			int totalPages = orgPages;
			if (r.type.canPrint()) {
				PdfCopy copy = r.getPdfCopy();
				addPages(copy, original);
				/*
				 * Get the pdfs from the file table
				 */
				ResultSet rs = db.dbQuery("select file from files where id = '" + r.id + "' and type = '" 
					+ r.type.getCode() + "' and content_type like '%pdf' and print = 1 order by "
					+ "uploaded desc");
				PdfReader file = null;
				InputStream is;
				while (rs.next()) {
					is = FileServlet.getFileAsInputStream(rs);
					file = new PdfReader(is);
					is.close();
					if (!file.isOpenedWithFullPermissions()) {
						file.close();
						is = FileServlet.getFileAsInputStream(rs);
						file = new PdfReader(is, pdfKey);
						is.close();
						if (!file.isOpenedWithFullPermissions()) {
							file.close();
							log.debug("addAttachments: unable to open file");
							break;							
						}
					}
					totalPages += addPages(copy, file);				
				}
				rs.getStatement().close();
				/*
				 * Get the non-pdfs out of the file table
				 */
				rs = db.dbQuery(FileImage.getQuery(r.type, r.id));
				Report t = new FileImage(r.type, r.id, rs);
				ByteArrayOutputStream baos;
				t.create(null, null);
				baos = t.getStream();
				if (baos != null) {
					file = new PdfReader(new RandomAccessArray(baos), null);
					totalPages += addPages(copy, file);
				}
				/*
				 * Now look for images in KFW
				 */
				rs = db.dbQuery("select * from kf_documents where id = '" + r.id + "' and type = '"
					+ r.type.getCode() + "' order by document_id", true);
				while (rs.next() && rs.getBoolean("print")) {
					t = new KFWImage(rs.getString("document_id"), session);
					// If we don't have anything let's not add it DUH!
					baos = t.getStream();
					if (baos != null) {
						file = new PdfReader(
								new RandomAccessArray(baos), null);
						totalPages += addPages(copy, file);
					}
				}
				rs.getStatement().close();
			} // End is r.type.canPrint()
			/*
			 * Now stamp the pages
			 */
			if (stamp) {
				log.debug("addAttachments: Stamping the pages with: " + r.type.getCode() + r.id);
				original = new PdfReader(new RandomAccessArray(r.getStream()),
					null);
				r.stream = new ByteArrayOutputStream();
				PdfStamper stamper = new PdfStamper(original, r.stream);
				if (encrypt) {
					stamper.setEncryption(null, pdfKey, PdfWriter.ALLOW_COPY
							| PdfWriter.ALLOW_PRINTING,
							PdfWriter.STANDARD_ENCRYPTION_128);
					log.debug("addAttachments: setting encryption");
				}
				float offset = 0;
				Image image39 = null;
				PdfContentByte under;
				PdfContentByte fake = stamper.getOverContent(1);
				Barcode39 code39 = new Barcode39();
				code39.setCode(r.type.getCode() + r.id);
				code39.setStartStopText(false);
				image39 = code39.createImageWithBarcode(fake, null, null);
				image39.setRotationDegrees(270);
				offset = image39.getScaledWidth() + 10;
				BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, 
						BaseFont.WINANSI, BaseFont.EMBEDDED);
				for (int i = 1; i <= totalPages; i++) {
					under = stamper.getOverContent(i);
					image39.setAbsolutePosition(stamper.getReader()
							.getPageSizeWithRotation(i).getWidth() - offset, 10);
					under.addImage(image39);
					if (i > orgPages) {
						under.beginText();
				    	under.setFontAndSize(bf, 10);
				    	under.setTextMatrix(10, 10);
				    	under.showText("Contrack ID: " + r.type.getCode() + r.id + 
				    		"     Page: " + i + " of " + totalPages);
				    	under.endText();
					}
				}
				original.close();
				stamper.close();
			}
		}
	}
	
	public static void stamp(Report r) throws DocumentException, IOException {
		stamp(r, null, false);
	}
	
	public static void stamp(Report r, byte[] pdfKey, boolean footer) 
			throws DocumentException, IOException {
		if (r.type != null && r.id != null) stamp(r, pdfKey, footer, r.type.getCode() + r.id);
	}
	
	public static void stamp(Report r, byte[] pdfKey, boolean footer, String stmp) 
			throws DocumentException, IOException {
		PdfReader original = new PdfReader(new RandomAccessArray(r.getStream()),
				null);
		r.stream = new ByteArrayOutputStream();
		PdfStamper stamp = new PdfStamper(original, r.stream);
		if (pdfKey != null)
			stamp.setEncryption(null, pdfKey, PdfWriter.ALLOW_COPY
					| PdfWriter.ALLOW_PRINTING,
					PdfWriter.STANDARD_ENCRYPTION_128);
		int totalPages = original.getNumberOfPages();
		float offset = 0;
		Image image39 = null;
		PdfContentByte under;
		PdfContentByte fake = stamp.getOverContent(1);
		Barcode39 code39 = new Barcode39();
		code39.setCode(stmp);
		code39.setStartStopText(false);
		image39 = code39.createImageWithBarcode(fake, null, null);
		image39.setRotationDegrees(270);
		offset = image39.getScaledWidth() + 10;
		BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, 
				BaseFont.WINANSI, BaseFont.EMBEDDED);
		for (int i = 1; i <= totalPages; i++) {
			under = stamp.getOverContent(i);
			if (image39 != null) {
				image39.setAbsolutePosition(stamp.getReader()
						.getPageSizeWithRotation(i).getWidth()
						- offset, 10);
				under.addImage(image39);
				if (footer) {
					under.beginText();
			    	under.setFontAndSize(bf, 10);
			    	under.setTextMatrix(10, 10);
			    	under.showText("Contrack ID: " + stmp + 
			    		"     Page: " + i + " of " + totalPages);
			    	under.endText();
				}
			}
		}
		original.close();
		stamp.close();
	}

}
