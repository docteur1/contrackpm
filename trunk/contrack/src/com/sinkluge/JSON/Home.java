package com.sinkluge.JSON;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import accounting.Accounting;
import accounting.Route;

import com.sinkluge.Info;
import com.sinkluge.accounting.AccountingUtils;
import com.sinkluge.asterisk.Dialer;
import com.sinkluge.asterisk.Extension;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.fax.FaxStatus;
import com.sinkluge.security.Security;

public class Home {
	
	public static Project setProjectId(HttpSession session, HttpServletRequest request, int id) {
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		Security sec = (Security) session.getAttribute("sec");
		ResultSet rs = null;
		Project p = null;
		Logger log = getLogger();
		try {
			log.debug("Looking for project id " + id);
			String query = "select job_name, job_num, site_id from job where job_id = " + id;
			rs = db.dbQuery(query);
			if (rs.next()) {
				attr.setJobId(id);
				attr.setJobName(rs.getString(1));
				attr.setJobNum(rs.getString(2));
				attr.setSiteId(rs.getInt(3));
				attr.load();
				sec.setJob(id, request);
				p = new Project();
				p.setSiteName(attr.get("short_name"));
				// Send the permissions back as a map!!!
				p.setPerms(sec.getJSONPermissions());
				log.debug("Set job id to " + id);
			} else log.debug("Project not found");
		} catch (NullPointerException e) {
			log.error("Null Exception getting project list", e);
		} catch (Exception ne) {
			log.error("Exception getting project list", ne);
		} finally {
			try {
				rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
		}
		return p;
	}

	public static List<Project> getProjectList(HttpSession session, int limit) {
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		List<Project> projs = new ArrayList<Project>();
		String query = "select job_name, job_num, job.job_id from job ";
		switch (limit) {
		case 0:
			query += " join user_jobs using(job_id) where user_id = " + attr.getUserId();
			break;
		case 1:
			query += "where active = 'y'";
			break;
		}
		query += " order by costorder(job_num) desc";
		ResultSet rs = null;
		try {
			rs = db.dbQuery(query);
			Project p;
			while (rs.next()) {
				p = new Project();
				p.setProjectId(rs.getInt("job_id"));
				p.setProjectName(rs.getString("job_name"));
				p.setProjectNum(rs.getString("job_num"));
				p.setLimit(limit);
				projs.add(p);
			}
			if (projs.size() == 0 && limit < 2) {
				projs = getProjectList(session, limit + 1);
			}
		} catch (Exception e) {
			getLogger().error("Exception getting project list", e);
		} finally {
			try {
				rs.getStatement().close();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {}
		}
		return projs;
	}
	
	public static void destroySession(HttpSession session, String reason) {
		session.setAttribute("reason", reason);
		session.invalidate();
	}
	
	public static Message poll(HttpSession session) {
		Message message = new Message();
		Long lastAccessedTime = (Long) session.getAttribute("lastAccessedTime");
		ServletContext sc = session.getServletContext();
		Info in = (Info) sc.getAttribute("in");
		if (in != null) {
			// Default session is one hour...
			if (in.session_timeout == null) in.session_timeout = "60";
			// Give a three minute warning
			if ((lastAccessedTime + Long.parseLong(in.session_timeout)*60000 - 3*60000)
					< System.currentTimeMillis()) message.setPrekick(true);
		}
		String m = (String) session.getAttribute("message");
		if (m != null) {
			message.setMessage(m);
			session.removeAttribute("message");
		}
		FaxStatus fs = (FaxStatus) session.getAttribute("fax_status");
		if (fs != null) {
			message.setFaxMessage(fs.getMessage());
			if (fs.getQueue() == 0 && fs.resetMessage()) {
				session.removeAttribute("fax_status");
			}
		}
		if (session.getAttribute("kick") != null) {
			message.setKick(true);
			session.invalidate();
		}
		return message;
	}
	
	/*
	 * This method does nothing other than allow a RPC to reset the session timeout.
	 */
	public static void preventTimeout() {
		return;
	}
	
	private static Logger getLogger() {
		return Logger.getLogger(Home.class);
	}
	
	public static String getRoute(HttpSession session, int siteId, String id) 
			throws Exception {
		Logger log = getLogger();
		log.debug("getRoute(" + siteId + ", " + id + ") called");
		Accounting acc = AccountingUtils.getAccounting(session.getServletContext(), siteId);
		if (acc != null) {
			Route r = acc.getVoucherRouteByVoucher(id);
			if (r != null && r.getStatus() == Route.STATUS_PENDING) return r.getId();
			else return null;
		}
		else return null;
	}
	
	public static void setLogComment(String comment, String logId)
			throws Exception {
		Database db = new Database();
		ResultSet rs = db.dbQuery("select * from log where log_id = " + logId, 
			true);
		if (rs.first()) {
			rs.updateString("comment", comment);
			rs.updateRow();
		}
		rs.getStatement().close();
		db.disconnect();
	}
	
	public static String setError(HttpSession session, String id, String msg, String comment, boolean addInfo) {
		if (System.getProperty("com.sinkluge.Test") == null) {
			Database db = new Database();
			Attributes attr = (Attributes) session.getAttribute("attr");
			if (addInfo) {
				msg += "<br>User: " + attr.getFullName();
				msg += "<br>Browser: " + attr.getBrowser();
			}
			String sql = "select * from error_log where id = " + id;
			ResultSet rs = null;
			try {
				rs = db.dbQuery(sql, true);
				if (!rs.first()) rs.moveToInsertRow();
				rs.updateString("message", msg);
				rs.updateString("comments", comment);
				rs.updateInt("user_id", attr != null ? attr.getUserId() : 0);
				if (id == null) {
					rs.insertRow();
					rs.last();
					id = rs.getString("id");
				} else rs.updateRow();
			} catch (Exception e) {
				getLogger().error("setError", e);
			} finally {
				try {
					rs.getStatement().close();
					db.disconnect();
				} catch (SQLException e) {}
			}
			return id;
		} else return "0";
	}
	
	public static void dialNumber(HttpSession session, String number, String channel, String clid) 
			throws InterruptedException {
		Info in = (Info) session.getServletContext().getAttribute("in");
		if (in != null && in.hasAsterisk) {
			Dialer dialer = (Dialer) session.getAttribute("_dialer");
			if (dialer != null) dialer.disconnect();
			else {
				dialer = new Dialer(in);
				session.setAttribute("_dialer", dialer);
			}
			int count = 0;
			// Wait for extension list...
			while (!in.asteriskEndpointsReady && count < 5) {
				Thread.sleep(1000);
				count ++;
			}
			// Get the extension
			Extension ext = null;
			for (Iterator<Extension> i = in.asterisk_endpoints.iterator(); i.hasNext(); ) {
				ext = i.next();
				if (ext.getChannel().equals(channel)) break;
			}
			if (ext == null) dialer.changeStatus("Extension not found!");
			else dialer.dial(ext, number, clid);
		}
	}
	
	public static DialStatus getDialStatus(HttpSession session) {
		DialStatus ds = null;
		Dialer dialer = (Dialer) session.getAttribute("_dialer");
		if (dialer != null) {
			String log = "";
			for (String li : dialer.getLog()) {
				log += li + "<br/>";
			}
			ds = new DialStatus(log, dialer.getStatus(), dialer.isFinished());
			if (dialer.isFinished()) {
				session.removeAttribute("_dialer");
				getLogger().debug("removed _dialer session attribute");
			}
		}
		return ds;
	}
	
	public static void hangupCall(HttpSession session) {
		Dialer dialer = (Dialer) session.getAttribute("_dialer");
		if (dialer != null) {
			getLogger().debug("hangupCall: attempting");
			dialer.hangup();
			dialer.disconnect();
		}
	}
	
}
