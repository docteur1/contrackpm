<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="java.sql.ResultSet, com.sinkluge.security.Security, 
    com.sinkluge.utilities.FormHelper, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
Database db = new Database();
if (request.getParameter("clear") != null) db.dbInsert("truncate table ext_sessions");
if (request.getParameter("closed") != null) db.dbInsert("delete from ext_sessions where closed = 1");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript">
		function clearLog() {
			if (window.confirm("Clear this list?")) window.location = "externalSessions.jsp?clear=t";
		}
		function clearClosed() {
			if (window.confirm("Clear closed sessions?")) window.location = "externalSessions.jsp?closed=t";
		}
	</script>
	<script src="../utils/table.js"></script>
</head>
<body>
<div class="title">External Sessions</div>
<hr>
<div class="link" onclick="window.location='superAdmin.jsp'">Administration</div> &gt;
External Sessions &nbsp;
<div class="link" onclick="clearLog();">Clear All</div> &nbsp;
<div class="link" onclick="clearClosed();">Clear Closed</div>
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
		<td class="left head">Email</td>
		<td class="head">Name</td>
		<td class="head">Host</td>
		<td class="head">Agent</td>
		<td class="head">Closed</td>
		<td class="right head">Created</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
ResultSet rs = db.dbQuery("select * from ext_sessions");
boolean gray = true;
while (rs.next()) {
	gray = !gray;
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (gray) out.print("class=\"gray\""); %>>
		<td class="left"><%= rs.getString("email") %></td>
		<td class="it"><%= rs.getString("name") %></td>
		<td class="it"><%= rs.getString("host") %></td>
		<td class="it"><%= rs.getString("agent") %></td>
		<td class="input"><%= (rs.getBoolean("closed")?"<img src=\"../images/checkmark.gif\">":"&nbsp;") %></td>
		<td class="right"><%= FormHelper.timestamp(rs.getTimestamp("created")) %></td>
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