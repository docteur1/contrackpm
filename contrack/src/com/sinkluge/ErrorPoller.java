package com.sinkluge;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.mail.ByteArrayDataSource;
import org.apache.commons.mail.MultiPartEmail;
import org.apache.log4j.Logger;

import com.sinkluge.database.Database;
import com.sinkluge.utilities.FormHelper;

public class ErrorPoller implements Runnable {

	private Info in;
	private Logger log = Logger.getLogger(ErrorPoller.class);
	
	public ErrorPoller(Info in) {
		this.in = in;
	}
	
	public void run() {
		log.debug("Starting ErrorPoller");
		Database db = null;
		ResultSet rs = null;
		try {
			db = new Database();
			if (in.notify_errors && in.admin_email != null && !"".equals(in.admin_email)) {
				rs = db.dbQuery("select * from error_log where sent = 0", true);
				if (rs.isBeforeFirst()) {
					rs.last();
					MultiPartEmail email = new MultiPartEmail();
					ByteArrayDataSource bads;
					email.setFrom(in.admin_email);
					email.addTo(in.admin_email);
					email.addHeader("X-Mailer", "Contrack - Project Management");
					email.setSubject("Contrack Errors: " + rs.getRow());
					email.setMsg("There are " + rs.getRow() + " new errors. See attached files.");
					email.setHostName(in.smtp_host);
					if (in.smtp_user != null && !"".equals(in.smtp_user)) {
						email.setAuthentication(in.smtp_user, in.smtp_pass);
					}
					rs.beforeFirst();
					while (rs.next()) {
						String msg = StringUtils.replace(rs.getString("message"), "<br>", "\n");
						msg = StringUtils.replace(msg, "&nbsp;", " ");
						msg = StringUtils.replace(msg, "<BR>", "\n");
						bads = new ByteArrayDataSource(FormHelper.string(rs.getString("comments"))
							+ "\n****************************************************************\n"
							+ FormHelper.timestamp(rs.getTimestamp("error_time")) + "\n" + msg, "text/plain");
						email.attach(bads, "Error_" + rs.getInt("id") + ".txt", "Error " + rs.getInt("id"));
						rs.updateBoolean("sent", true);
						rs.updateRow();
					}
					email.send();
				} else log.debug("No errors found");
			} else log.debug("Error Poller not run");
		} catch (Exception e) {
			log.error("Error in ErrorPoller service", e);
		} finally {
			log.debug("Finished ErrorPoller");
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				if (db != null) db.disconnect();
			} catch (SQLException e) {}			
		}
	}

}
