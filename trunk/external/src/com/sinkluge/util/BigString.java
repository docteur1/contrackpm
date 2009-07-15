package com.sinkluge.util;

public class BigString  {
	
	private StringBuffer sb;
	
	public BigString(String s) {
		sb = new StringBuffer(s);
	}
	
	public void replaceAll(String regex, String repl) {
		int loc = sb.indexOf(regex);
		while (loc != -1) {
			sb = sb.delete(loc, loc + regex.length());
			sb = sb.insert(loc, repl);
			loc = sb.indexOf(regex, loc);
		}
	}
	
	public String toString() {
		return sb.toString();
	}
	
	public void clear() {
		sb = null;
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
