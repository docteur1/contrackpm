package com.sinkluge;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

import com.sinkluge.database.Database;

public class Info {

	public Info () {
		loadProperties();
	}
	
	public String upload_limit, path, live_support_url, live_support_workgroup;

	public void loadProperties() {
		try {
			Database db = new Database();
			db.connect();
			Statement stmt = db.getStatement();
			ResultSet rs = stmt.executeQuery("select * from settings where id = 'site'");
			Map<String, String> temp = new HashMap<String, String>();
			while (rs.next()) temp.put(rs.getString("name"), rs.getString("val"));
			rs.getStatement().close();
			rs = null;
			db.disconnect();
			db = null;
			upload_limit = temp.get("upload_limit");
			live_support_url = temp.get("live_support_url");
			live_support_workgroup = temp.get("live_support_workgroup");
			temp.clear();
			temp = null;
		} catch (SQLException e) {
			System.out.println("SQLException loading company properties: " + e.toString());
			e.printStackTrace();
		}
	}
}