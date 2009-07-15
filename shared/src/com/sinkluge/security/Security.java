package com.sinkluge.security;

import java.sql.ResultSet;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public class Security implements java.io.Serializable {

	private static final long serialVersionUID = 1L;
	
	private boolean root = false;

	@Deprecated
	public static final int ADMIN = 0;
	@Deprecated
	public static final int JOB = 1;
	@Deprecated
	public static final int JOB_PER = 2;
	@Deprecated
	public static final int ACCOUNT = 3;
	@Deprecated
	public static final int COST_DATA = 4;
	@Deprecated
	public static final int CO = 5;
	@Deprecated
	public static final int SUBCONTRACT = 6;
	@Deprecated
	public static final int RFI = 7;
	@Deprecated
	public static final int SUBMITTALS = 8;
	@Deprecated
	public static final int TRANSMITTALS = 9;
	@Deprecated
	public static final int LETTERS = 10;
	@Deprecated
	public static final int PENDING_CO = 11;
	//@Deprecated
	//public static final int DOCUMENTS = 12;
	@Deprecated
	public static final int LABOR_COSTS = 13;
	@Deprecated
	public static final int UNLOCK_BUDGET = 14;
	@Deprecated
	public static final int APPROVE_PAYMENT = 15;
	
	@Deprecated
	public static final int READ = 4;
	@Deprecated
	public static final int WRITE = 2;
	@Deprecated
	public static final int DELETE = 1;
	@Deprecated
	public static final int PRINT = 8;
	@Deprecated
	public static final int NONE = 0;
	
	private Logger log = Logger.getLogger(Security.class);
	
	private Map<Name, EnumSet<Permission>> permissions = new EnumMap<Name, EnumSet<Permission>>(Name.class);

	public void isAdmin(boolean root) {
		this.root = root;
	}
	
	public Map<String, Boolean> getJSONPermissions() {
		Map<String, Boolean> map = new HashMap<String, Boolean>();
		for (Name name : Name.values()) map.put(name.toString(), ok(name, Permission.READ));
		return map; 
	}
	
	public boolean ok(Name name, Permission permission) {
		if (name != null) return permissions.containsKey(name) && permissions.get(name).contains(permission);
		else return true;
	}
	
	@Deprecated
	public boolean ok(int permission_name, int permission) {
		for (Name name : Name.values()) {
			if (name.ordinal() == permission_name) {
				switch (permission) {
					case DELETE:
						return ok(name, Permission.DELETE);
					case WRITE:
						return ok(name, Permission.WRITE);
					case READ:
						return ok(name, Permission.READ);
					case PRINT:
						return ok(name, Permission.PRINT);
				}
				break;
			}
		}
		return false;
	}

	@Deprecated
	public String getPermission(int permission_name) {
		int retVal = 0;
		for (Name name : Name.values()) {
			if (name.ordinal() == permission_name) {
				if (ok(name, Permission.DELETE)) retVal = DELETE;
				if (ok(name, Permission.WRITE)) retVal |= WRITE;
				if (ok(name, Permission.READ)) retVal |= READ;
				if (ok(name, Permission.PRINT)) retVal |= PRINT;
				break;
			}
		}
		return Integer.toString(retVal);
	}

	private void getDefaultPermissions(String role) throws Exception {
		ResultSet rs = null;
		Database db = new Database();
		rs = db.dbQuery("select * from default_permissions where role_name = '" + role + "'");
		Name name;		
		StringTokenizer st;
		EnumSet<Permission> per;
		while (rs.next()) {
			name = Enum.valueOf(Name.class, rs.getString("name"));
			per = permissions.get(name);
			if (per == null) per = EnumSet.noneOf(Permission.class);
			st = new StringTokenizer(rs.getString("val"), ",");
			while (st.hasMoreTokens()) {
				per.add(Enum.valueOf(Permission.class, st.nextToken()));
			}
			permissions.put(name, per);
		}
		if (rs != null) rs.getStatement().close();
		rs = null;
		db.disconnect();
	}

	public void setJob(int jobId, HttpServletRequest request) throws Exception {
		if (root) {
			log.debug("setJob: is root");
			for (Name name : Name.values()) {
				permissions.put(name, EnumSet.allOf(Permission.class));
			}
			return;
		}
		ResultSet rs = null;
		ResultSet roles = null;
		Attributes attr = (Attributes) request.getSession().getAttribute("attr");
		Database db = new Database();
		rs = db.dbQuery("select * from job_permissions where job_id = " + jobId + " and user_id = " + 
			attr.getUserId());
		permissions.clear();
		StringTokenizer st;
		Name name;
		EnumSet<Permission> per;
		while(rs.next()) {
			per = EnumSet.noneOf(Permission.class);
			name = Enum.valueOf(Name.class, rs.getString("name"));
			st = new StringTokenizer(rs.getString("val"), ",");
			while (st.hasMoreTokens()) {
				per.add(Enum.valueOf(Permission.class, st.nextToken()));
			}
			permissions.put(name, per);
		}
		roles = db.dbQuery("select role_name from roles");
		String roleName;
		while (roles.next()) {
			// Load permissions
			roleName = roles.getString(1);
			if (request.isUserInRole(roleName)) {
				log.debug("setJob: User has role: " + roleName);
				getDefaultPermissions(roleName);
			} else log.debug("setJob: User does NOT have role" + roleName);
		} // end while (roles.next())
		if (rs != null) rs.getStatement().close();
		rs = null;
		if (roles != null) roles.getStatement().close();
		roles = null;
		db.disconnect();
	}

}

