package com.sinkluge.ldap;

import java.io.UnsupportedEncodingException;
//import java.util.Date;
import java.util.Hashtable;

import javax.naming.AuthenticationException;
import javax.naming.Context;
import javax.naming.NamingException;
import javax.naming.OperationNotSupportedException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.BasicAttribute;
import javax.naming.directory.DirContext;
import javax.naming.directory.InvalidAttributeValueException;
import javax.naming.directory.ModificationItem;
import javax.naming.ldap.InitialLdapContext;
import javax.naming.ldap.LdapContext;

import org.apache.log4j.Logger;

import com.sinkluge.Info;
//import com.sinkluge.utilities.DateUtils;

public final class ActiveDirectoryPassword {
	
	// From MS's Lmaccess.h
	// private final static int UF_DONT_EXPIRE_PASSWD = 0x10000;
	
	/* 
	 * I'm done with this dealing with password ages
	 * 
	public static long getPwdAge(String sPwdLastSet, String sUserAccountControl) throws NamingException {
		 // -1 indicates to us the password doesn't expire.
		 // 0 that the password has expired (or a reset is being forced.
		long seconds = -1;
		long userAccountControl = Long.parseLong(sUserAccountControl);
		// Does the user have an expiring account.
		long pwdLastSet = Long.parseLong(sPwdLastSet);
		if (pwdLastSet == 0) seconds = 0;
		else if ((userAccountControl & UF_DONT_EXPIRE_PASSWD) != UF_DONT_EXPIRE_PASSWD) 
			seconds = (new Date()).getTime() - DateUtils.convertWin32(pwdLastSet);
		return seconds;
	} 
	
	public static long getMaxPwdAge(Info in) throws NamingException {
		Ldap ldap = new Ldap(in);
		LdapContext ctx = ldap.getContext();
		Attributes attrs = ctx.getAttributes(in.search_base);
		long maxPwdAge = Long.parseLong((String) attrs.get("maxPwdAge").get());
		if (maxPwdAge < 0) maxPwdAge *= -1;
		ctx.close();
		return maxPwdAge/10000;
	}
	*/

	private static LdapContext getUserContext(String user, String pass, Info in) throws NamingException {
		Hashtable<String,String> ht = new Hashtable<String,String>();
		ht.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		ht.put(Context.PROVIDER_URL, in.ldap_host);
		ht.put(Context.SECURITY_PRINCIPAL, user);
		ht.put(Context.SECURITY_CREDENTIALS, pass);
		ht.put(Context.REFERRAL, "follow");
		LdapContext ctx = null;
		try {
			ctx = new InitialLdapContext(ht, null);
		} catch (NamingException e) {
			if (e instanceof AuthenticationException) throw new AuthenticationException(e.getExplanation());
			ht.put(Context.PROVIDER_URL, in.alt_ldap_host);
			ctx = new InitialLdapContext(ht, null);
		}
		return ctx;
	}
	
	public static String changeUserPassword(String id, String oldPass, String newPass, Info in) {
		String result = "Password Changed";
		Logger log = Logger.getLogger(ActiveDirectoryPassword.class);
		LdapContext ctx = null;
		try {
			ActiveDirectory ldap = new ActiveDirectory(in);
			Attributes attrs = ldap.getUserById(id);
			String dn = (String) attrs.get("distinguishedName").get();
			ldap.close();
			ctx = getUserContext(dn, oldPass, in);
			ldap = new ActiveDirectory(ctx);
			ModificationItem[] modificationItem = new ModificationItem[2];
	        modificationItem[0] = new ModificationItem(DirContext.REMOVE_ATTRIBUTE,
	        		getPasswordAttribute(oldPass));
	        modificationItem[1] = new ModificationItem(DirContext.ADD_ATTRIBUTE,
	        		getPasswordAttribute(newPass));
	        ctx.modifyAttributes(dn, modificationItem);
		} catch (AuthenticationException e) {
			result = "Invalid current password";
		} catch (OperationNotSupportedException e) {
			result = "Password was not accepted by the server: " + e.getMessage();
			log.warn(result, e);
		} catch (InvalidAttributeValueException e) {
			result = "Password was not accepted by the server (security policy)";
			log.warn(result, e);
		} catch (NamingException e) {
			result = "ERROR! Message from server: " + e.toString() + " " + e.getMessage();
			log.warn(result, e);
		} catch (UnsupportedEncodingException e) {
			result = "INTERNAL password encoding error";
		} finally {
			try {
				if (ctx != null) ctx.close();
			} catch (NamingException e) {
				log.warn("Error closing context", e);
			}
		}
		return result;
	}
	
	private static Attribute getPasswordAttribute(String password)
	    throws UnsupportedEncodingException {
	    byte[] _bytes = encode(password);
	    byte[] bytes = new byte[_bytes.length - 2];
	    System.arraycopy(_bytes, 2, bytes, 0, _bytes.length - 2);
	    Attribute pwdAttribute = new BasicAttribute("unicodePwd");
	    pwdAttribute.add((byte[]) bytes);
	    return pwdAttribute;
	}
	
	private static byte[] encode(String s)
	    throws UnsupportedEncodingException {
	    s = "\"" + s + "\"";
	    return s.getBytes("Unicode");
	}
	
}
