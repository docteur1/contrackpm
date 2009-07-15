package com.sinkluge.JSON;

import java.io.Serializable;
import java.sql.ResultSet;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.sinkluge.User;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public class Verify implements Serializable {

	/**
	 * get Logger
	 */
	public static Logger getLogger() {
		return Logger.getLogger(Verify.class);
	}
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 3L;
	
	/**
	 * Verify that the change request number is in fact unique
	 */
	public static String cRNum(HttpSession session, String num, String id) throws Exception {
		Database db = new Database();
		ResultSet rs = null;
		Attributes attr = null;
		String result = null;
		Logger log = getLogger();
		try {
			log.debug("Looking up CR num to verify doesn't exist: " + num);
			attr = (Attributes) session.getAttribute("attr");
			rs = db.dbQuery("select num, title from change_requests where num = " + num
					+ " and cr_id != " + id + " and job_id = " + attr.getJobId());
			if (rs.first()) result = rs.getString("num") + ": " + rs.getString("title");
		} catch (Exception e) {
			log.error("Error verifying CRNum", e);
			throw new Exception(e);
		} finally {
			if (rs != null) rs.getStatement().close();
			db.disconnect();
		}
		return result;
	}
	
	/**
	 * Verify that the change auth number is in fact unique
	 */
	public static String cDNum(HttpSession session, String num, String id) throws Exception {
		Database db = new Database();
		ResultSet rs = null;
		Attributes attr = null;
		String result = null;
		Logger log = getLogger();
		try {
			log.debug("Looking up CD num to verify doesn't exist: " + num);
			attr = (Attributes) session.getAttribute("attr");
			rs = db.dbQuery("select num, title, status from change_requests as cr join "
					+ "change_request_detail as crd using(cr_id) where "
					+ "crd_id = " + id + " and status != 'Approved'");
			if (rs.first()) {
				result = "\"CR#" + rs.getString(1) + ": " + rs.getString(2) +
					"\" has not been approved.";
			}
			if (result == null) {
				System.out.println(num + " " + id);
				if (id != null)
					rs = db.dbQuery("select change_auth_num, work_description from change_request_detail as crd "
						+ "where change_auth_num = " + num + " and crd_id != " + id + " and job_id = " 
						+ attr.getJobId());
				else 
					rs = db.dbQuery("select change_auth_num, work_description from change_request_detail as crd "
							+ "where change_auth_num = " + num + " and job_id = " + attr.getJobId());
				if (rs.first()) result = rs.getString(1) + ": " + rs.getString(2);
			}
		} catch (Exception e) {
			log.error("Error verifying CDNum", e);
			throw new Exception(e);
		} finally {
			if (rs != null) rs.getStatement().close();
			if (db != null) db.disconnect();
		}
		return result;
	}
	
	public static String cONum(HttpSession session, String num, String id) throws Exception {
		Database db = new Database();
		ResultSet rs = null;
		Attributes attr = null;
		String result = null;
		Logger log = getLogger();
		try {
			log.debug("Looking up CO num to verify doesn't exist: " + num);
			attr = (Attributes) session.getAttribute("attr");
			if (id != null)
				rs = db.dbQuery("select co_num, co_description from change_orders "
					+ "where co_id != " + id + " and job_id = " + attr.getJobId()
					+ " and co_num = " + num);
			else 
				rs = db.dbQuery("select co_num, co_description from change_orders "
						+ "where job_id = " + attr.getJobId() + " and co_num = " + num);
			if (rs.first()) result = rs.getString(1) + ": " + rs.getString(2);
		} catch (Exception e) {
			log.error("Error verifying CDNum", e);
			throw new Exception(e);
		} finally {
			if (rs != null) rs.getStatement().close();
			if (db != null) db.disconnect();
		}
		return result;
	}
	
	/**
	 * Get a unique CA Num
	 */
	public static int getNextCANum(HttpSession session) throws Exception {
		Database db = new Database();
		ResultSet rs = null;
		Attributes attr = null;
		int result = 1;
		Logger log = getLogger();
		try {
			log.debug("Looking up next CANum");
			attr = (Attributes) session.getAttribute("attr");
			rs = db.dbQuery("select max(change_auth_num) from change_request_detail as crd "
					+ "join job_cost_detail as jcd using(cost_code_id) where crd.job_id = " + attr.getJobId());
			if (rs.first()) result = rs.getInt(1) + 1;
			log.debug("Found CANum " + result);
		} catch (Exception e) {
			log.error("Error verifying CDNum", e);
			throw new Exception(e);
		} finally {
			if (rs != null) rs.getStatement().close();
			if (db != null) db.disconnect();
		}
		return result;
	}
	
	public static String username(String username, int id) throws Exception {
		User user = User.getUserByUsername(username);
		getLogger().debug("username: " + username + " found " + user + " compare to id " + id);
		if (user != null && user.getId() != id) return user.getListName();
		else return null;
	}
	
}
