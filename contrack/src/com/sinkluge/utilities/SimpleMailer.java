package com.sinkluge.utilities;

import org.apache.commons.lang.text.StrTokenizer;
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.HtmlEmail;
import org.apache.commons.mail.SimpleEmail;
import org.apache.log4j.Logger;

import com.sinkluge.Info;

public class SimpleMailer {
	
	public static void sendMessage(String from, String fromName, String to, String subj, 
			String msgtext, Info in) throws EmailException {
		sendMessage(from, fromName, to, null, subj, msgtext, null, in);
	}
	
	public static void addRecipients(Email email, String to) throws EmailException {
		if (to.indexOf(",") != -1) {
			StrTokenizer st = new StrTokenizer(to, ",");
			while (st.hasNext()) email.addTo(st.nextToken());
		} else if (to.indexOf(";") != -1) {
			StrTokenizer st = new StrTokenizer(to, ";");
			while (st.hasNext()) email.addTo(st.nextToken());
		} else email.addTo(to);
	}
	
	public static void sendMessage(String from, String fromName, String to, String cc, String subj, 
			String msgtext, String content, Info in) throws EmailException {
		Email email = null;
		if ("text/html".equals(content)) {
			email = new HtmlEmail();
			((HtmlEmail) email).setHtmlMsg(msgtext);
		} else {
			email = new SimpleEmail();
			email.setMsg(msgtext);
		}
		email.setFrom(from, fromName);
		addRecipients(email, to);
		if (cc != null) email.addCc(cc);
		email.addHeader("X-Mailer", "Contrack - Project Management");
		email.setSubject(subj);
		email.setHostName(in.smtp_host);
		Logger log = Logger.getLogger(SimpleMailer.class);
		if (in.smtp_user != null && !"".equals(in.smtp_user)) {
			log.debug("Setting SMTP Auth");
			email.setAuthentication(in.smtp_user, in.smtp_pass);
		}
		if (System.getProperty("com.sinkluge.test.disableEmail") == null) {
			email.send();
			log.debug("Email Sent. To: " + to + " From: " + from + " Type: " + content);
		} else log.debug("Email Not Sent. To: " + to + " From: " + from + " Type: " + content);	
	}
}