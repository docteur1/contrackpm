<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) response.sendRedirect("../accessDenied.html");
int siteId = Integer.parseInt(request.getParameter("site_id"));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" media="all" />
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="../utils/spell.js"></script>
</head>
<body>
<%
String letter = request.getParameter("letter");
String query = "select * from cost_types where site_id = " + siteId + " and letter = '" + letter + "'";
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
rs.first();
%>
<form id="main" action="costTypeContract.jsp" method="POST" onSubmit="return checkForm(this);">
<input type="hidden" name="site_id" value="<%= siteId %>">
<font size="+1">Contract: <%= letter + " - " + rs.getString("description") %></font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; <a href="costTypes.jsp?site_id=<%= siteId %>">Cost Types</a> &gt; Contract
<%
ResultSet site = db.dbQuery("select site_name from sites where site_id = " + siteId);
if (site.next()) out.print(site.getString(1));
if (site != null) site.getStatement().close();
%>
<hr>
<%
if (request.getParameter("save") != null) {
	rs.updateString("contract", request.getParameter("contract"));
	rs.updateRow();
	out.print("<div class=\"bold red\">Saved</div><hr>");
}
%>
<div><input type="submit" value="Save"> 
<div style="display: inline; width: 500px"><b>%a</b> Amount, <b>%A</b> Long Amount, <b>%r</b> Retention Rate, 
	<b>%n</b> Project Name, <b>%p</b> Phone, <b>%d</b> Address, <b>%c</b> City, <b>%s</b> State, <b>%z</b> Zip</div>
<input type="hidden" name="letter" value="<%= letter %>">
<input type="hidden" name="save" value="true"></div>
<textarea  style="margin-top: 10px; font-family: Times;" cols="120" rows="25" name="contract"><%= FormHelper.string(rs.getString("contract")) %></textarea>
</form>
<script>
	var d = document.getElementById("main").contract;
	d.required = true;
	d.spell = true;
	d.eName = "Contract Text";
</script>
</body>
</html>
<%
db.disconnect();
%>