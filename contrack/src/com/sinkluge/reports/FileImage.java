package com.sinkluge.reports;

import java.io.InputStream;
import java.sql.ResultSet;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.log4j.Logger;

import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.RandomAccessFileOrArray;
import com.lowagie.text.pdf.codec.TiffImage;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.servlets.FileServlet;

public class FileImage extends Report {
	
	public static String getQuery(Type t, String id) {
		return "select * from files where id = '" + id + "' and type = '" + t.getCode() + 
			"' and content_type not like '%pdf%' and print = 1 order by uploaded desc";
	}
	
	ResultSet rs;
	Logger log = Logger.getLogger(FileImage.class);
	
	public FileImage(Type t, String id, ResultSet rs) {
		this.type = t;
		this.id = id;
		this.rs = rs;
	}
	
	public void create(Info in, Image logo) throws Exception {
		String content;
		init();
		InputStream is;
		if (!rs.isBeforeFirst()) {
			stream = null;
			return;
		}
		float pageX = PageSize.LETTER.getWidth();
        float pageY = PageSize.LETTER.getHeight();
		while (rs.next()) {
			content = rs.getString("content_type");
			if (content.equals("image/tiff")) {
				try {
					PdfContentByte cb = writer.getDirectContent();
	                RandomAccessFileOrArray ra = null;
	                int comps = 0;
	                try {
	                	is = FileServlet.getFileAsInputStream(rs);
	                    ra = new RandomAccessFileOrArray(is);
	                    is.close();
	                    comps = TiffImage.getNumberOfPages(ra);
	                }
	                catch (Throwable e) {
	                    System.out.println("Unable to open tiff file: " + 
	                    		rs.getString("description") + " " + e.toString());
	                    continue;
	                }
	                float X, Y;
	                for (int c = 0; c < comps; ++c) {
                        Image img = TiffImage.getTiffImage(ra, c + 1);
                        if (img != null) {
        					// Get the image size and guess the page size
        					X = img.getScaledWidth();
        					Y = img.getScaledHeight();
        					log.debug("tiff: X=" + X + " Y=" + Y);
        					if (X > Y) {
         						document.setPageSize(PageSize.LETTER.rotate());
         						img.scaleToFit(pageY, pageX);
         					} else {
         						document.setPageSize(PageSize.LETTER);
         						img.scaleToFit(pageX, pageY);
         					}
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
				ByteArrayOutputStream baos = FileServlet.getFileAsOutputStream(rs);
				Image img = Image.getInstance(baos.toByteArray());
				baos.close();
				float X,Y;
				if (img != null) {
					X = img.getScaledWidth();
					Y = img.getScaledHeight();
					log.debug("image: X=" + X + " Y=" + Y);
 					if (X > Y) {
 						document.setPageSize(PageSize.LETTER.rotate());
 						img.scaleToFit(pageY, pageX);
 					} else {
 						document.setPageSize(PageSize.LETTER);
 						img.scaleToFit(pageY, pageX);
 					}
 					img.setAbsolutePosition(0, 0);
					document.newPage();
					cb.addImage(img);
                }
			}
		}
	}

	public void doCleanup(Database db) throws Exception {
		rs.getStatement().close();
	}

	@Override
	public ReportContact getReportContact(String id, Database db) throws Exception {
		return null;
	}

}
