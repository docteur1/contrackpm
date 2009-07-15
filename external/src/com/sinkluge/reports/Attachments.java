package com.sinkluge.reports;

import org.apache.commons.io.output.ByteArrayOutputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.zip.InflaterInputStream;

import com.lowagie.text.Document;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.Barcode39;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.RandomAccessFileOrArray;
import com.lowagie.text.pdf.codec.TiffImage;
import com.sinkluge.database.Database;

public class Attachments {

	public static ByteArrayOutputStream addPDFAttachmentsAndStamp(String id, String t, int orgPages, byte[] in) 
		throws Exception {
		ResultSet rs = null;
		Database db = null;
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		try {
			db = new Database();
			rs = db.dbQuery("select file from files where id = '" + id + "' and type = '" + t + 
					"' and content_type like '%pdf' and print = 1 and protected = 0 order by uploaded desc");
			PdfReader orginal = new PdfReader(in, "3p(0pdf".getBytes());
			PdfStamper stamp = new PdfStamper(orginal, baos);
			stamp.setEncryption(null, "3p(0pdf".getBytes(), PdfWriter.ALLOW_COPY | 
					PdfWriter.ALLOW_PRINTING, PdfWriter.STANDARD_ENCRYPTION_128);
			PdfReader file = null;
			PdfContentByte under;
			int totalPages = orginal.getNumberOfPages();
			int curOriginalPages = orginal.getNumberOfPages();
			while (rs.next()) {
				file = new PdfReader(new InflaterInputStream(rs.getBinaryStream("file")));
				for (int i = 1; i <= file.getNumberOfPages(); i++) {
					// BlankPage
					totalPages++;
					stamp.insertPage(curOriginalPages + i, file.getPageSizeWithRotation(i));
					under = stamp.getOverContent(curOriginalPages + i);
					under.addTemplate(stamp.getImportedPage(file, i), 1, 0, 0, 1, 0, 0);
				}
				file = null;
			}
			// Stamp the cramp out of them...
			PdfContentByte fake = stamp.getOverContent(1);
			Barcode39 code39 = new Barcode39();
			code39.setCode(t + id);
			code39.setStartStopText(false);
			Image image39 = code39.createImageWithBarcode(fake, null, null);
			image39.setRotationDegrees(270);
			BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.WINANSI, BaseFont.EMBEDDED);
			float offset = image39.getScaledWidth() + 10;
			for (int i  = orgPages + 1; i <= totalPages; i++) {
				under = stamp.getOverContent(i);
				image39.setAbsolutePosition(stamp.getReader().getPageSizeWithRotation(i).getWidth() - offset,
						10);
				under.addImage(image39);
				under.beginText();
            	under.setFontAndSize(bf, 10);
            	under.setTextMatrix(10, 10);
            	under.showText("Contrack ID: " + t + id + "     Page: " + i + " of " + totalPages);
            	under.endText();
			}
			stamp.close();
			orginal = null;
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try { 
				if (rs != null) rs.getStatement().close();
				rs = null;
				db.disconnectFinal();
				db = null;
			} catch (SQLException se) {}
		}
		return baos;
	}
	
	
	public static void addImageAttachments(String id, String t, PdfWriter writer, Document document) 
		throws Exception {
		ResultSet rs = null;
		Database db = null;
		try {
			db = new Database();
			rs = db.dbQuery("select * from files where id = '" + id + "' and type = '" + t + 
					"' and content_type not like '%pdf%' and print = 1 and protected = 0 order by uploaded desc");
			String content;
			if (rs.isBeforeFirst()) {
				document.resetFooter();
				document.resetHeader();
			}
			while (rs.next()) {
				content = rs.getString("content_type");
				if (content.equals("image/tiff")) {
					try {
						PdfContentByte cb = writer.getDirectContent();
		                RandomAccessFileOrArray ra = null;
		                int comps = 0;
		                try {
		                    ra = new RandomAccessFileOrArray(new InflaterInputStream(rs.getBinaryStream("file")));
		                    comps = TiffImage.getNumberOfPages(ra);
		                }
		                catch (Throwable e) {
		                    System.out.println("Unable to open tiff file: " + rs.getString("description") + " " + e.toString());
		                    continue;
		                }
		                float X, Y;
		                for (int c = 0; c < comps; ++c) {
	                        Image img = TiffImage.getTiffImage(ra, c + 1);
	                        if (img != null) {
	                        	// 8.5" = 612
	                        	// 11" = 792
	                        	img = TiffImage.getTiffImage(ra, c + 1);
	        					// Get the image size and guess the page size
	        					X = img.getScaledWidth();
	        					Y = img.getScaledHeight();
	        					if (X < Y) document.setPageSize(PageSize.LETTER);
	        					else document.setPageSize(PageSize.LETTER.rotate());
	         					if (X > 612) img.scalePercent(612*100/X);
	         					if (Y > 792) img.scalePercent(792*100/Y);
	        					document.newPage();
	        					// pixels/dpi = size in inches * 72 pt/in = pts
	        					img.setAbsolutePosition(0, 0);
	        					cb.addImage(img);
	                        }
						}
						ra.close();
					} catch (Throwable e) {
						e.printStackTrace();
					}
					// some other image...
				} else {
					PdfContentByte cb = writer.getDirectContent();
					InflaterInputStream iis = new InflaterInputStream(rs.getBinaryStream("file"));
					ByteArrayOutputStream baos = new ByteArrayOutputStream();
					int b = 0;
					do {
						b = iis.read();
						baos.write(b);
					} while (b != -1);
					iis.close();
					Image img = Image.getInstance(baos.toByteArray());
					baos.close();
					float X,Y;
					if (img != null) {
    					X = img.getScaledWidth();
    					Y = img.getScaledHeight();
     					if (X < Y) document.setPageSize(PageSize.LETTER);
    					else document.setPageSize(PageSize.LETTER.rotate());
     					if (X > 612) img.scalePercent(612*90/X);
     					if (Y > 792) img.scalePercent(792*90/Y);
     					if (X < Y) img.setAbsolutePosition(612*0.05f, 792*0.05f);
     					else img.setAbsolutePosition(792*0.05f, 612*0.05f);
    					//document.setPageSize(new Rectangle(pageX, pageY));
    					document.newPage();
    					// pixels/dpi = size in inches * 72 pt/in = pts
    					cb.addImage(img);
                    }
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try { 
				if (rs != null) rs.getStatement().close();
				rs = null;
				db.disconnectFinal();
				db = null;
			} catch (SQLException se) {}
		}

	}
	
}
