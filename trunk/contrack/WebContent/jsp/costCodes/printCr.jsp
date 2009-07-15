<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.CO, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Changes</title>
<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
</head>
<body>
<%
String code = "00 00000-? Description";
String id = request.getParameter("id");
String sql = "select division, cost_code, phase_code, code_description from "
	+ "job_cost_detail where cost_code_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
if (rs.first()) code = rs.getString("division") + " " + rs.getString("cost_code") + "-"
	+ rs.getString("phase_code") + ": " + rs.getString("code_description"); 
if (rs != null) rs.getStatement().close();
sql = "select cr.cr_id, crd_id, num, change_auth_num, status, company_name, crd.amount, "
	+ "fee, bonds, authorization, work_description, title from change_request_detail "
	+ "as crd left join change_requests as cr using(cr_id) left join contracts "
	+ "using(contract_id) left join company using(company_id) where crd.cost_code_id = "
	+ id + " order by num, change_auth_num";
rs = db.dbQuery(sql);
%>
<div class="title">Changes - <%= code %></div><hr>
<table>
<thead>
<tr>
	<td class="head">CR #</td>
	<td class="head">CA #</td>
	<td class="head">Company</td>
	<td class="head">Description</td>
	<td class="head">Status</td>
	<td class="head">Amount</td>
	<td class="head">Fee</td>
	<td class="head">Bonds</td>
	<td class="head">ID</td>
</tr>
</thead>
<tbody>
<%
boolean caOnly = false;
double amount = 0, fee = 0, bonds = 0;
while (rs.next()) {
	caOnly = rs.getString("cr_id") == null;
	if (!caOnly && "Approved".equals(rs.getString("status"))) {
		amount += rs.getDouble("amount");
		fee += rs.getDouble("fee");
		bonds += rs.getDouble("bonds");
	}
%>
<tr>
	<td><%= !caOnly ? rs.getString("num") : "&nbsp;" %></td>
	<td><%= rs.getBoolean("authorization") ? rs.getString("change_auth_num")
			: "&nbsp;" %></td>
	<td><%= FormHelper.stringTable(rs.getString("company_name")) %></td>
	<td><%= rs.getString("title") != null ? rs.getString("title") 
			: FormHelper.left(rs.getString("work_description"), 50) %></td>
	<td><%= caOnly ? "&nbsp;" : rs.getString("status") %></td>
	<td class="aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
	<td class="aright"><%= caOnly ? "&nbsp;" : FormHelper.cur(rs.getDouble("fee")) %></td>
	<td class="aright"><%= caOnly ? "&nbsp;" : FormHelper.cur(rs.getDouble("bonds")) %></td>
	<td>CD<%= rs.getString("crd_id") %></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
<tr>
	<td class="bold aright" colspan="5">Total (Approved)</td>
	<td class="aright bold"><%= FormHelper.cur(amount) %></td>
	<td class="aright bold"><%= FormHelper.cur(fee) %></td>
	<td class="aright bold"><%= FormHelper.cur(bonds) %></td>
	<td>&nbsp;</td>
</tr>
</tbody>
</table>
</body>
</html>