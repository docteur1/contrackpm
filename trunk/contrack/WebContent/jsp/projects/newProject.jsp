<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Contrack - New Project (1 of 3)</title>
	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<form action="newProject.jsp" method="POST">
<font size="+1">New Project (1 of 3) - Owner Contact</font><hr>
<a href="../">Contrack</a> &gt; New Project (Owner Contact)<hr>
<table>
	<tr>
		<td class="lbl">Search company name:</td>
		<td><input id="searchBox" type="text" name="search" value="<%= FormHelper.string(request.getParameter("search")) %>"></td>
		<td><input type="submit" value="Search"></td>
	</tr>
</table>
</form>
<script>
	document.getElementById("searchBox").focus();
	document.getElementById("searchBox").select();
</script>
<%
if (request.getParameter("search") != null) {
%>
<hr>
<div class="bold" style="margin-bottom: 12px;">Select a contact</div>
<%
	String query = "select c.company_id, c.company_name, c.city, c.state, n.contact_id, n.name, n.city, n.state " +
		"from company as c left join contacts as n using (company_id) where company_name like ? order by " +
		"company_name, name limit 25";
	Database db = new Database();
	PreparedStatement ps = db.preStmt(query);
	ps.setString(1, request.getParameter("search") + "%");
	ResultSet rs = ps.executeQuery();
	while(rs.next()) {
		String contact_id = rs.getString("contact_id");
		if (contact_id != null) {
%>
	<div><a href="newProject2.jsp?ocontact_id=<%= contact_id %>">
		<%= rs.getString("company_name") + ": " + FormHelper.string(rs.getString("name")) %></a> 
		(<%= FormHelper.string(rs.getString("n.city")) + ", " + FormHelper.string(rs.getString("n.state")) %>)</div>
<%
		} else {
%>
	<div><a href="newProject2.jsp?ocompany_id=<%= rs.getString("company_id") %>">
		<%= rs.getString("company_name") %></a> 
		(<%= FormHelper.string(rs.getString("c.city")) + ", " + FormHelper.string(rs.getString("c.state")) %>)</div>
<%	
		}
	}
	if (rs != null) rs.close();
	rs = null;
	if (ps != null) ps.close();
	ps = null;
	db.disconnect();
}
%>
</body>
</html>