package com.sinkluge;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.apache.log4j.Logger;

import com.sinkluge.database.Database;

public class User implements Comparable<User> {

	private String username;
	private String lastName;
	private String firstName;
	private String email;
	private String GID;
	private int fontSize;
	private boolean flag = false;
	private int id;
	private boolean active = false;
	
	@Override
	public String toString() {
		return super.toString() + " " + username + " id: " + id;
	}
	
	public boolean isFlagged() {
		return flag;
	}
	
	public static List<User> getUserList() throws SQLException, Exception {
		return getUserList(0);
	}
	
	public static List<User> getUserList(int id) throws SQLException, Exception {
		List<User> users = new ArrayList<User>();
		User user;
		Database db = new Database();
		ResultSet rs = db.dbQuery("select id, first_name, last_name from users where active = 1 and id != " + id);
		while (rs.next()) {
			user = new User();
			user.setId(rs.getInt("id"));
			user.setFirstName(rs.getString("first_name"));
			user.setLastName(rs.getString("last_name"));
			user.setActive(true);
			users.add(user);
		}
		rs.getStatement().close();
		db.disconnect();
		if (id != 0) {
			user = getUser(id);
			if (user != null) {
				user.flag = true;
				users.add(user);
			}
		}
		Collections.sort(users);
		return users;
	}
	
	public static User getUserByUsername(String username) throws SQLException, Exception {
		User user = null;
		Database db = new Database();
		ResultSet rs = db.dbQuery("select id from users where username = '" + username + "'");
		if (rs.first()) user = getUser(rs.getInt(1));
		rs.getStatement().close();
		db.disconnect();
		return user;
	}
	
	public static User getUser(String id) throws SQLException, Exception {
		return getUser(Integer.parseInt(id));
	}
	
	public static User getUser(int id) throws SQLException, Exception {
		User user = null;
		Database db = new Database();
		ResultSet rs = db.dbQuery("select id, uid, email, username, font_size, first_name, last_name, " +
			"active from users where id = " + id);
		Logger log = Logger.getLogger(User.class);
		log.debug("Looking for user with id: " + id);
		if (rs.first()) {
			user = new User();
			user.setId(rs.getInt("id"));
			user.setFirstName(rs.getString("first_name"));
			user.setLastName(rs.getString("last_name"));
			user.setUID(rs.getString("uid"));
			user.setUsername(rs.getString("username"));
			user.setEmail(rs.getString("email"));
			user.setFontSize(rs.getInt("font_size"));
			user.setActive(rs.getBoolean("active"));
		}
		rs.getStatement().close();
		db.disconnect();
		return user;
	}
	
	public int compareTo(User u) {
		if (!lastName.equals(u.lastName)) return lastName.compareTo(u.lastName);
		else return firstName.compareTo(u.firstName);
	}
	
	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getLastName() {
		return lastName;
	}
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	public String getUsername() {
		return username;
	}
	public void setUsername(String username) {
		this.username = username;
	}
	public String getFullName() {
		return firstName + " " + lastName;
	}
	public String getListName() {
		return lastName + ", " + firstName;
	}

	public void setUID(String gID) {
		GID = gID;
	}

	public String getUID() {
		return GID;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}

	public void setFontSize(int fontSize) {
		this.fontSize = fontSize;
	}

	public int getFontSize() {
		return fontSize;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}
	
}
