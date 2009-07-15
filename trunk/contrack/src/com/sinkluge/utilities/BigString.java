package com.sinkluge.utilities;

import org.apache.commons.lang.StringUtils;

public class BigString  {
	
	private String s;
	
	public BigString(String s) {
		this.s = s;
	}
	// Use org.apache.commons.lang.StringUtils.replaceEach!!!
	public void replaceAll(String regex, String repl) {
		s = StringUtils.replace(s, regex, repl);
	}
	
	public String toString() {
		return s;
	}
	
	public void clear() {
		s = null;
	}
	
	public void setContractorName(String name) {
		replaceAll("%c", name);
	}
	
	public void setSubcontractorName(String name) {
		replaceAll("%s", name);
	}
	
	public void setProjectName(String name) {
		replaceAll("%n", name);
	}
	
}
