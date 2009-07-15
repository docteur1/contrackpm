package com.sinkluge.servlets;

import org.apache.commons.io.output.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.FileUploadBase.SizeLimitExceededException;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.util.Streams;
import org.apache.log4j.Logger;

import com.sinkluge.Info;
import com.sinkluge.UserData;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.utilities.ImageUtils;

public class UserPhoto extends HttpServlet {

	private static final long serialVersionUID = -50461397475755926L;
	
	public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws ServletException {
		response.setContentType("image/jpeg");
		response.setHeader ("Pragma", "expires");
		response.setHeader ("Cache-Control", "private");
		Logger log = Logger.getLogger(UserPhoto.class);
		HttpSession session = request.getSession();
		Attributes attr = (Attributes) session.getAttribute("attr");
		Info in = (Info) session.getServletContext().getAttribute("in");
		String userId = request.getParameter("user_id");
		log.debug("getting user photo");
		try {
			UserData user = UserData.getInstance(in, userId != null ? Integer.parseInt(userId) 
				: attr.getUserId());
			InputStream ins = user.getPhoto(in);
			ServletOutputStream out = response.getOutputStream();
			ImageUtils.genJPEGThumb(ins, out, 200, 200);
			out.flush();
			out.close();
		} catch (Exception e) {
			throw new ServletException("Error getting/writing photo", e);
		}
	}
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException {
		if (ServletFileUpload.isMultipartContent(request)) {
			Logger log = Logger.getLogger(UserPhoto.class);
			log.debug("uploading user phone");
			HttpSession session = request.getSession();
			Attributes attr = (Attributes) session.getAttribute("attr");
			Info in = (Info) session.getServletContext().getAttribute("in");
			try {
				ServletFileUpload upload = new ServletFileUpload();
				upload.setSizeMax(Integer.parseInt(in.upload_limit)*1000);
				FileItemStream item = null;
				int userId = attr.getUserId();
				ByteArrayOutputStream baos = null;
				String redirect = request.getContextPath() + "/admin/personalAdmin.jsp";
				for(FileItemIterator iter = upload.getItemIterator(request); iter.hasNext(); ) {
				    item = iter.next();
				    if (!item.isFormField()){
						if (item.getContentType().indexOf("jpeg") != -1 ||
								item.getContentType().indexOf("gif") != -1 ||
								item.getContentType().indexOf("png") != -1) {
							baos = new ByteArrayOutputStream();
							ImageUtils.genJPEGThumb(item.openStream(), baos, 400, 400);
				    	} else {
				    		PrintWriter out = response.getWriter();
							response.setContentType("text/html");
							out.println("<script>window.alert(\"Only JPEG, GIF, or PNG files allowed.\");history.back();</script>");
							out.flush();
							out.close();
				    	}
					} else {
						InputStream ins = item.openStream();
						if ("user_id".equals(item.getFieldName())) userId = 
							Integer.parseInt(Streams.asString(ins));
						else redirect = Streams.asString(ins);
					}
				}
				UserData user = UserData.getInstance(in, userId);
				user.setPhoto(in, baos);
				log.debug("Upload Complete");
				response.sendRedirect(redirect);
			} catch (SizeLimitExceededException e) {
				try {
					PrintWriter out = response.getWriter();
					response.setContentType("text/html");
					out.println("<script>window.alert(\"File too large!\\n----------------\\nThe uploaded file size was "
							+ e.getActualSize()/1000 + "K\\nThe permited size is " + 50 + "K\");"
							+ "parent.location.replace(parent.location);</script>");
					out.flush();
					out.close();
				} catch (IOException ie) {}
			} catch (Exception e) {
				log.error("Exception caught", e);
			} finally {
				log.debug("Cleaning up");
			}
		}
	}
	
}
