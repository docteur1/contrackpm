package com.sinkluge.utilities;

public class DataUtils {

	public static String oldBoolean(String s) {
		return oldBoolean(!blank(s));
	}
	
	public static String oldBoolean(boolean b) {
		if (b) return "y";
		else return "n";
	}
	
	public static String chkFormNull(String s) {
		if (blank(s)) return null;
		else return s;
	}
	
	public static String chkForm(String s) {
		if (blank(s)) return "";
		else return s;
	}
	
	private static boolean blank(String s) {
		if (s ==null || s.equals("")) return true;
		else if (s.matches("^\\s+$")) return true;
		else return false;
	}
	
	public static String decimal(String s) {
		if (blank(s)) return "0";
		else return s.replaceAll(",", "");
	}
}
