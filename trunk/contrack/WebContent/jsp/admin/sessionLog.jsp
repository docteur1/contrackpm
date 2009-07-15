<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="java.text.DecimalFormat, com.sinkluge.database.Database, com.sinkluge.User" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Name.ADMIN, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
Database db = new Database();
if (request.getParameter("clear") != null) {
	db.dbInsert("truncate table session_log");
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/table.js"></script>
<script>
	function clearLog() {
		if (window.confirm("Clear the session log?")) window.location = "sessionLog.jsp?clear=t";
	}
</script>
</head>
<body>
<div class="title">Session Log</div><hr>
<div class="link" onclick="window.location='superAdmin.jsp';">Administration</div> &gt;
<div class="link" onclick="window.location='sessions.jsp';">Sessions</div> &gt; Session Log &nbsp;
<div class="link" onclick="clearLog();">Clear</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
<td class="left head">Username</td>
<td class="head">Created</td>
<td class="head">Destroyed</td>
<td class="head">Duration</td>
<td class="head">Reason Destroyed</td>
<td class="head">Host</td>
<td class="right head">Agent</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
ResultSet rs = db.dbQuery("select * from session_log order by destroyed desc");
boolean c = true;
long created, destroyed, duration;
DecimalFormat df = new DecimalFormat("00");
User user;
while (rs.next()) {
	c = !c;
	created = rs.getTimestamp("created").getTime();
	destroyed = rs.getTimestamp("destroyed").getTime();
	duration = destroyed - created;
	user = User.getUser(rs.getInt("user_id"));
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (c) out.print("class=\"gray\""); %>>
<td class="left"><%= user != null ? user.getFullName() : "&nbsp;" %></td>
<td class="it aright"><%= FormHelper.timestamp(created) %></td>
<td class="it aright"><%= FormHelper.timestamp(destroyed) %></td>
<td class="it aright"><%= df.format(duration/3600000) + ":" + df.format((duration%3600000)/60000) + ":" 
	+ df.format((duration%60000)/1000) %></td>
<td class="it"><%= rs.getString("reason") %></td>
<td class="it"><%= rs.getString("host") %></td>
<td class="right"><%= rs.getString("agent") %></td>
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