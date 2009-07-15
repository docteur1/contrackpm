package com.sinkluge.util;

import java.sql.ResultSet;

import com.sinkluge.database.Database;

public class Widgets {

	public static String attachments(String id, String type, Database db) throws Exception {
		String out = "<a href=\"javascript: openWin('../utils/upload.jsp?type=" + type + "&id=" + id + "');\">Attachments";
		ResultSet rs = db.dbQuery("select count(*) from files where id = " + id + " and type = '" + type + "'");
		if (rs.first() && rs.getInt(1) != 0) out = "<b>" + out + "(" + rs.getInt(1) + ")</a></b>";
		else out += "</a>";
		rs.getStatement().close();
		rs = null;
		return out;
	}
	
	public static String checkmark(boolean val) {
		if (val) return "<img src=\"../images/checkmark.gif\">";
		else return "&nbsp;";
	}
	
	public static String map(String address, String city, String state, String zip) {
		String map = "";
		if (address != null && !address.equals("")) map = address + ", ";
		map += city + ", " + state + ", " + zip;
		map = "http://maps.google.com/maps?q=" + map;
		if (city == null || city.equals("")) map = "Address";
		else map = "<a href=\"" + map + "\" target=\"_blank\">Address (Map)</a>";
		return map;
	}
	
}
