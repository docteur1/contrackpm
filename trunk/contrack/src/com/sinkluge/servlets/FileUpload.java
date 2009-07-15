package com.sinkluge.servlets;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.zip.DeflaterOutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.FileUploadBase.SizeLimitExceededException;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.util.Streams;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.log4j.Logger;

import com.sinkluge.Info;
import com.sinkluge.JSON.FileUploadStatus;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.utilities.DateUtils;
import com.sinkluge.utilities.FileUploadListener;
import com.sinkluge.utilities.Verify;

@SuppressWarnings("serial")
public class FileUpload extends HttpServlet {
	
	private static Logger log = Logger.getLogger(FileUpload.class);
	
	public static void setImageValue(HttpSession session, long docId, String type, String id, 
				String name, boolean val) throws Exception {
		Database db = new Database();
		log.debug("Updating/inserting image value: " + id + " " + name + " " + val);
		if (db.dbInsert("insert ignore into kf_documents (document_id, type, id, print, share) " +
				"values " +	"(" + docId + ", '" + type + "', " + id +
				("print".equals(name) && val ? ", 1" : ", 0") +
				("share".equals(name) && val ? ", 1" : ", 0") + ")") == 0)
			db.dbInsert("update kf_documents set type = '" + type + "', id = '" + id + "', " + 
				name + " = " + (val ? "1" : "0") + " where document_id = " + docId);
		db.disconnect();
	}
	
	public static void setFileValue(HttpSession session, int id, String name, boolean val) 
			throws Exception {
		Database db = new Database();
		log.debug("Updating file value: " + id + " " + name + " " + val);
		db.dbInsert("update files set " + name + " = " + (val ? "1" : "0") + " where file_id = " + id);
		db.disconnect();
	}
	
	// This to be called by JSON-RPC
	public static FileUploadStatus getStatus(HttpSession session, double id) {
		FileUploadStatus fus = new FileUploadStatus();
		FileUploadListener ful = (FileUploadListener) session.getAttribute("ful_" + id);
		log.debug("looking for status in session: ful_" + id);
		if (ful != null) {
			log.debug("Found Status id: ful_" + id + " in session");
			DecimalFormat df = new DecimalFormat("0.0");
			fus.setSent(df.format(ful.getBytesRead() / 1000));
			if (ful.getContentLength() != 0) {
				log.debug("Found length");
				fus.setPercent(df.format(ful.getBytesRead() * 100 / ful.getContentLength()));
				fus.setTotal(df.format(ful.getContentLength() / 1000));
			} else {
				log.debug("No length found");
				fus.setTotal("Unknown");
				fus.setPercent("Unknown");
			}
			// Throw over the listener if we are done.
			if (ful.getBytesRead() == ful.getContentLength()) {
				log.debug("Finished");
				fus.setFinished(true);
				session.removeAttribute("ful_" + id);
			}
		} else {
			log.debug("No status found in session");
			fus.setFinished(true);
		}
		return fus;
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
	}
			
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
		
		Logger log = Logger.getLogger(FileUpload.class);
		
		if (ServletFileUpload.isMultipartContent(request)) {
			HttpSession session = request.getSession();
			Database db = new Database();
			Attributes attr = (Attributes) session.getAttribute("attr");
			Info in = (Info) session.getServletContext().getAttribute("in");
			ResultSet rs = null;
			try {
				rs = db.dbQuery("select * from files where file_id = 0" , true);
				FileUploadListener listener = new FileUploadListener();
				ServletFileUpload upload = new ServletFileUpload();
				if (in != null) upload.setSizeMax(Integer.parseInt(in.upload_limit)*1000);
				if (log.isDebugEnabled()) log.debug("Size Max Set: " + upload.getSizeMax());
				upload.setProgressListener(listener);
				FileItemIterator iter = upload.getItemIterator(request);
				rs.moveToInsertRow();
				while (iter.hasNext()) {
					FileItemStream item = iter.next();
					InputStream ins = item.openStream();
				    if (item.isFormField()) {
				    	if ("upload_id".equals(item.getFieldName())) {
				    		String upload_id = Streams.asString(ins);
				    		session.setAttribute("ful_" + upload_id, listener);
				    		log.debug("Set session listener: ful_" + upload_id);
				    	} else rs.updateString(item.getFieldName(), Streams.asString(ins));
				    } else {
				    	ByteArrayOutputStream baos = new ByteArrayOutputStream();
				    	DeflaterOutputStream def = new DeflaterOutputStream(baos);
				    	InputStream is = item.openStream();
				    	IOUtils.copy(is, def);
				    	def.finish();
				    	is.close();
				    	is = null;
						rs.updateBytes(item.getFieldName(), baos.toByteArray());
						def.close();
						baos.close();
						baos = null;
						def = null;
						String filename = item.getName();
					    if (filename != null) {
					        filename = FilenameUtils.getName(filename);
					        if (filename != null) {
					        	filename = filename.replaceAll("#","");
					        	filename = filename.replaceAll("%","");
					        }
					    }
						rs.updateString("filename", filename);
						rs.updateString("content_type", item.getContentType());
						rs.updateLong("size", listener.getContentLength());
				    }
			    	ins.close();
				}
				if (attr != null) rs.updateString("uploaded_by", attr.getFullName());
				else rs.updateString("uploaded_by", "Unknown");
				rs.updateTimestamp("uploaded", DateUtils.getTimestamp());
				if (Verify.blank(rs.getString("description")))
					rs.updateString("description", rs.getString("filename"));
				rs.insertRow();
				rs.last();
				if (rs.getBoolean("protected")) {
					rs.updateBoolean("email", false);
					rs.updateRow();
				}
				log.debug("Upload Complete");
			} catch (SizeLimitExceededException e) {
				PrintWriter out = response.getWriter();
				response.setContentType("text/html");
				out.println("<script>window.alert(\"File too large!\\n----------------\\nThe uploaded file size was "
						+ e.getActualSize()/1000 + "K\\nThe permited size is " + in.upload_limit + "K\");"
						+ "parent.uploading=false;parent.location.replace(parent.location);</script>");
				out.flush();
				out.close();
			} catch (Throwable e) {
				log.error("Throwable caught", e);
				log.error("Cause", e.getCause());
			} finally {
				log.debug("Cleaning up");
				try {
					if (rs != null) rs.getStatement().close();
					if (db != null) db.disconnect();
				} catch (SQLException e) {}	
			}
		}
	}	
}
