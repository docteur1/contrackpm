package com.sinkluge;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.apache.log4j.Logger;

import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public class SessionListener implements HttpSessionListener {

	private Logger log = Logger.getLogger(SessionListener.class);
	
	@SuppressWarnings("unchecked")
	public void sessionCreated(HttpSessionEvent hse) {
		HttpSession session = hse.getSession();
		// Only authenicated sessions will persist... give them 5 minutes to login.
		session.setMaxInactiveInterval(300);
		Map<String, HttpSession> st = (Map<String, HttpSession>) 
			session.getServletContext().getAttribute("st");
		if (st == null) {
			st = new HashMap<String, HttpSession>();
			session.getServletContext().setAttribute("st", st);
		}
		st.put(session.getId(), session);
	}

	@SuppressWarnings("unchecked")
	public void sessionDestroyed(HttpSessionEvent hse) {
		HttpSession session = hse.getSession();
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		if (attr != null) {
			String sql = "select * from session_log where session_log_id = 0";
			ResultSet rs = null;
			try {
				rs = db.dbQuery(sql, true);
				rs.moveToInsertRow();
				rs.updateInt("user_id", attr.getUserId());
				rs.updateString("agent", attr.getBrowser() == null ? "Unknown" : attr.getBrowser());
				rs.updateString("host", attr.getInfo() == null ? "Unknown" : attr.getInfo());
				rs.updateTimestamp("created", new Timestamp(session.getCreationTime()));
				rs.updateTimestamp("destroyed", new Timestamp(System.currentTimeMillis()));
				String reason = (String) session.getAttribute("reason");
				if (reason == null) reason = "Session Timeout";
				rs.updateString("reason", reason);
				rs.insertRow();
			} catch (Exception e) {
				log.warn("sessionDestroyed: ERROR " + e.getMessage(), e);
			} finally {
				try {
					if (rs != null) rs.getStatement().close();
					if (db != null) db.disconnect();
				} catch (SQLException e) {}
			}
		}
		Map<String, HttpSession> st = (Map<String, HttpSession>)
			session.getServletContext().getAttribute("st");
		if(st != null) {
			st.remove(session.getId());
		}
		
	}

}
