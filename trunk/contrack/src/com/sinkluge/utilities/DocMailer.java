package com.sinkluge.utilities;

import java.io.IOException;
import java.io.InputStream;
import java.sql.ResultSet;

import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.MultiPartEmail;
import org.apache.commons.mail.ByteArrayDataSource;
import org.apache.log4j.Logger;

import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.database.Database;
import com.sinkluge.servlets.FileServlet;

public class DocMailer {
	
	private MultiPartEmail email;
	private String from, fromName, msgtext, to = null, subj = null;
	private Info in;
	
	public DocMailer(String from, String fromName, String to, String subj, 
			String msgtext, Info in) throws EmailException {
		this.from = from;
		this.fromName = fromName;
		this.to = to;
		this.subj = subj;
		this.in = in;
		this.msgtext = msgtext;
		email = getMPE();
	}
	
	public DocMailer(String from, String fromName, String msgtext, Info in) throws EmailException {
		this.from = from;
		this.fromName = fromName;
		this.in = in;
		this.msgtext = msgtext;
		email = getMPE();
	}
	
	public void removeAttachments() throws EmailException {
		email = getMPE();
	}
	
	public void addFiles(Type type, String id, Database db) throws Exception {
		ResultSet rs = db.dbQuery("select * from files where type = '" + type.getCode()
				+ "' and " + "id = '" + id + "' and email = 1");
		InputStream is;
		while (rs.next()) {
			is = FileServlet.getFileAsInputStream(rs);
			addFile(rs.getString("filename"), rs.getString("description"),
				rs.getString("content_type"), is);
			is.close();
		}
	}
	
	public void addFile(String fileName, String description, String type, InputStream in) 
			throws IOException, EmailException { 
		ByteArrayDataSource bads = new ByteArrayDataSource(in, type);
		email.attach(bads, fileName, description);
	}
	
	public void addFile(String fileName, String description, String type, byte[] file) 
			throws IOException, EmailException {
		ByteArrayDataSource bads = new ByteArrayDataSource(file, type);
		email.attach(bads, fileName, description);
	}
	
	public void addTo(String to) throws EmailException {
		email.addTo(to);
	}
	
	public void setSubject(String subj) throws EmailException {
		email.setSubject(subj);
	}
	
	public void send() throws EmailException {
		Logger log = Logger.getLogger(DocMailer.class);
		if (System.getProperty("com.sinkluge.test.disableEmail") == null) {
			email.send();
			log.debug("Email Sent.");
		} else log.debug("Email Not Sent.");
	}
		
	
	private MultiPartEmail getMPE() throws EmailException {
		MultiPartEmail email = new MultiPartEmail();
		email.setFrom(from, fromName);
		email.addHeader("X-Mailer", "Contrack - Project Management");
		email.setMsg(msgtext);
		if (subj != null) email.setSubject(subj);
		if (to != null) SimpleMailer.addRecipients(email, to);
		email.setHostName(in.smtp_host);
		Logger log = Logger.getLogger(DocMailer.class);
		if (in.smtp_user != null && !"".equals(in.smtp_user)) {
			log.debug("Using SMTP Auth");
			email.setAuthentication(in.smtp_user, in.smtp_pass);
		}
		return email;
	}
	
	public static void sendMessage(String from, String fromName, String to, String fileName, String subj, 
			String msgtext, byte[] file, Info in) throws IOException, EmailException {
		DocMailer dm = new DocMailer(from, fromName, to, subj, msgtext, in);
		dm.addFile(fileName, "Document", "application/pdf", file);
		Logger log = Logger.getLogger(DocMailer.class);
		if (System.getProperty("com.sinkluge.test.disableEmail") == null) {
			dm.send();
			log.debug("Email Sent. To: " + to + " From: " + from + " File: " + fileName);
		} else log.debug("Email Not Sent. To: " + to + " From: " + from + " File: " + fileName);	
	}
}
