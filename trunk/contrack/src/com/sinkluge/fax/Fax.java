package com.sinkluge.fax;

import gnu.hylafax.Client;
import gnu.hylafax.HylaFAXClient;
import gnu.hylafax.HylaFAXClientProtocol;
import gnu.hylafax.Job;
import gnu.hylafax.Pagesize;
import gnu.hylafax.job.SendEvent;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.sql.ResultSet;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.sinkluge.Info;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public class Fax {
	
	public static String getFax(String phone) {
		String fax = phone;
		if (fax == null) return null;
		else return fax.replaceAll("\\D", "");
	}
	
	public static void logFax(String jobId, String fax, String document, String contact, String company,
			String description, HttpSession session) throws Exception {
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		ResultSet rs = db.dbQuery("select * from fax_log where fax_log_id = 0", true);
		rs.moveToInsertRow();
		rs.updateString("job_id", jobId);
		rs.updateString("fax", fax);
		rs.updateString("contact_name", contact);
		rs.updateString("company_name", company);
		rs.updateString("description", description);
		rs.updateString("document", document);
		rs.updateInt("user_id", attr.getUserId());
		rs.insertRow();
		rs.getStatement();
		db.disconnect();
		FaxStatus fs = (FaxStatus) session.getAttribute("fax_status");
		if (fs == null) {
			fs = new FaxStatus("Sending");
			session.setAttribute("fax_status", fs);
		} else fs.incrementQueue();
	}

	public static void updateStatus(String jobId, String status, String ss,
			Map<String, HttpSession> st) throws Exception {
		Logger log = Logger.getLogger(Fax.class);
		Database db = new Database();
		ResultSet rs = db.dbQuery("select * from fax_log where job_id = " + jobId, true);
		while (rs.next()) {
			log.debug("Found fax_log entry");
			String username = rs.getString("username");
			rs.updateString("status", status);
			rs.updateBoolean("viewed", false);
			rs.updateRow();
			HttpSession session = null;
			for (Iterator<Map.Entry<String, HttpSession>> i = st.entrySet().iterator(); i.hasNext();) {
				session = i.next().getValue();
				Attributes attr = (Attributes) session.getAttribute("attr");
				if (attr != null) {
					log.debug("Found session related to fax log entry");
					if (username.equals(attr.getUserName())) {
						FaxStatus fs = (FaxStatus) session.getAttribute("fax_status");
						if (fs != null) {
							if (log.isDebugEnabled()) {
								log.debug("Found fax_status with session reason: " + ss);
							}
							if (SendEvent.REASON_DONE.equals(ss) || SendEvent.REASON_KILLED.equals(ss)) {
								fs.decrementQueue();
								if (log.isDebugEnabled()) 
									log.debug("Remainging faxes in user queue: " + fs.getQueue());
								if (fs.getQueue() == 0) {
									fs.setMessage(status);
									fs.setResetMessage(true);
								}
							} else if (!SendEvent.REASON_REQUEUED.equals(ss)) {
								fs.setHasError(true);
								fs.setMessage(status);
								fs.setResetMessage(false);
							}
						}
					}
				}
			}
		}
		db.disconnect();
	}
	
	public static String sendPDF(String phone, byte[] file, Info in)
			throws Exception {
		return sendPDF(phone, new ByteArrayInputStream(file), in);
	}
	
	public static String sendPDF(String phone, InputStream is, Info in)
	throws Exception {
		//String killtime = "000259"; // -k
		String killtime = "000400";
		int maxdials = 6; // -T
		int maxtries = 3; // -t
		//int priority = 127; // -P
		//int resolution = 98; // -l, -m
		//int chopthreshold = 3;

		// pagesize= (Dimension)Job.pagesizes.get("na-let"); // default pagesize
		// is US Letter

		String job_id = "0";
		// get down to business, send the FAX already

		Client c = new HylaFAXClient();
		// try{
		c.open(in.fax_host);
		c.user(in.fax_user);
		if (in.fax_pass != null) c.pass(in.fax_pass);
		c.tzone(HylaFAXClientProtocol.TZONE_LOCAL);
		// c.mode(FtpClientProtocol.TYPE_IMAGE);
		c.setPassive(true);

		String remoteFilename = c.putTemporary(is);

		Job job = c.createJob(); // start a new job

		// add document to the job
		job.addDocument(remoteFilename);

		// set job properties
		// job.setNotifyAddress(user_email);
		job.setKilltime(killtime);
		job.setMaximumDials(maxdials);
		job.setMaximumTries(maxtries);
		//job.setPriority(priority);
		job.setDialstring(phone);
		//job.setVerticalResolution(resolution);
		job.setPageDimension(Pagesize.LETTER);
		job.setNotifyType(Job.NOTIFY_ALL);
		job.setNotifyAddress("contrack@nohost");
		//job.setChopThreshold(chopthreshold);

		job_id = Long.toString(job.getId());

		c.submit(job);

		c.quit();
		is.close();

		return job_id;
	}

}
