<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.User" %>
<%@page import="java.util.Iterator, java.util.Map, java.util.StringTokenizer" %>
<%@page import="java.util.EnumMap, java.util.EnumSet" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Name.PERMISSIONS, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sd = sec.ok(Name.PERMISSIONS, Permission.DELETE);
boolean sw = sec.ok(Name.PERMISSIONS, Permission.WRITE);
%>

<%@page import="java.util.Arrays"%>
<%@page import="com.sinkluge.security.NameComparator"%><html>
<head>
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css"></link>
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="../utils/table.js"></script>
<script>
<%
if (sd) {
%>
	function remove(userId) {
		if (window.confirm("Remove this user from this job?")) window.location = "permissions.jsp?remove="
			+ userId;
	}
<%
}
if (sw) {
%>
	function toggle(ref) {
		var tr = ref.parentNode.parentNode;
		var inputs = tr.getElementsByTagName("INPUT");
		for (var i = 0; i < inputs.length; i++) {
			inputs[i].checked = !inputs[i].checked;
		}
	}
<%
}
%>
</script>
</head>
<body>
<div class="title">Project Permissions</div><hr>
<%= com.sinkluge.utilities.Widgets.logLink(Integer.toString(attr.getJobId()),
	com.sinkluge.Type.PROJECT, "window", "projects/permissions.jsp", request) %><hr>
<%
if (sw) {
%>
<form action="permissions.jsp" method="POST">
<fieldset style="width: 33%;">
<legend>Add User</legend>
<%= com.sinkluge.utilities.Widgets.userList(0, "user_id") %>
<input type="submit" name="add" value="Add">
</fieldset>
</form>
<%
}
%>
<table cellspacing="0" cellpadding="3" style="margin-top: 8px;">
<tr>
	<td class="left head">Remove</td>
	<td class="right head">Name</td>
</tr>
<%
String sql;
int curUserId = 0;
try {
	curUserId = Integer.parseInt(request.getParameter("user_id"));
} catch (NumberFormatException e) {}
ResultSet rs;
Database db = new Database();
if (sd && request.getParameter("remove") != null) {
	db.dbInsert("delete from job_permissions where "
		+ "user_id = " + request.getParameter("remove") + " and job_id = " 
		+ attr.getJobId());
	User user = User.getUser(request.getParameter("remove"));
	com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.PROJECT,
		Integer.toString(attr.getJobId()), "Permissions: removed for user " 
		+ user.getFullName(), session);
}
else if (sw && request.getParameter("add") != null) {
	sql = "insert ignore into job_permissions (job_id, user_id, name, val) values ("
		+ attr.getJobId() + ", '" + curUserId + "', '" + Name.PROJECT + "', '" + Permission.READ + "')";
	User user = User.getUser(curUserId);
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
		Integer.toString(attr.getJobId()), "Permissions: added user " 
		+ user.getFullName(), session);
	db.dbInsert(sql);
	db.disconnect(); 
	response.sendRedirect("permissions.jsp?userId=" + curUserId);
	return;
} else if (sw && request.getParameter("save") != null) {
	String val;
	for (Name name : Name.values()) {
		val = "";
		if (request.getParameter("D" + name) != null) val += "DELETE,";
		if (request.getParameter("W" + name) != null) val += "WRITE,";
		if (request.getParameter("R" + name) != null) val += "READ,";
		if (request.getParameter("P" + name) != null) val += "PRINT,";
		if (!"".equals(val)) {
			val = val.substring(0, val.length() - 1);
			sql = "insert ignore into job_permissions (job_id, user_id, name, val) values ("
				+ attr.getJobId() + ", '" + curUserId + "', '" + name + "', '" 
				+ val + "')";
			if (db.dbInsert(sql) == 0) {
				sql = "update job_permissions set val = '" + val + "' where "
					+ "job_id = " + attr.getJobId() + " and user_id =  " + curUserId
					+ " and name = '" + name + "'";
				db.dbInsert(sql);
			}
		} else {
			sql = "delete from job_permissions where job_id = " + attr.getJobId()
				+ " and user_id = " + curUserId + " and name = '" + name + "'";
			db.dbInsert(sql);
		}
	}
	// update the permissions...
	sec.setJob(attr.getJobId(), request);
	User user = User.getUser(curUserId);
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
		Integer.toString(attr.getJobId()), "Permissions: updated for user " 
		+ user.getFullName(), session);
}
sql = "select distinct user_id from job_permissions join users on user_id = id where job_id = "
	+ attr.getJobId() + " order by last_name, first_name";
