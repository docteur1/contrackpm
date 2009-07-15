<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@ page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@ page import="java.util.HashMap, accounting.ce.CEAccounting" %>
<%@ page import="com.sinkluge.accounting.AccountingUtils, com.sinkluge.database.Database" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(com.sinkluge.security.Name.ADMIN,
		com.sinkluge.security.Permission.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
String siteId = request.getParameter("site_id");
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<div class="title">ComputerEase&#0153; Settings</div><hr>
<div class="link" onclick="window.location='superAdmin.jsp';">Administration</div>
&gt; <div class="link" onclick="window.location='updateInfo.jsp?site_id=<%= siteId %>';"
		>Site Settings</div>
&gt; ComputerEase&#0153; Settings<hr>
<%
Database db = new Database();
ResultSet rs = db.dbQuery("select * from settings where id = 'ce" + siteId + "'", true);
HashMap<String, String> hm = new HashMap<String, String>();
boolean saved = false;
while (rs.next()){
	if (request.getParameter("submit") != null && 
			request.getParameter(rs.getString("name")) != null) {
		rs.updateString("val", request.getParameter(rs.getString("name")));
		rs.updateRow();
		saved = true;
	}
	hm.put(rs.getString("name"), rs.getString("val"));
}
if (saved) out.println("<div class=\"bold red\">Saved</div><hr>");
if (rs != null) rs.getStatement().close();
%>
<form method="POST">
<table>
	<tr>
		<td class="lbl">Site</td>
		<td><select name="site_id" 
			onchange="window.location = 'ceSettings.jsp?site_id=' + this.value;">
<%
rs = db.dbQuery("select site_id, site_name from sites order by site_id");
while (rs.next()) {
	out.println("<option value=\"" + rs.getString(1) + "\" " + 
		FormHelper.sel(rs.getString(1), siteId) + ">" + rs.getString(2) 
		+ "</option>");
}
if (rs != null) rs.getStatement().close();
%>
		</select></td>
	</tr>
<tr>
<td class="lbl">Process Vouchers for Group</td>
<td><select name="route">
<%
String temp;
try {
	CEAccounting acc = (CEAccounting) AccountingUtils.getAccounting(application, 
			Integer.parseInt(siteId));
	java.util.List<String> l = acc.getRoutes();
	if (l != null && l.size() > 0) {
		for (java.util.Iterator<String> i = l.iterator(); i.hasNext(); ){
			temp = i.next();
			out.println("<option value=\"" + temp + "\"" + 
				FormHelper.sel(temp, hm.get("route")) + ">" + temp + "</option>");
		}
	}
} catch (Exception e) {
	org.apache.log4j.Logger.getLogger(this.getClass()).debug("Accounting error", e);
}
%>
</select>
</td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="submit" name="submit" value="Save"/></td>
</tr>
</table>
</form>
</body>
</html>
<%
db.disconnect();
%>