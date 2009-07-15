package com.sinkluge.ldap;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;

import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.Logger;

import com.sinkluge.Group;
import com.sinkluge.Info;
import com.sinkluge.User;
import com.sinkluge.database.Database;

public class ActiveDirectoryGroup extends Group {

	private Info in;
	private final Logger log = Logger.getLogger(ActiveDirectoryGroup.class);
	private String groupName = null;
	
	public ActiveDirectoryGroup(Info in, String groupName) {
		this.in = in;
		this.groupName = groupName == null ? in.default_group : groupName;
	}
	
	public void run() {
		setUserList();
	}

	private List<Attributes> getUsers() throws Exception {
		ActiveDirectory ldap = new ActiveDirectory(in);
		List<Attributes> list = ldap.getGroupUsers(groupName);
		ldap.close();
		ldap = null;
		return list;
	}
	
	
	private void setUserList() {
		// only do this once every thirty mins
		log.debug("Beginning loading user list");
		try {
			List<Attributes> list = getUsers();
			User user;
			Attributes attrs;
			Attribute at;
			String username, lastName, GID;
			char[] guidc;
			List<User> users = new ArrayList<User>();
			// Each iteration is a user object.
			for (Iterator<Attributes> i = list.iterator(); i.hasNext(); ) {
				attrs = i.next();
				at = attrs.get("objectGUID");
				byte[] guid = null;
				if (at != null) {
					guid = (byte[]) at.get();
					guidc = Hex.encodeHex(guid);
					GID = new String(guidc);
					if (log.isDebugEnabled()) 
						log.debug("found user with GID " + GID + " " + GID.length());
					at = attrs.get("sAMAccountName");
					if (at != null) {
						username = (String) at.get();
						at = attrs.get("sn");
						if (at != null) {
							lastName = (String) at.get();
							at = attrs.get("givenName");
							if (at != null) {
								user = new User();
								user.setUsername(username);
								user.setFirstName((String) at.get());
								user.setLastName(lastName);
								user.setUID(GID);
								at = attrs.get("mail");
								if (at != null) user.setEmail((String) at.get()); 
								users.add(user);
							}
						}
					}
				}
			}
			list.clear();
			list = null;
			Collections.sort(users);
			Database db = new Database();
			db.dbInsert("lock table users write");
			db.dbInsert("update users set active = 0");
			ResultSet rs = null;
			boolean insert;
			for(Iterator<User> i = users.iterator(); i.hasNext(); ) {
				user = i.next();
				rs = db.dbQuery("select * from users where uid = '" + user.getUID() + "' or " +
						"username = '" + user.getUsername() + "'", true);
				insert = false;
				if (!rs.first()) {
					insert = true;
					rs.moveToInsertRow();
				} 
				rs.updateString("uid", user.getUID());
				rs.updateString("username", user.getUsername());
				rs.updateString("first_name", user.getFirstName());
				rs.updateString("last_name", user.getLastName());
				rs.updateString("email", user.getEmail());
				rs.updateBoolean("active", true);
				try {
					if (insert) rs.insertRow();
					else rs.updateRow();
				} catch (SQLException e) {
					log.warn("Error inserting user", e);
				}
				rs.getStatement().close();
			}
			db.dbInsert("unlock tables");
			db.disconnect();;
			users.clear();
			user = null;
			log.debug("Finished loading user list");
		} catch (Exception e) {
			log.error("setUserList(): Can't set user list", e);
		}
	}
}
