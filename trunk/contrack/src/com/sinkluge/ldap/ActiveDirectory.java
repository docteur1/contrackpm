package com.sinkluge.ldap;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attributes;
import javax.naming.directory.BasicAttribute;
import javax.naming.directory.ModificationItem;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.ldap.InitialLdapContext;
import javax.naming.ldap.LdapContext;

import com.sinkluge.Info;

final class ActiveDirectory {

	private LdapContext ctx;
	private String searchBase;

	private HashMap<String, Object> modItems = null;

	protected LdapContext getContext() {
		return ctx;
	}

	protected ActiveDirectory(Info in) throws NamingException {
		Hashtable<String, String> ht = new Hashtable<String, String>();
		ht.put(Context.INITIAL_CONTEXT_FACTORY,
				"com.sun.jndi.ldap.LdapCtxFactory");
		ht.put(Context.PROVIDER_URL, in.ldap_host + " " + in.alt_ldap_host);
		ht.put(Context.SECURITY_PRINCIPAL, in.bind_dn);
		ht.put(Context.SECURITY_CREDENTIALS, in.bind_pw);
		ht.put(Context.REFERRAL, "follow");
		ht.put("java.naming.ldap.attributes.binary", "objectGUID");
		ht.put("com.sun.jndi.ldap.connect.timeout", "3000");
		searchBase = in.search_base;
		ctx = new InitialLdapContext(ht, null);
	}

	protected ActiveDirectory(LdapContext ctx) {
		this.ctx = ctx;
	}

	protected void setAttribute(String name, Object value) {
		if (modItems == null)
			modItems = new HashMap<String, Object>();
		if (value == null || value.equals(""))
			modItems.put(name, null);
		else
			modItems.put(name, value);
	}

	@SuppressWarnings("unchecked")
	protected void saveUser(String id) throws NamingException {
		Attributes attrs = getUserById(id);
		// Let's replace the attributes that exist
		ArrayList<Object> al = new ArrayList<Object>();
		String value, name;
		Object obj;
		ModificationItem mi = null;
		ArrayList hm;
		byte[] photo;
		BasicAttribute ba;
		for (Iterator i = modItems.keySet().iterator(); i.hasNext();) {
			name = (String) i.next();
			obj = modItems.get(name);
			if (obj instanceof String) {
				value = (String) obj;
				// If the value is null and the attribute exists remove it...
				if ((value == null || value.equals(""))
						&& (attrs.get(name) != null))
					mi = new ModificationItem(LdapContext.REMOVE_ATTRIBUTE,
							new BasicAttribute(name));
				// Otherwise replace or create it.
				else
					mi = new ModificationItem(LdapContext.REPLACE_ATTRIBUTE,
							new BasicAttribute(name, value));
			} else if (obj instanceof ArrayList) {
				hm = (ArrayList) obj;
				ba = new BasicAttribute(name);
				for (Iterator j = hm.iterator(); j.hasNext();) {
					value = (String) j.next();
					ba.add(value);
				}
				if (ba.size() > 0)
					mi = new ModificationItem(LdapContext.REPLACE_ATTRIBUTE, ba);
				else
					mi = new ModificationItem(LdapContext.REMOVE_ATTRIBUTE, ba);
			} else if (obj instanceof byte[]) {
				photo = (byte[]) obj;
				if ((photo == null || photo.length == 0)
						&& (attrs.get(name) != null))
					mi = new ModificationItem(LdapContext.REMOVE_ATTRIBUTE,
							new BasicAttribute(name));
				// Otherwise replace or create it.
				else
					mi = new ModificationItem(LdapContext.REPLACE_ATTRIBUTE,
							new BasicAttribute(name, photo));
			} else if (obj == null && attrs.get(name) != null) {
				mi = new ModificationItem(LdapContext.REMOVE_ATTRIBUTE,
						new BasicAttribute(name));
			}
			if (mi != null)
				al.add((Object) mi);
			mi = null;
		}
		ModificationItem[] mods = new ModificationItem[al.size()];
		mods = (ModificationItem[]) al.toArray(new ModificationItem[0]);
		modItems.clear();
		al.clear();
		ctx.modifyAttributes((String) attrs.get("distinguishedName").get(),
				mods);
	}

	@SuppressWarnings("unchecked")
	protected List<Attributes> getGroupUsers(String groupName)
			throws NamingException, IOException {
		SearchControls sc = new SearchControls();
		sc.setSearchScope(SearchControls.SUBTREE_SCOPE);
		String filter = "(&(objectClass=user)(memberOf=" + groupName + "))";
		String retAttrs[] = { "sn", "givenName", "sAMAccountName",
				"objectGUID", "mail" };
		sc.setReturningAttributes(retAttrs);
		NamingEnumeration ne = ctx.search(searchBase, filter, sc);
		Attributes attrs = null;
		SearchResult sr = null;
		List<Attributes> list = new ArrayList<Attributes>();
		while (ne.hasMore()) {
			sr = (SearchResult) ne.next();
			attrs = sr.getAttributes();
			list.add(attrs);
		}
		return list;
	}

	protected Attributes getUserByUsername(String username)
			throws NamingException {
		SearchControls sc = new SearchControls();
		sc.setSearchScope(SearchControls.SUBTREE_SCOPE);
		NamingEnumeration<SearchResult> ne = ctx.search(searchBase, "sAMAccountName="
				+ username, sc);
		Attributes attrs = null;
		if (ne.hasMore()) {
			SearchResult sr = ne.next();
			attrs = sr.getAttributes();
		}
		ne.close();
		return attrs;
	}

	protected Attributes getUserById(String id) throws NamingException {
		return ctx.getAttributes("<GUID=" + id + ">");
	}

	protected void close() throws NamingException {
		ctx.close();
		ctx = null;
		if (modItems != null)
			modItems.clear();
		modItems = null;
	}
}
