/**
 * 
 */
package com.sinkluge;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.io.output.ByteArrayOutputStream;

/**
 * @author grante
 * 
 * This holds the user's data... creates a consistent way to get / set user data
 */
public abstract class UserData {
	
	protected String id;
	protected Map<String, String> ht = new HashMap<String, String>();
	
	public abstract String getWebConfigJspName();
	
	public String getSafe(String key) {
		return ht.get(key)==null?"":ht.get(key);
	}
	
	public String getId() {
		return id;
	}
	
	public String get(String key) {
		return ht.get(key);
	}
	
	public void put(String key, String val) {
		ht.put(key, val);
	}
	
	public static UserData getInstance(Info in, String username) throws Exception {
		UserData user = (UserData) Class.forName(in.user_class).newInstance();
		user.getData(username, in);
		return user;
	}
	
	public static UserData getInstance(Info in, int id) throws Exception {
		UserData user = (UserData) Class.forName(in.user_class).newInstance();
		user.getData(id, in);
		return user;
	}
	
	public static UserData getInstance(Info in, User user) throws Exception {
		UserData ud = (UserData) Class.forName(in.user_class).newInstance();
		ud.getData(user, in);
		return ud;
	}
	
	public abstract Group getGroupInstance(Info in, String groupName);
	
	public abstract String changeUserPassword(String oldPass, String newPass, Info in) 
		throws Exception;
	
	public abstract String changeUserPassword(String newPass, Info in) throws Exception;
	
	public abstract void getData(String username, Info in) throws Exception;
	
	public abstract void getData(int id, Info in) throws Exception;
	
	public abstract void getData(User user, Info in) throws Exception;
	
	public abstract InputStream getPhoto(Info in) throws Exception;
	
	public abstract void setPhoto(Info in, ByteArrayOutputStream photo) throws Exception;
	
	public void close() {
		ht.clear();
		ht = null;
	}
	
	public abstract void setData(Info in) throws Exception;
	
}
