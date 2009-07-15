<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Company, accounting.Accounting" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Accounting Company Information</title>
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
</head>
<body>
<font size="+1">Accounting Company Information</font><hr>
<%
String id = request.getParameter("id");
Accounting acc = AccountingUtils.getAccounting(session);
Company c = acc.getCompany(id);
if (c != null) {
%>
<table>
<tr>
	<td class="lbl">ID:</td>
	<td><%= id %></td>
	<td class="lbl">Phone:</td>
	<td><%= FormHelper.stringTable(c.getPhone()) %></td>
</tr>
<tr>
	<td class="lbl">Name:</td>
	<td><%= FormHelper.stringTable(c.getName()) %></td>
	<td class="lbl">Fax:</td>
	<td><%= FormHelper.stringTable(c.getFax()) %></td>
</tr>
<tr>
	<td class="lbl">Address:</td>
	<td rowspan="2"><%= FormHelper.stringTable(c.getAddress()) %><br />
		<%= FormHelper.stringTable(c.getCity()) %>, <%= FormHelper.stringTable(c.getState()) %> 
		<%= FormHelper.stringTable(c.getZip()) %></td>
	<td class="lbl">Email:</td>
	<td><%= FormHelper.stringTable(c.getEmail()) %></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td class="lbl">Website:</td>
	<td><%= FormHelper.stringTable(c.getUrl()) %></td>
</tr>
<tr>
	<td class="lbl">Federal ID:</td>
	<td><%= FormHelper.stringTable(c.getFederalId()) %></td>
	<td colspan="2">&nbsp;</td>
</tr>
<tr>
	<td class="lbl" style="vertical-align: top;">Notes:</td>
<%
String notes = c.getComment();
if (notes != null) notes = notes.replaceAll("\n","<br />");
%>
	<td colspan="3"><%= FormHelper.stringTable(notes) %></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="button" value="Close" onClick="window.close();"></td>
</tr>
</table>
<%
} else {
%>
<div class="bold red">Company not found!</div>
<%
}
%>
</body>
</html>