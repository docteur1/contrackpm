package com.sinkluge.sqluser;

import java.io.InputStream;
import java.sql.Blob;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.log4j.Logger;

import com.sinkluge.Group;
import com.sinkluge.Info;
import com.sinkluge.User;
import com.sinkluge.UserData;
import com.sinkluge.database.Database;
import com.sinkluge.exception.NotFoundException;
import com.sinkluge.utilities.Digest;
import com.sinkluge.utilities.Verify;

public class SQLUser extends UserData {
	
	private Logger log = Logger.getLogger(SQLUser.class);
	
	public String getWebConfigJspName() {
		return "sqlUserAdmin.jsp";
	}
	
	@Override
	public String changeUserPassword(String oldPass, String newPass, Info in) 
			throws Exception {
		Database db = new Database();
		ResultSet rs = db.dbQuery("select * from users where id = " + id, true);
		String result = "Password Changed";
		if (rs.first()) {
			if (log.isDebugEnabled() && oldPass != null) {
				log.debug("changeUserPassword: old md5 hash in db: " 
					+ rs.getString("password") + " old md5 hash from user "
					+ Digest.digest(oldPass) + ".");
			}
			// oldPass is null this is being called by the admin
			if (oldPass == null || Digest.digest(oldPass).equals(rs.getString("password"))) {
				Verify v = new Verify();
				if (v.password(newPass, null)) {
					rs.updateString("password", Digest.digest(newPass));
				} else result = v.message;
			} else result = "Old password does not match";
		} else result = "User not found";
		rs.getStatement().close();
		db.disconnect();
		return result;
	}

	@Override
	public void getData(String username, Info in) throws NotFoundException {
		Database db = null;
		ResultSet rs = null;
		try {
			db = new Database();
			rs = db.dbQuery("select * from user where username = '" 
					+ username + "'");
			if (rs.first()) populateUser(rs);
			else throw new Exception();
		} catch (Exception e) {
			throw new NotFoundException("getUser(username, in): username = " +
				username);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {
				log.debug("getUser(username, in): error closing resources", e);
			}
		}
	}
	
	private void populateUser(ResultSet rs) throws SQLException {
		ht.put("last_name", rs.getString("last_name"));
		ht.put("first_name", rs.getString("first_name"));
		ht.put("user_name", rs.getString("username"));
		ht.put("email", rs.getString("email"));
		id = rs.getString("id");
		ht.put("title", rs.getString("title"));
		ht.put("address", rs.getString("address"));
		ht.put("city", rs.getString("city"));
		ht.put("state", rs.getString("state"));
		ht.put("zip", rs.getString("zip"));
		Blob photo = rs.getBlob("photo");
		if (photo != null && photo.length() != 0) 
			ht.put("photo", "true");
		ht.put("phone", rs.getString("phone"));
		ht.put("ext", rs.getString("ext"));
		ht.put("fax", rs.getString("fax"));
		ht.put("radio", rs.getString("radio"));
	}
	
	@Override
	public void getData(int id, Info in) throws NotFoundException {
		Database db = null;
		ResultSet rs = null;
		try {
			db = new Database();
			rs = db.dbQuery("select * from users where id = " + id);
			if (rs.first()) populateUser(rs);
			else throw new NotFoundException("getUser(id, in): id = " +
					id);
		} catch (SQLException e) {
			throw new NotFoundException("getUser(id, in): id = " +
				id + " SQLException: " + e.getMessage(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {
				log.debug("getUser(id, in): error closing resources", e);
			}
		}
	}

	@Override
	public void getData(User user, Info in) throws IllegalArgumentException {
		if (user != null) {
			getData(user.getId(), in);
		} else throw new IllegalArgumentException(
				"getData(user, in): user cannot be null");
	}

	@Override
	public Group getGroupInstance(Info in, String groupName) {
		return new SQLGroup();
	}

	@Override
	public InputStream getPhoto(Info in) throws NotFoundException {
		Database db = null;
		ResultSet rs = null;
		InputStream is = null;
		try {
			db = new Database();
			rs = db.dbQuery("select photo from users where id = " + id);
			if (rs.first()) is = rs.getBinaryStream(1);
			else throw new NotFoundException("getPhoto: id = " +
					id);
		} catch (Exception e) {
			throw new NotFoundException("getPhoto: id = " +
					id + " SQLException: " + e.getMessage(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {
				log.debug("getPhoto(in): error closing resources", e);
			}
		}
		return is;
	}

	@Override
	public void setData(Info in) throws Exception {
		Database db = null;
		ResultSet rs = null;
		try {
			db = new Database();
			rs = db.dbQuery("select * from users where id = " + id, true);
			if (rs.first()) {
				rs.updateString("last_name", ht.get("last_name"));
				rs.updateString("first_name", ht.get("first_name"));
				rs.updateString("username", ht.get("user_name"));
				rs.updateString("email", ht.get("email"));
				rs.updateString("title", ht.get("title"));
				rs.updateString("address", ht.get("address"));
				rs.updateString("city", ht.get("city"));
				rs.updateString("state", ht.get("state"));
				rs.updateString("zip", ht.get("zip"));
				rs.updateString("phone", ht.get("phone"));
				rs.updateString("ext", ht.get("ext"));
				rs.updateString("fax", ht.get("fax"));
				rs.updateString("radio", ht.get("radio"));
				rs.updateRow();
			}
			else throw new NotFoundException("setData(in): id = " +
					id);
		} catch (SQLException e) {
			throw new NotFoundException("setData(in): id = " +
					id + " SQLException: " + e.getMessage(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {
				log.debug("setData(in): error closing resources", e);
			}
		}
	}

	@Override
	public void setPhoto(Info in, ByteArrayOutputStream photo) throws Exception {
		Database db = null;
		ResultSet rs = null;
		try {
			db = new Database();
			rs = db.dbQuery("select * from users where id = " + id, true);
			if (rs.first()) {
				rs.updateBytes("photo", photo == null ? null : photo.toByteArray());
				rs.updateRow();
			}
			else throw new NotFoundException("setPhoto: id = " +
					id);
		} catch (SQLException e) {
			throw new NotFoundException("setPhoto: id = " +
					id + " SQLException: " + e.getMessage(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {
				log.debug("getPhoto(in): error closing resources", e);
			}
		}
	}

	@Override
	public String changeUserPassword(String newPass, Info in) throws Exception {
		return changeUserPassword(null, newPass, in);
	}

}
