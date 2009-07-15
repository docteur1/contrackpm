package com.sinkluge.JSON;

import java.io.Serializable;
import java.util.Map;

public class Project implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -9165995426650898254L;
	
	private String projectNum;
	private String projectName;
	private int projectId;
	private String siteName;
	private int limit;
	private Map<String, Boolean> perms;
	private boolean supportAvailable;
	
	public String getSiteName() {
		return siteName;
	}
	public void setSiteName(String siteName) {
		this.siteName = siteName;
	}
	public Map<String, Boolean> getPerms() {
		return perms;
	}
	public void setPerms(Map<String, Boolean> perms) {
		this.perms = perms;
	}
	public String getProjectNum() {
		return projectNum;
	}
	public void setProjectNum(String projectNum) {
		this.projectNum = projectNum;
	}
	public String getProjectName() {
		return projectName;
	}
	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}
	public int getProjectId() {
		return projectId;
	}
	public void setProjectId(int projectId) {
		this.projectId = projectId;
	}
	public boolean isSupportAvailable() {
		return supportAvailable;
	}
	public void setSupportAvailable(boolean supportAvailable) {
		this.supportAvailable = supportAvailable;
	}
	public void setLimit(int limit) {
		this.limit = limit;
	}
	public int getLimit() {
		return limit;
	}

}
