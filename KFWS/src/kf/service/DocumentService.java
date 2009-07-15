package kf.service;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.List;

import javax.imageio.ImageIO;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import kf.Page;
import kf.config.Company;
import kf.config.Customerconfig;

import org.apache.cayenne.DataObjectUtils;
import org.apache.cayenne.access.DataContext;
import org.apache.cayenne.query.Ordering;
import org.apache.log4j.Logger;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.RandomAccessFileOrArray;
import com.lowagie.text.pdf.codec.TiffImage;

public class DocumentService extends HttpServlet  {

	private static final long serialVersionUID = 1L;
	private Logger log = Logger.getLogger(DocumentService.class);
	
	public void service(HttpServletRequest request, HttpServletResponse response) 
		throws ServletException {
		ServletContext application = getServletContext();
		DataContext context = DataContext.getThreadDataContext();
		String basepath = (String) application.getAttribute("basepath" + request.getParameter("config_id") 
				+ request.getParameter("company_id"));
		if (basepath == null) {
			Customerconfig cc = (Customerconfig) DataObjectUtils.objectForPK(context,
					Customerconfig.class, request.getParameter("config_id"));
			if (cc != null) {
				Company comp = (Company) DataObjectUtils.objectForPK(context, Company.class, 
					request.getParameter("company_id"));
				if (comp != null) {
					basepath = cc.getProjectRoot() + comp.getKeyName() + "/";
					application.setAttribute("basepath", basepath);
				} else throw new ServletException("Cannot find company for id: " 
						+ request.getParameter("company_id"));
			} else throw new ServletException("Cannot find customerconfig for id: " 
					+ request.getParameter("config_id"));
			
		}
		kf.Document doc = (kf.Document) DataObjectUtils.objectForPK(context, kf.Document.class, 
				request.getParameter("id"));
		ServletOutputStream out = null;
		if (doc != null) {
			log.debug("Found document in database");
			if (System.getProperty("com.sinkluge.Test") != null) 
				basepath = System.getProperty("com.sinkluge.test.KFPath");
			RandomAccessFileOrArray ra = null;
			Page p;
			List<Page> pages;
			try {
				out = response.getOutputStream();
				Ordering ord = new Ordering(Page.PAGE_ORDER_PROPERTY, true);
	        	/*
	        	 * This isn't going to work for individual documents 
	        	 * as it lumps them all together.
	        	 */
        		pages = (List<Page>) doc.getPages();
        		ord.orderList(pages);
        		int comps = 0;
        		Calendar cal = GregorianCalendar.getInstance();
        		cal.setTimeInMillis(doc.getDateCreated().longValue() * 1000);
        		DecimalFormat df = new DecimalFormat("00");
        		basepath = basepath + doc.getProject().getProjectName() + "/";
        		String pathToImage = basepath + cal.get(Calendar.YEAR) + "/" 
        			+ df.format(cal.get(Calendar.MONTH) + 1)
        			+ "/" + df.format(cal.get(Calendar.DAY_OF_MONTH)) + "/"
        			+ doc.getDocumentID() + "/";
        		if (request.getParameter("img") == null) {
	        		PdfWriter writer = null;
		        	Document document = null;
		        	PdfContentByte cb = null;
		        	int total = 0;
	        		for (Iterator<Page> it = pages.iterator(); it.hasNext();) {
	        			p = it.next();
	    	        	Image img;
	    	        	float X, Y;
		                if (document == null) {
		                	response.setHeader("Cache-Control", "private");
							response.setHeader("Pragma", "expires"); 
							response.setContentType("application/pdf");
		        			document = new Document(PageSize.LETTER, 0, 0, 0, 0);
		        			writer = PdfWriter.getInstance(document, out);
		        			document.open();
	        			}
		                cb = writer.getDirectContent();
	        			if (p.getExtension().indexOf("tif") != -1) {
	        				/*
	        				 * First we have to look in old KF location, then in the new
	        				 * because things get moved. Ridiculous.
	        				 */
	        				try {
	        					ra = new RandomAccessFileOrArray(basepath +
	        						doc.getDocumentID() + "/" +
	        	        				+ p.getPageID() + "." + p.getExtension());
        	    				if (log.isDebugEnabled()) log.debug("found file: " 
        	    					+ basepath +
	        						doc.getDocumentID() + "/" +
        	        				+ p.getPageID() + "." + p.getExtension());
	        				} catch (IOException e) {
	        					ra = new RandomAccessFileOrArray(pathToImage
	    	        				+ p.getPageID() + "." + p.getExtension());
	        					if (log.isDebugEnabled()) log.debug("found file: " 
        							+ pathToImage
	    	        				+ p.getPageID() + "." + p.getExtension());
	        				}
			                comps = TiffImage.getNumberOfPages(ra);
			                for (int c = 0; c < comps; c++) {
			                	total++;
			                    img = TiffImage.getTiffImage(ra, c + 1);
			                    if (img != null) {
			                    	// 8.5" = 612
			                    	// 11" = 792
			    					// Get the image size and guess the page size and orientation
			    					X = img.getScaledWidth();
			    					Y = img.getScaledHeight();
			    					if (X < Y) {
			    						document.setPageSize(PageSize.LETTER);
			    						img.scaleToFit(580, 750);
			    					}
			    					else {
			    						document.setPageSize(PageSize.LETTER.rotate());
			    						img.scaleToFit(750, 580);
			    					}
			    					document.newPage();
			    					// pixels/dpi = size in inches * 72 pt/in = pts
			    					img.setAbsolutePosition(0, 0);
			    					cb.addImage(img);
			    					img = null;
			                    }
							}
							ra.close();
							ra = null;
	        			} else {
	        				/*
	        				 * It's not a tif it's something else
	        				 */
	        				try {
	        					img = Image.getInstance(basepath +
	        						doc.getDocumentID() + "/" +
	        	        				+ p.getPageID() + "." + p.getExtension());
	        				} catch (IOException e) {
	        					img = Image.getInstance(pathToImage + p.getPageID() + "." 
	    							+ p.getExtension());
	        				}
	    					if (img != null) {
	        					X = img.getScaledWidth();
	        					Y = img.getScaledHeight();
	        					if (X < Y) {
		    						document.setPageSize(PageSize.LETTER);
		    						img.scaleToFit(612, 792);
		    					}
		    					else {
		    						document.setPageSize(PageSize.LETTER.rotate());
		    						img.scaleToFit(792, 612);
		    					}
	         					img.setAbsolutePosition(0, 0);
	        					//document.setPageSize(new Rectangle(pageX, pageY));
	        					document.newPage();
	        					// pixels/dpi = size in inches * 72 pt/in = pts
	        					cb.addImage(img);
	        					total++;
	    					}
	        			}
	        		}
					if (total > 0) {
		        		document.close();
						out.flush();
						out.close();
		        	}

	        	} else { // END request.getParameter("img") == null
	        		/*
	        		 * Generate the thumbnail of the first page
	        		 */
	        		p = pages.get(0);
	        		File f = new File(basepath +
						doc.getDocumentID() + "/" +
	        			+ p.getPageID() + "." + p.getExtension());
    				if (!f.exists()) f = new File(pathToImage + p.getPageID() + "." 
    					+ p.getExtension());
    				if (log.isDebugEnabled()) log.debug("found file: " 
    					+ f.getPath());
    				BufferedImage img = ImageIO.read(f);
    				if (log.isDebugEnabled()) { 
	    				String[] readerFormats = ImageIO.getReaderFormatNames();
						String msg = "ImageIO Reader Formats: ";
						for (int ix = 0; ix < readerFormats.length; ix++)
							msg += "\n" + readerFormats[ix];
						log.debug(msg);
    				}
    				f = null;
    				float sx = img.getWidth();
    				float sy = img.getHeight();
    				// We have to scale more in the x direction than the y
    				int x = 200;
    				int y = 200;
    				float rx = sx/x;
    				float ry = sy/y;
    				if(log.isDebugEnabled()) log.debug("Ratios " + Float.toString(rx) + "x" + Float.toString(ry));
    				if (x > sx && y > sy) {
    					x = img.getWidth();
    					y = img.getHeight();
    				} else {
    					if (rx > ry) y = Math.round(sy/rx);
    					else if (rx < ry) x = Math.round(sx/ry);
    				}
    				if(log.isDebugEnabled()) log.debug("Returning image with " + x + "x" + y + " orginally " 
    					+ sx + "x" + sy + ".");
    				BufferedImage image = new BufferedImage(x, y, 
    					BufferedImage.TYPE_INT_RGB);
    				image.createGraphics().drawImage(img, 0, 0, x, y, null);
    				response.setHeader ("Pragma", "expires");
    				response.setHeader ("Cache-Control", "private");
    				if ("tif".equals(p.getExtension())) {
	    				response.setContentType("image/png");
	    				ImageIO.write(image, "png", out);
    				} else {
    					response.setContentType("image/jpeg");
	    				ImageIO.write(image, "jpeg", out);
    				}
	        	}
			} catch (FileNotFoundException e) {
				log.error("Document files not found", e);
				throw new ServletException("Document files not found!", e);
			} catch(DocumentException e) {
				log.error(e.getMessage(), e);
				throw new ServletException("Error", e);
			} catch (IOException e) {
				log.error("IOException caught ", e);
				throw new ServletException(e);
			} finally {
				try {
					if (out != null) {
						out.close();
						out.flush();
					}
					if (ra != null) ra.close();
				} catch (IOException e) {
					throw new ServletException(e);
				}
			}
		} else throw new ServletException("Cannot find document for id: " + request.getParameter("id"));
	}
}
