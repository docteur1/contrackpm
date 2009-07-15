
package com.sinkluge.util;

// Classes we will need
import java.sql.Date;

public class Convert {

	public Convert () {}

	public Date date(String s) {
		return Date.valueOf(s.substring(6) + "-" + s.substring(0,2) + "-" + s.substring(3,5));
	}

	public int integer(String s) {
		if (s ==null || s.equals("") || s.matches("^\\s+$")) s = "0";
		return Integer.parseInt(s);
	}

	public String string(String s) {
		if (s == null) return "";
		else return s;
	}

	public boolean bool(String s) {
		return s != null;
	}

	public float cur(String s) {
		if (s ==null || s.equals("") || s.matches("^\\s+$")) s = "0";
		return Float.parseFloat(s);
	}

}