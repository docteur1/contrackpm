package com.sinkluge.ldap;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.log4j.Logger;

import com.sinkluge.Group;
import com.sinkluge.Info;
import com.sinkluge.User;
import com.sinkluge.UserData;

public class ActiveDirectoryUser extends UserData {
	
	private static Logger log = Logger.getLogger(ActiveDirectoryUser.class);
	
	public String getWebConfigJspName() {
		return null;
	}
	
	public String getSafe(String key) {
		return ht.get(key)==null?"":ht.get(key);
	}
	
	public String get(String key) {
		return ht.get(key);
	}
	
	public void put(String key, String val) {
		ht.put(key, val);
	}
	
	private static final long serialVersionUID = -7931198881991903940L;
	
	public InputStream getPhoto(Info in) throws Exception {
		InputStream photo = null;
		ActiveDirectory ldap = new ActiveDirectory(in);
		Attributes attrs = ldap.getUserById(id);
		log.debug("Getting user photo");
		if (attrs != null) {
			Attribute at = attrs.get("jpegPhoto");
			if (at != null) photo = new ByteArrayInputStream((byte[]) at.get());
		}
		ldap.close();
		return photo;
	}
	
	public void setPhoto(Info in, ByteArrayOutputStream photo) throws Exception {
		ActiveDirectory ldap = new ActiveDirectory(in);
		if (log.isDebugEnabled() && photo != null) log.debug("Saving a photo of size " + photo.size());
		else log.debug("Removing photo");
		if (photo != null) ldap.setAttribute("jpegPhoto", photo.toByteArray());
		else ldap.setAttribute("jpegPhoto", null);
		ldap.saveUser(id);
		ldap.close();
	}
	
	public void getData(User user, Info in) throws Exception {
		if (user != null) {
			ActiveDirectory ldap = new ActiveDirectory(in);
			Attributes attrs = ldap.getUserById(user.getUID());
			if (log.isDebugEnabled()) log.debug("Searched for user by id: " + user.getUID() + " found: " + (attrs != null));
			getData(attrs);
			ldap.close();
		} else throw new Exception("User not found!");
	}
	
	public void getData(int id, Info in) throws Exception {
		User user = User.getUser(id);
		getData(user, in);
	}
	
	public void getData(String username, Info in) throws Exception {
		ActiveDirectory ldap = new ActiveDirectory(in);
		Attributes attrs = ldap.getUserByUsername(username);
		getData(attrs);
		if (log.isDebugEnabled()) log.debug("Searched for user by username: " + username + " found: " 
				+ (attrs != null) + " with id: " + id);
		ldap.close();
	}
		
	private void getData(Attributes attrs) throws Exception {
		if (attrs != null) {
			Attribute at = attrs.get("sn");
			if (at != null) ht.put("last_name", (String) at.get());
			at = attrs.get("givenName");
			if (at != null) ht.put("first_name", (String) at.get());
			at = attrs.get("sAMAccountName");
			if (at != null) ht.put("user_name", (String) at.get());
			at = attrs.get("mail");
			if (at != null) ht.put("email", (String) at.get());
			at = attrs.get("objectGUID");
			byte[] guid = null;
			if (at != null) {
				guid = (byte[]) at.get();
				char[] guidc = Hex.encodeHex(guid);
				id = new String(guidc);
			}
			at = attrs.get("title");
			if (at != null) ht.put("title", (String) at.get());
			at = attrs.get("streetAddress");
			if (at != null) ht.put("address", (String) at.get());
			at = attrs.get("l");
			if (at != null) ht.put("city", (String) at.get());
			at = attrs.get("st");
			if (at != null) ht.put("state", (String) at.get());
			at = attrs.get("postalCode");
			if (at != null) ht.put("zip", (String) at.get());
			at = attrs.get("jpegPhoto");
			if (at != null) ht.put("photo", "true");
			String phone = null;
			String ext = null;
			at = attrs.get("telephoneNumber");
			if (at != null) {
				phone = (String) at.get();
				if (phone != null) {
					int x = phone.indexOf("x");
					if (x != -1) {
						ext = phone.substring(x+2);
						phone = phone.substring(0,x-1);	
					}
				}
			}
			ht.put("phone", phone);
			ht.put("ext",ext);
			at = attrs.get("facsimileTelephoneNumber");
			if (at != null) ht.put("fax", (String) at.get());
			at = attrs.get("mobile");
			if (at != null) ht.put("mobile", (String) at.get());
			at = attrs.get("otherMobile");
			if (at != null) ht.put("radio", (String) at.get());
			/*
			at = attrs.get("pwdLastSet");
			if (at != null) ht.put("pwd_age", Long.toString(LdapPwd.getPwdAge((String) at.get(), 
					(String) attrs.get("userAccountControl").get())));
			*/
			// I know it seems hookey to use the car licsense field- but we'll never use it
		} 
	}
	
	public String changeUserPassword(String oldPass, String newPass, Info in) {
		return ActiveDirectoryPassword.changeUserPassword(id, oldPass, newPass, in);
	}
	
	public void setData(Info in) throws Exception {
		ActiveDirectory ldap = new ActiveDirectory(in);
		ldap.setAttribute("sn", ht.get("last_name"));
		ldap.setAttribute("givenName", ht.get("first_name"));
		ldap.setAttribute("mail", ht.get("email"));
		ldap.setAttribute("title", ht.get("title"));
		ldap.setAttribute("streetAddress", ht.get("address"));
		ldap.setAttribute("l", ht.get("city"));
		ldap.setAttribute("st", ht.get("state"));
		ldap.setAttribute("postalCode", ht.get("zip"));
		String phone = ht.get("ext");
		if (phone == null || phone.equals("")) phone = ht.get("phone");
		else phone = ht.get("phone") + " x " + phone; 
		ldap.setAttribute("telephoneNumber", phone);
		ldap.setAttribute("facsimileTelephoneNumber", ht.get("fax"));
		ldap.setAttribute("mobile", ht.get("mobile"));
		ldap.setAttribute("otherMobile", ht.get("radio"));
		ldap.setAttribute("carLicense", null);
		ldap.saveUser(id);
		ldap.close();
	}

	public Group getGroupInstance(Info in, String groupName) {
		return new ActiveDirectoryGroup(in, groupName);
	}

	@Override
	public String changeUserPassword(String newPass, Info in) throws Exception {
		return null; // This method isn't going to do anything.
	}
	
}