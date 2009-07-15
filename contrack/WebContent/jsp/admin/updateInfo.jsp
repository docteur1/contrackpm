<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.accounting.AccountingUtils, accounting.Accounting" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper,
	com.sinkluge.utilities.DataUtils" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
String site_id = request.getParameter("site_id");
if (site_id == null) site_id = "1";
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
Database db = new Database();
if (request.getParameter("short_name") == null) {
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<form action="updateInfo.jsp" method="POST">
<font size="+1">Site Settings</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Site Settings &nbsp;
<%
try {
	Accounting acc = AccountingUtils.getAccounting(application, Integer.parseInt(site_id));
	if (acc.getWebConfigJspName() != null) out.println("<div class=\"link\" onclick=\"" +
		"window.location='" + acc.getWebConfigJspName() + "?site_id=" +
		site_id + "';\">Accounting Settings</div>");
} catch (Exception e) {
	org.apache.log4j.Logger.getLogger(this.getClass()).debug("Accounting error", e);
}
%>
<hr>
<%
if (request.getParameter("saved") != null) out.print("<font color=\"red\"><b>Settings Saved</b></font><hr>");
%>
<table>
	<tr>
		<td class="lbl">Site</td>
		<td><select name="site_id" onChange="window.location = 'updateInfo.jsp?site_id=' + this.value;">
<%
	ResultSet rs = db.dbQuery("select site_id, site_name from sites order by site_id");
	while (rs.next()) out.println("<option value=\"" + rs.getString(1) + "\" " + FormHelper.sel(rs.getString(1),
		site_id) + ">" + rs.getString(2) + "</option>");
	if (rs != null) rs.getStatement().close();
%>
		</select></td>
	</tr>
<%
	rs = db.dbQuery("select * from settings where id = 'site" + site_id + "' and name not like 'kf_%'");
	String name;
	while (rs.next()) {
		name = rs.getString("name");%>
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
	ResultSet rs = db.dbQuery("select * from settings where id = 'site" + site_id 
			+ "' and name not like 'kf_%'", true);
	while (rs.next()) {
		name = rs.getString("name");
		rs.updateString("val", DataUtils.chkFormNull(request.getParameter(name)));
		rs.updateRow();
	}
	rs.getStatement().close();
	rs = null;
	attr.load();
	db.disconnect();
	response.sendRedirect("updateInfo.jsp?saved=true&site_id=" + site_id);
}
%>