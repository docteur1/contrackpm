package com.sinkluge.utilities;

import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpSession;

import com.sinkluge.Type;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public enum ItemLogger {
	
	Created, 
	Updated,
	Faxed,
	Printed,
	eSubmited,
	Read, // They've opened the item in the external interface
	Opened, // IE they've displayed the image associated with the email
	Emailed,
	Deleted; // Need to add functionality to show things that have been deleted.
	
	public long update(Type type, String id, HttpSession session) throws SQLException, Exception {
		return update(type, id, null, session);
	}
	
	public long update(Type type, String id, String comment, HttpSession session) throws SQLException, Exception {
		return update(type, id, comment, 0, 0, session);
	}
	
	public long update(Type type, String id, int contactId, int companyId, HttpSession session) 
			throws SQLException, Exception {
		return update(type, id, null, contactId, companyId, session);
	}
	
	public static void setComment(long id, String comment) throws SQLException, Exception {
		Database db = new Database();
		ResultSet rs = db.dbQuery("select * from log where log_id = " + id, true);
		if (rs.first()) {
			rs.updateString("comment", comment);
			rs.updateRow();
		}
		rs.getStatement().close();
		rs = null;
		db.disconnect();
		db = null;
	}
	
	public long update(Type type, String id, String comment, int contactId, int companyId, HttpSession session) 
			throws SQLException, Exception {
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		ResultSet rs = db.dbQuery("select * from log where log_id = 0", true);
		rs.moveToInsertRow();
		rs.updateInt("uid", attr.getUserId());
		rs.updateString("type", type.getCode());
		rs.updateString("id", id);
		rs.updateString("activity", name());
		rs.updateString("comment", comment);
		rs.updateInt("to_contact_id", contactId);
		rs.updateInt("to_company_id", companyId);
		rs.updateTimestamp("stamp", new java.sql.Timestamp(System.currentTimeMillis()));
		rs.insertRow();
		rs.last();
		long logId = rs.getLong("log_id");
		rs.getStatement().close();
		rs = null;
		db.disconnect();
		db = null;
		return logId;
	}
	
}
