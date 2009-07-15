package com.sinkluge;

import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import com.sinkluge.database.Database;

public class SinklugeSessionListener implements HttpSessionListener {

	public void sessionCreated(HttpSessionEvent hse) {
	}

	public void sessionDestroyed(HttpSessionEvent hse) {
		Database db = null;
		Statement stmt = null;
		try {
			db = new Database();
			db.connect();
			stmt = db.getStatement();
			stmt.executeUpdate("update ext_sessions set closed = 1 where id = '" + hse.getSession().getId() + "'");
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				if (stmt != null) stmt.close();
				} catch (SQLException e) {}
			stmt = null;
			if (db != null) db.disconnect();
		}
	}

}
