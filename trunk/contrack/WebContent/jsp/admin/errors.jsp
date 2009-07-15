<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper, 
	com.sinkluge.security.Security, com.sinkluge.User, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
Database db = new Database();
if (request.getParameter("del") != null) {
	db.dbInsert("delete from error_log where id = " + request.getParameter("del"));
}
if (request.getParameter("delall") != null) {
	db.dbInsert("delete from error_log");
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/table.js"></script>
<script>
	function del(id) {
		if (window.confirm("Delete this error?")) window.location = "errors.jsp?del=" + id;
	}
</script>
</head>
<body>
<div class="title">Errors</div><hr>
<div class="link" onclick="window.location='superAdmin.jsp';">Administration</div> &gt; Errors &nbsp;
<div class="link" onclick="if(window.confirm('Delete all errors?')) window.location='errors.jsp?delall=t';">Delete All</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
<td class="left head nosort">Delete</td>
<td class="head nosort">Log</td>
<td class="head">Time</td>
<td class="head">User</td>
<td class="right head">Comments</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
ResultSet rs = db.dbQuery("select * from error_log order by error_time desc");
boolean c = true;
User user;
while (rs.next()) {
	c = !c;
	user = User.getUser(rs.getInt("user_id")); 
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (c) out.print("class=\"gray\""); %>>
<td class="left"><div class="link" onclick="del(<%= rs.getString("id") %>);">Delete</div></td>
<td class="right"><div class="link" onclick="window.location='../servlets/error?id=<%= rs.getString("id") %>';">Log</div></td>
<td class="it"><%= FormHelper.timestamp(rs.getTimestamp("error_time")) %></td>
<td class="it"><%= user.getFullName() %></td>
<td class="right" style="vertical-align: top;"><%= FormHelper.stringTable(rs.getString("comments")) %></td>
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