package com.sinkluge.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.output.ByteArrayOutputStream;

import kf.BinaryDocument;
import kf.KF;

public class ImageServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	public void service(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			KF kf = KF.getKF(request.getSession());
			BinaryDocument bd = null;
			if (kf != null) bd = kf.getProjectThumbnail(
					request.getParameter("id"));
			if (bd == null) throw new ServletException("Image not found");
			response.setContentType(bd.getContentType());
			ByteArrayOutputStream baos = bd.getStream();
			response.setContentLength(baos.size());
			ServletOutputStream out = response.getOutputStream();
			baos.writeTo(out);
			out.flush();
			out.close();
		} catch (Exception e) {
			throw new ServletException("Problem getting image", e);
		}
	}
	
}
