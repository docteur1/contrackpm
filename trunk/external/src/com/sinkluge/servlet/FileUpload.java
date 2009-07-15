package com.sinkluge.servlet;

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

import com.sinkluge.Info;

import com.sinkluge.database.Database;
import com.sinkluge.util.FileUploadListener;
import com.sinkluge.util.DateUtils;

@SuppressWarnings("serial")
public class FileUpload extends HttpServlet {

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
		
		PrintWriter out = response.getWriter();
		HttpSession session = request.getSession();
		FileUploadListener listener = (FileUploadListener) session.getAttribute("FULLIST");
		response.setContentType("text/xml");
		DecimalFormat df = new DecimalFormat("0.0");
		out.println("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>");
		out.println("<response>");
		long read = 0;
		long length = 0;
		if (listener != null) {
			read = listener.getBytesRead();
			length = listener.getContentLength();
		} 
		if (read == length && length != 0) {
			out.println("<finished />");
			session.removeAttribute("FULLIST");
		} else {
			if (length != 0) out.println("<percent>" + df.format(read * 100 / length) + "</percent>");
			else out.println("<percent>Unknown</percent>");
			out.println("<kbsent>" + df.format(read / 1000) + "</kbsent>");
			out.println("<totalkb>" + df.format(length / 1000) + "</totalkb>");
		}
		out.println("</response>");
		out.flush();
		out.close();
	}
			
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
		throws ServletException, IOException {
		System.out.println("starting upload");
		if (ServletFileUpload.isMultipartContent(request)) {
			HttpSession session = request.getSession();
			Database db = (Database) session.getAttribute("db");
			Info in = (Info) session.getServletContext().getAttribute("in");
			if (db == null) {
				try {
					db = new Database();
				} catch (Exception e) {
					if (db != null) db.disconnect();
				}
				session.setAttribute("db", db);
			}
			ResultSet rs = null;
			try {
				rs = db.dbQuery("select * from files where file_id = 0" , true);
				FileUploadListener listener = new FileUploadListener();
				session.setAttribute("FULLIST", listener);
				ServletFileUpload upload = new ServletFileUpload();
				if (in != null) upload.setSizeMax(Integer.parseInt(in.upload_limit)*1000);
				upload.setProgressListener(listener);
				FileItemIterator iter = upload.getItemIterator(request);
				rs.moveToInsertRow();
				while (iter.hasNext()) {
					FileItemStream item = iter.next();
					InputStream ins = item.openStream();
				    if (item.isFormField()) {
				        rs.updateString(item.getFieldName(), Streams.asString(ins));
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
						rs.updateInt("contact_id", db.contact_id);
				    }
			    	ins.close();
				}
				if (db != null) rs.updateString("uploaded_by", db.contact_name);
				else rs.updateString("uploaded_by", "Unknown");
				rs.updateTimestamp("uploaded", DateUtils.getTimestamp());
				rs.insertRow();
			} catch (SizeLimitExceededException e) {
				PrintWriter out = response.getWriter();
				response.setContentType("text/html");
				out.println("<script>window.alert(\"File too large!\\n----------------\\nThe uploaded file size was "
						+ e.getActualSize()/1000 + "K\\nThe permited size is " + in.upload_limit + "K\");"
						+ "parent.location.replace(parent.location);</script>");
				out.flush();
				out.close();
			} catch (Throwable e) {
				e.printStackTrace();
			} finally {
				try {
					if (rs != null) rs.getStatement().close();
				} catch (SQLException e) {}
				rs = null;
				db.disconnect();
			}
		}
	}	
}
