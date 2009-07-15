<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="java.sql.ResultSet, com.sinkluge.security.Security, 
    com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.DataUtils,
    com.sinkluge.database.Database" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) response.sendRedirect("../accessDenied.html");
if (request.getParameter("session_timeout_mins") == null) {
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<form action="updateGlobalInfo.jsp" method="POST">
<font size="+1">Global Settings</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Global Settings<hr>
<%
if (request.getParameter("saved") != null) out.print("<font color=\"red\"><b>Settings Saved</b></font><hr>");
%>
<table>
<%
	Database db = new Database();
	ResultSet rs = db.dbQuery("select * from settings where id = 'site'");
	String name;
	while (rs.next()) {
		name = rs.getString("name");
%>
	<tr>
		<td class="lbl"><%= name %></td>
		<td><input type="text" name="<%= name %>" value="<%= FormHelper.string(rs.getString("val")) %>" size="80" /></td>
	</tr>
<%
	}
	rs.getStatement().close();
	rs = null;
	db.disconnect();
%>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Save" /></td>
	</tr>
</table>
</form>
</body>
</html>
<%
} else {
	String name;
	Database db = new Database();
	ResultSet rs = db.dbQuery("select * from settings where id = 'site'", true);
	while (rs.next()) {
		name = rs.getString("name");
		rs.updateString("val", DataUtils.chkFormNull(request.getParameter(name)));
		rs.updateRow();
	}
	rs.getStatement().close();
	rs = null;
	in.loadProperties();
	db.disconnect();
	response.sendRedirect("updateGlobalInfo.jsp?saved=true");
}
%>