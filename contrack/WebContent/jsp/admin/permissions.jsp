<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.User" %>
<%@page import="java.util.Iterator, java.util.Map, java.util.StringTokenizer" %>
<%@page import="java.util.EnumMap, java.util.EnumSet" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission,
	com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Name.ADMIN, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sd = sec.ok(Name.ADMIN, Permission.DELETE);
boolean sw = sec.ok(Name.ADMIN, Permission.WRITE);
%>
<html>
<head>
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css"></link>
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="../utils/table.js"></script>
<script>
<%
if (sd) {
%>
	function remove(username) {
		if (window.confirm("Remove this group?")) window.location = "permissions.jsp?remove="
			+ username;
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
	function verify() {
		var boxes = document.getElementsByTagName("INPUT");
		var checked = false;
		for (var i = 0; i < boxes.length; i++) {
			if (boxes[i].type == "checkbox") checked = checked || boxes[i].checked;
		}
		if (!checked) window.alert("ERROR!\n-------------------\n"
			+ "At least one checkbox must be checked.");
		else document.getElementById("mainForm").submit();
	}
</script>
</head>
<body>
<div class="title">Groups</div><hr>
<div class="link" onclick="window.location='superAdmin.jsp';">Administration</div>
&gt; Groups<hr>
<%
String sql;
String curGroup = request.getParameter("group");
ResultSet rs = null;
Database db = new Database();
String msg = null;
if (sd && request.getParameter("remove") != null) {
	rs = db.dbQuery("select count(*) from users join user_roles using(username) where "
		+ "role_name = '" + request.getParameter("remove") + "'");
	if (rs.first()) msg = "Cannot delete: " + rs.getInt(1) + " user(s) have this role";
	else db.dbInsert("delete from default_permissions where "
		+ "role_name = '" + request.getParameter("remove") + "'");
} else if (sw && request.getParameter("add") != null) {
	sql = "insert ignore into default_permissions (role_name, name, val) values ("
		+ "'" + curGroup + "', '" + Name.PROJECT + "', '" + Permission.READ + "')";
	db.dbInsert(sql);
	msg = "Group " + curGroup + " created";
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
			sql = "insert ignore into default_permissions (role_name, name, val) values ("
				+ "'" + curGroup + "', '" + name + "', '" + val + "')";
			if (db.dbInsert(sql) == 0) {
				sql = "update default_permissions set val = '" + val + "' where "
					+ "role_name =  '" + curGroup + "' and name = '" + name + "'";
				db.dbInsert(sql);
			}
		} else {
			sql = "delete from default_permissions where role_name = '" + curGroup 
				+ "' and name = '" + name + "'";
			db.dbInsert(sql);
		}
	}
	msg = "Saved";
}
if (rs != null) rs.getStatement().close();
if (msg != null) {
%>
<div class="bold red"><%= msg %></div><hr/>
<% 
}
if (sw) {
%>
<form method="POST">
<fieldset style="width: 33%;">
<legend>Add Group</legend>
<input type="text" name="group">
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
sql = "select distinct role_name from default_permissions where role_name != 'Users'"
	+ " order by role_name";
rs = db.dbQuery(sql);
boolean color = true;
String roleName;
while (rs.next()) {
	color = !color;
	roleName = rs.getString("role_name");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if(color) out.print("class=\"gray\""); %>>
	<td class="left"><%= sd ? "<div class=\"link\" onclick=\"remove('" +
		rs.getString("role_name") + "');\">Remove</div>" : "&nbsp;" %></td>
	<td class="right"><div class="link" onclick="window.location='permissions.jsp?group=<%= 
		roleName %>';"><%= roleName %></div>
		</td>
</tr>
<%
	if (roleName.equals(curGroup)) {
%>
<tr>
<td class="left right <%= color ? "gray" : "" %>" colspan="2" >
	<%= sw ? "<form id=\"mainForm\" method=\"POST\">" : "" %>
	<input type="hidden" name="save" value="t"/>
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
		ResultSet perm = db.dbQuery("select * from default_permissions where role_name = '" + curGroup + "'");
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
		for (Name n : Name.values()) {
			if (n.getName() != null) {
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
		<td colspan="4"><input type="button" onclick="verify();" name="save" value="Save"></td>
	</tr>
<%
		}
%>
	</table><%= sw ? "</form>" : "" %><td>
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