rs = db.dbQuery(sql);
boolean color = true;
String username;
java.util.List<User> ul = new java.util.ArrayList<User>();
User user;
while (rs.next()) {
	user = User.getUser(rs.getInt(1));
	if (user != null) ul.add(user);
}
java.util.Collections.sort(ul);
for (java.util.Iterator<User> i = ul.iterator(); i.hasNext();) {
	user = i.next();
	color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if(color) out.print("class=\"gray\""); %>>
	<td class="left"><%= sd ? "<div class=\"link\" onclick=\"remove('" +
		user.getId() + "');\">Remove</div>" : "&nbsp;" %></td>
	<td class="right"><div class="link" 
		<%= !user.isActive() ? "style=\"text-decoration: line-through\"" : "" %>
		onclick="window.location='permissions.jsp?user_id=<%= 
		user.getId() %>';"><%= user.getListName() %></div>
		</td>
</tr>
<%
	if (user.getId() == curUserId) {
%>
<tr>
<td class="left right <%= color ? "gray" : "" %>" colspan="2" >
	<%= sw ? "<form method=\"POST\">" : "" %>
	<table cellspacing="0" cellpadding="0">
	<tr>
		<td>&nbsp;</td>
		<%= sw ? "<td class=\"bold acenter\" style=\"padding-right: 3px;\">Toggle</td>" : ""%>
		<td class="bold acenter" style="padding-right: 3px;">Delete</td>
		<td class="bold acenter" style="padding-right: 3px;">Write</td>
		<td class="bold acenter" style="padding-right: 3px;">Print</td>
		<td class="bold acenter" style="padding-right: 3px;">Read</td>
	</tr>
<%
		ResultSet perm = db.dbQuery("select * from job_permissions where job_id = " 
				+ attr.getJobId() + " and user_id = " + curUserId);
		Map<Name, EnumSet<Permission>> permissions = new EnumMap<Name, EnumSet<Permission>>(Name.class);
		permissions.clear();
		StringTokenizer st;
		Name name;
		EnumSet<Permission> per;
		while(perm.next()) {
			per = EnumSet.noneOf(Permission.class);
			name = Enum.valueOf(Name.class, perm.getString("name"));
			st = new StringTokenizer(perm.getString("val"), ",");
			while (st.hasMoreTokens()) {
				per.add(Enum.valueOf(Permission.class, st.nextToken()));
			}
			permissions.put(name, per);
		}
		perm.getStatement().close();
		Name[] names = Name.values();
		java.util.Comparator<Name> cn = new com.sinkluge.security.NameComparator();
		java.util.Arrays.sort(names, cn);
		for (Name n : names) {
			if (!n.isAdminOnly()) {
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);">
		<td><%= n.getName() %></td>
		<%= sw ? "<td class=\"acenter\"><input type=\"checkbox\" "
			+ "onclick=\"toggle(this);\"></td>"	: "" %>
		<td class="acenter"><input type="checkbox" name="D<%= n %>" value="y"
			<%= FormHelper.chk(permissions.containsKey(n) && 
					permissions.get(n).contains(Permission.DELETE)) %>></td>
		<td class="acenter"><input type="checkbox" name="W<%= n %>" value="y"
			<%= FormHelper.chk(permissions.containsKey(n) && 
					permissions.get(n).contains(Permission.WRITE)) %>></td>
		<td class="acenter"><input type="checkbox" name="P<%= n %>" value="y"
			<%= FormHelper.chk(permissions.containsKey(n) && 
					permissions.get(n).contains(Permission.PRINT)) %>></td>
		<td class="acenter"><input type="checkbox" name="R<%= n %>" value="y"
			<%= FormHelper.chk(permissions.containsKey(n) && 
					permissions.get(n).contains(Permission.READ)) %>></td>
	</tr>
<%
			}
		}
		if (sw) {
%>
	<tr>
		<td>&nbsp;</td>
		<td colspan="4"><input type="submit" name="save" value="Save">
<%
			if (request.getParameter("save") != null) {
%>
			&nbsp; <span class="bold red">Saved</span>
<%
			}

%>		
		</td>
	</tr>
<%
		}
%>
	</table><%= sw ? "</form>" : "" %>
</td>
</tr>
<%
	}
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</body>
</html>