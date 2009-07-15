
package com.sinkluge.util;

// Classes we will need
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;
import java.sql.Timestamp;

public class FormHelper {

	public static String sel(int id1, int id2) {
		return sel(id1 == id2);
	}

	public static String sel(long id1, long id2) {
		return sel(id1 == id2);
	}
	
	public static String sel(String val1, String val2) {
		return sel((val1 != null && val2 != null) && val1.equals(val2));
	}


	public static String sel(boolean val) {
		if (val) return "selected";
		else return "";
	}
	
	public static String color(boolean val) {
		if (val) return "class=\"gray\"";
		else return "";
	}
	
	public static String yellow(boolean val) {
		if (val) return "yellow";
		else return "";
	}
	
	public static String yellow(String val1, String val2) {
		return yellow((val1 != null && val2 != null) && val1.equals(val2));
	}
	
	public static String bold(boolean val) {
		if (val) return "bold";
		else return "";
	}
	
	public static String bold(String val1, String val2) {
		return bold((val1 != null && val2 != null) && val1.equals(val2));
	}

	public static String chk(boolean val) {
		if (val) return "checked";
		else return "";
	}

	public static String dis(boolean val) {
		if (val) return "disabled";
		else return "";
	}

	public static String date(Date d) {
		if (d == null) return "";
		else {
			SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
			return sdf.format(d);
		}
	}

	public static String medDate(Date d) {
		if (d == null) return "&nbsp;";
		else {
			SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy");
			return sdf.format(d);
		}
	}

	private static boolean blank(String s) {
		if (s ==null || s.equals("")) return true;
		else if (s.matches("^\\s+$")) return true;
		else return false;
	}
	
	public static String stringNull(String s) {
		if (blank(s)) return null;
		else return s;
	}
	
	public static String string(String s) {
		if (s == null) return "";
		else return s;
	}
	
	public static String stringTable(String s) {
		if (blank(s)) return "&nbsp;";
		else return s;
	}

	public static String cur(float val) {
		return cur((double) val);
	}
	
	public static String cur(double val) {
		DecimalFormat df = new DecimalFormat("#,##0.00");
		return df.format(val);
	}
	
	public static String timestamp (Date d) {
		if (d == null) return "";
		else {
			SimpleDateFormat sdf = new SimpleDateFormat("MMM d yyyy h:mm a");
			return sdf.format(d);
		}
	}
	
	public static String hidden (String name, String value) {
		return "<input type=\"hidden\" name=\"" + name + "\" value=\"" + value + "\">";
	}
	
	public static boolean oldBoolean(String s) {
		if (blank(s)) return false;
		else return s.equals("y");
	}

	public static String elapsed (Timestamp present, Timestamp past) {
		DecimalFormat df = new DecimalFormat("0");
		// Number of milliseconds past
		long elapse = present.getTime() - past.getTime();
		double days = elapse / (long) 86400000; // Millis in a day
		double hours = elapse / (long) 3600000; // Millis in an hour
		double minutes = elapse / (long) 60000; // Millis in a minute
		minutes = minutes % 60;
		hours = hours % 24;
		String s = "";
		if (days != 0) s =  df.format(days) + " days ";
		s += df.format(hours) + ":";
		df.applyPattern("00");
		s += df.format(minutes);
		return s;
	}
/*
	public static String active (boolean val) {
		if (!val) return "style=\"background-color: #C0C0C0;\"";
		else return "";
	}
*/
}