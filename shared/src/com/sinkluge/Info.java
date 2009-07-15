package com.sinkluge;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import org.apache.commons.lang.RandomStringUtils;
import org.apache.log4j.Logger;

import com.sinkluge.asterisk.Extension;
import com.sinkluge.database.Database;

public class Info implements java.io.Serializable {

	private static final long serialVersionUID = 1L;
	
	private Logger log;

	public Info () throws SQLException {
		log = Logger.getLogger(Info.class);
		loadProperties();
	}
	
	public String external_url, upload_limit, smtp_user, smtp_pass, path, build = null,
		default_group, search_base, bind_dn, bind_pw, alt_ldap_host, ldap_host, session_timeout, smtp_host,
		fax_user, fax_host, fax_pass, kf_endpoint, kf_username, kf_password,
		admin_email, key, user_class, pdf_key, site_url, asterisk_host, asterisk_user, 
		asterisk_pass, asterisk_context;
	
	public int asterisk_port, asterisk_prefix;
	
	public boolean asteriskEndpointsReady = false;
	public List<Extension> asterisk_endpoints = new ArrayList<Extension>();
	
	public boolean testMode = false, hasEmail = false, hasKF = false, 
		hasFax = false, notify_errors = false, hasAsterisk = false;
	
	public long startTime = 0;
	
	public String[] admin_groups;
	
	public void loadProperties() throws SQLException {
		Database db = new Database();
		ResultSet rs = null;
		try {
			rs = db.dbQuery("select * from settings where id = 'site'");
			Map<String, String> temp = new HashMap<String, String>();
			while (rs.next()) temp.put(rs.getString("name"), rs.getString("val"));
			rs.getStatement().close();
			rs = null;
			try {
				StringTokenizer st = new StringTokenizer(temp.get("admin_groups"), ",");
				admin_groups = new String[st.countTokens()];
				int count = 0;
				while (st.hasMoreTokens()) {
					admin_groups[count] = st.nextToken();
					count++;
				}
			} catch (NullPointerException e) {}
			smtp_host = temp.get("smtp_host");
			hasEmail = !blank(smtp_host);
			session_timeout = temp.get("session_timeout_mins");
			ldap_host = temp.get("ldap_host");
			alt_ldap_host = temp.get("alt_ldap_host");
			bind_dn = temp.get("bind_dn");
			bind_pw = temp.get("bind_pw");
			search_base = temp.get("searchbase");
			default_group = temp.get("default_group");
			smtp_user = temp.get("smtp_user");
			smtp_pass = temp.get("smtp_pass");
			upload_limit = temp.get("upload_limit");
			external_url = temp.get("external_url");
			fax_user = temp.get("fax_user");
			fax_host = temp.get("fax_host");
			fax_pass = temp.get("fax_pass");
			hasFax = !blank(fax_host);
			kf_endpoint = temp.get("kf_endpoint");
			kf_username = temp.get("kf_username");
			kf_password = temp.get("kf_password");
			notify_errors = "1".equals(temp.get("notify_errors"));
			admin_email = temp.get("admin_email");
			user_class = temp.get("user_class");
			key = temp.get("key");
			pdf_key = temp.get("pdf_key");
			site_url = temp.get("site_url");
			asterisk_host = temp.get("asterisk_host");
			try {
				asterisk_port = Integer.parseInt(temp.get("asterisk_port"));
			} catch (NumberFormatException e) {
				asterisk_port = 5038;
			}
			asterisk_user = temp.get("asterisk_user");
			asterisk_pass = temp.get("asterisk_pass");
			try {
				asterisk_prefix = Integer.parseInt(temp.get("asterisk_prefix"));
			} catch (NumberFormatException e) {
				asterisk_prefix = 6;
			}
			asterisk_context = temp.get("asterisk_context");
			hasAsterisk = !blank(asterisk_host);
			// Has a key been generated?
			if (blank(key)) {
				key = RandomStringUtils.randomAlphanumeric(40);
				rs = db.dbQuery("select * from settings where id = 'site' and name = 'key'", true);
				if (rs.first()) { 
					rs.updateString("val", key);
					rs.updateRow();
				}
				rs.getStatement().close();
				rs = null;
			}
			if (!blank(kf_endpoint)) {
				Object kf = null;
				try {
					kf = Class.forName("kf.KF");
				} catch (ClassNotFoundException e) {}
				hasKF = kf != null;
				kf = null;
			}
			temp.clear();
			temp = null;
		} catch (SQLException e) {
			log.fatal(e);
		} finally {
			try {
				if (rs != null) rs.getStatement();
				rs = null;
				db.disconnect();
			} catch (SQLException e) {}
		}
	}
	
	public static boolean blank(String s) {
		if (s == null || s.equals("")) return true;
		else if (s.matches("^\\s+$")) return true;
		else return false;
	}
}