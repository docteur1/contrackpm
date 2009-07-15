package com.sinkluge.utilities;

import java.sql.ResultSet;

import javax.servlet.http.HttpSession;

import com.sinkluge.Type;
import com.sinkluge.database.Database;

public class ESubmit {
	
	public static int geteSubmitContactId(int id, Type type) throws Exception {
		int contactId = 0;
		Database db = new Database();
		ResultSet rs = getTypeResultSet(id, type, db);
		if (rs.first()) {
		switch (type) {
			case SUBMITTAL:
				if (rs.getDate("date_received") == null) contactId = 
					getContractContactId(rs.getInt("contract_id"), db);
				else if (rs.getDate("date_to_architect") != null) contactId = 
					getJobContactId(rs.getInt("architect_id"), db);
				else if (rs.getDate("date_from_architect") != null) contactId = 
						getContractContactId(rs.getInt("contract_id"), db);
				break;
			case RFI:
				rs.getStatement().close();
				rs = db.dbQuery("select contact_id from rfi where rfi_id = " + id + " and date_received is null");
				if (rs.first()) contactId = rs.getInt(1);
				break;
			}
		}
		if (rs != null) rs.getStatement().close();
		if (contactId != 0) {
			rs = db.dbQuery("select email from contacts where contact_id = " + contactId);
			if (!rs.first() || !Verify.email(rs.getString("email"))) contactId = 0;
		}
		db.disconnect();
		return contactId;
	}
	
	private static int getJobContactId(int id, Database db) throws Exception {
		int contractId = 0;
		ResultSet rs = db.dbQuery("select contact_id from job_contacts where job_contact_id = " + id);
		if (rs.first()) contractId = rs.getInt(1);
		rs.getStatement().close();
		return contractId;
	}
	
	private static int getContractContactId(int id, Database db) throws Exception {
		int contractId = 0;
		ResultSet rs = db.dbQuery("select contact_id from contracts where contract_id = " + id);
		if (rs.first()) contractId = rs.getInt(1);
		rs.getStatement().close();
		return contractId;
	}
	
	public static void setESubmit(int id, Type type, HttpSession session) throws Exception {
		Database db = new Database();
		ResultSet rs = getTypeResultSet(id, type, db);
		if (rs.first()) {
			rs.updateBoolean("e_submit", true);
			rs.updateRow();
		}
		rs.getStatement().close();
		db.disconnect();
	}
	
	private static ResultSet getTypeResultSet(int id, Type type, Database db) throws Exception {
		ResultSet rs = null;
		switch (type) {
		case SUBMITTAL:
			rs = db.dbQuery("select * from submittals where submittal_id = " + id, true);
			break;
		case RFI:
			rs = db.dbQuery("select * from rfi where rfi_id = " + id, true);
			break;
		}
		return rs;
	}
	
}
