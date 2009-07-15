package com.sinkluge.util;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.SimpleTimeZone;
import java.util.Date;

public class DateUtils {

	public static long convertWin32(long d) {
		SimpleTimeZone utc = new SimpleTimeZone(SimpleTimeZone.UTC_TIME, "UTC");
		GregorianCalendar Win32Epoch = new GregorianCalendar(utc);
		Win32Epoch.set(1601, Calendar.JANUARY, 1, 0, 0, 0);
		long lWin32Epoch = Win32Epoch.getTimeInMillis(); 
		return d/10000 + lWin32Epoch;
	}
	
	public static String parseLdapDate(String d) throws ParseException {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddkkmmss");
		SimpleTimeZone utc = new SimpleTimeZone(SimpleTimeZone.UTC_TIME, "UTC");
		sdf.setTimeZone(utc);
		d = d.substring(0, d.indexOf("."));
		SimpleDateFormat std = new SimpleDateFormat("d MMM yy h:mm a");
		return std.format(sdf.parse(d));
	}
	
	public static String formatDate(long d) {
		return formatData(new Date(d));
	}
	
	public static String formatData(Date d) {
		SimpleDateFormat std = new SimpleDateFormat("d MMM yy h:mm a");
		return std.format(d);
	}
	
	public static java.sql.Date getSQLShort(String s) throws ParseException {
		if (blank(s)) return null;
		else {
			SimpleDateFormat std = new SimpleDateFormat("MM/dd/yyyy");
			return new java.sql.Date(std.parse(s).getTime());
		}
	}
	
	public static Timestamp getTimestamp() {
		return new Timestamp(new Date().getTime());
	}
	
	private static boolean blank(String s) {
		if (s ==null || s.equals("")) return true;
		else if (s.matches("^\\s+$")) return true;
		else return false;
	}
	
}
