package com.sinkluge.attributes;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

import com.sinkluge.database.Database;

public class Attributes implements java.io.Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private boolean accounting = false;
	private int userId = 0;
	private int siteId = 0;
	private int jobId;
	private String userName;
	private String email;
	private String fullName;
	private int fontSize = 8;
	private String div;
	private String jobName;
	private String jobNum;
	private LienWaiver lienWaiver;
	private String info;
	private String browser;
	private HashMap<String,String> ht = null;
	private String laborTypes = "";
	
	public Attributes() {
		
	}
	
	public Attributes(int siteId) throws Exception {
		this.siteId = siteId;
		load();
	}
	
	public String get(String key) {
		if (ht != null) return ht.get(key);
		else return null;
	}
	
	public void close() {
		ht.clear();
		ht = null;
	}
	
	public boolean hasAccounting() {
		return accounting;
	}
	
	public void load() throws SQLException {
		if (siteId != 0) {
			Database db = new Database();
			ResultSet rs = null;
			try {
				rs = db.dbQuery("select name, val from settings where id = 'site" + siteId + "'");
				if (ht == null) ht = new HashMap<String, String>();
				else if (ht.size() != 0) ht.clear();
				while (rs.next()) {
					ht.put(rs.getString("name"), rs.getString("val"));
				}
				if (rs != null) rs.getStatement().close();
				accounting = ht.get("acc_endpoint") != null && !"".equals(ht.get("acc_endpoint"));
				laborTypes = "";
				rs = db.dbQuery("select letter from cost_types where labor = 1 and site_id = " + siteId);
				while (rs.next()) laborTypes += rs.getString(1);
			} finally {
				try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
				} catch (SQLException e) {}
			}
			
			
		}
	}

	public boolean isLabor(String phase) {
		return laborTypes.indexOf(phase) != -1;
	}
	
	public String getBrowser() {
		return browser;
	}
	public void setBrowser(String browser) {
		this.browser = browser;
	}
	public LienWaiver getLienWaiver() {
		return lienWaiver;
	}
	public void setLienWaiver(LienWaiver lienWaiver) {
		this.lienWaiver = lienWaiver;
	}
	public String getJobNum() {
		return jobNum;
	}
	public void setJobNum(String jobNum) {
		this.jobNum = jobNum;
	}
	public String getJobName() {
		return jobName;
	}
	public void setJobName(String jobName) {
		this.jobName = jobName;
	}
	public String getDiv() {
		return div;
	}
	public void setDiv(String div) {
		this.div = div;
	}
	public int getFontSize() {
		return fontSize;
	}
	public void setFontSize(int fontSize) {
		this.fontSize = fontSize;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getFullName() {
		return fullName;
	}
	public void setFullName(String fullName) {
		this.fullName = fullName;
	}
	public int getJobId() {
		return jobId;
	}
	public void setJobId(int jobId) {
		this.jobId = jobId;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getInfo() {
		return info;
	}
	public void setInfo(String info) {
		this.info = info;
	}
	public int getSiteId() {
		return siteId;
	}
	public void setSiteId(int siteId) {
		this.siteId = siteId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public int getUserId() {
		return userId;
	}
}