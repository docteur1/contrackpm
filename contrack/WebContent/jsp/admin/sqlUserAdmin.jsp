<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.sinkluge.security.*,
    java.sql.ResultSet, com.sinkluge.database.Database, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
if (!sec.ok(Name.ADMIN, Permission.READ)){
	response.sendRedirect("../accessDenied.jsp");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" >
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/table.js"></script>
</head>
<body>
<div class="title">Users</div><hr/>
<div class="link" onclick="window.location='superAdmin.jsp'">Administration</div> &gt; Users
&nbsp; <div class="link" onclick="window.location='sqlUser.jsp'">New</div>
<hr/>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<td class="head">Username</td>
	<td class="head">Full Name</td>
	<td class="head">Active</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
Database db = new Database();
ResultSet rs = db.dbQuery("select id, username, first_name, last_name, active from users "
	+ "order by active desc, last_name, first_name");
boolean color = true;
while (rs.next()) {
	color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left right"><div class="link" onclick="window.location='sqlUser.jsp?id=<%= 
		rs.getString("id") %>';">Edit</div></td>
	<td class="it"><%= rs.getString("username") %></td>
	<td class="it"><%= rs.getString("last_name") + ", " + rs.getString("first_name") %></td>
	<td class="input"><%= com.sinkluge.utilities.Widgets.checkmark(rs.getBoolean("active"),
		request) %></td>
	<td class="right"><%= rs.getString("id") %></td>
</tr>
<%
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>