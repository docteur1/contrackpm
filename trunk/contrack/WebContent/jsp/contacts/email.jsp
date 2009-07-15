<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<jsp:useBean id="JSONRPCBridge" scope="session"
     class="org.jabsorb.JSONRPCBridge" />

<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<% 
JSONRPCBridge.registerClass("search", com.sinkluge.JSON.Search.class); 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/jsonrpc.js"></script>
	<script src="scripts/email.js"></script>
	<script>
		try {
			var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
		} catch (e) {
			alert(e);
		}
	</script>
	<style>
		table {
			margin: 5px;
		}
	</style>
</head>
<body>
<font size="+1">Email Contacts</font><hr>
<a href="reviewCompanies.jsp">Companies</a> &gt; Email Contacts &nbsp; 
<a href="javascript: email();">Send Email</a><hr>
<table>
<tr>
<td style="vertical-align: top;">
<fieldset>
<legend>Project Contacts</legend>
<table cellspacing="0" cellpadding="3">
<tr>
	<td class="left head right" colspan="2"><a href="javascript: selectAll();">Invert Selection</a> &nbsp; <a href="javascript: add();">Add Emails</a></td>
</tr>
<%
String query = "(select distinct company_name, name, email from contracts join company using(company_id) left join contacts "
	+ "using(contact_id) where email is not null and email != '' and job_id = " + attr.getJobId();
query += ") union (select company_name, name, email from job_contacts join company using(company_id) left join contacts "
	+ "using(contact_id) where email is not null and email != '' and job_id = " + attr.getJobId()
	+ ") order by name";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
boolean color = true;
while (rs.next()) {
	color = !color;
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left input"><input type="checkbox" value="<%= rs.getString("name") + " <" + rs.getString("email") + ">" %>"></td>
	<td class="right" title="<%= rs.getString("company_name") %>"><%= rs.getString("name") + " &lt;" + rs.getString("email") + "&gt;" %></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</fieldset>
</td>
<td style="vertical-align: top;">
<fieldset>
<legend>Search Contacts</legend>
<form onSubmit="return searchFormSubmit();" style="margin-bottom: 10px;">
<b>Search:</b> <input type="text" id="search" onKeyUp="searchFormSubmit();" size="5"> <input type="submit" value="Search">
</form>
<table id="searchTable" cellspacing="0" cellpadding="3" style="display: none;">
<tr>
	<td class="left head right" colspan="2"><a href="javascript: selectAll('search');">Invert Selection</a> &nbsp; <a href="javascript: add('search');">Add Emails</a></td>
</tr>
</table>
</fieldset>
</td>
<td style="vertical-align: top;">
<fieldset>
<legend>Email</legend>
<table id="emailTable" cellspacing="0" cellpadding="3">
<tr>
	<td class="left head"><a href="javascript: removeAll();">Remove All</a></td>
	<td class="right head">Email</td>
</tr>
<tr>
	<td colspan="2" class="right left bold acenter">No emails</td>
</tr>
</table>
</fieldset>
</td>
</tr>
</table>
<script>
	document.getElementById("search").focus();
</script>
</body>
</html>