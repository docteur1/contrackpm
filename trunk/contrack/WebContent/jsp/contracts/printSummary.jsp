<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
<title>Contract Summary</title>
</head>
<body>
<div class="title">Current Summary</div><hr>
<table cellspacing="0">
<thead>
<tr>
	<td class="head">Code</td>
	<td class="head">Company</td>
	<td class="head">Amount</td>
	<td class="head"># CAs</td>
	<td class="head">CAs</td>
	<td class="head">Revised</td>
	<td class="head">ID</td>
</tr>
</thead>
<tbody>
<%
String sql = "select cost_code, phase_code, division, company_name, name, "
	+ "cp.company_id, cn.contract_id, cn.amount from contracts as cn join company as cp "
	+ "on cn.company_id = cp.company_id left join "
	+ "contacts as ct on cn.contact_id = ct.contact_id join job_cost_detail as jcd on "
	+ "jcd.cost_code_id = cn.cost_code_id where cn.job_id = " + attr.getJobId()
	+ " order by costorder(division), costorder(cost_code), "
	+ "costorder(phase_code)";
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
ResultSet rs2;
while (rs.next()) {
	sql = "select count(*) as count, sum(amount) as sum from change_request_detail "
		+ "where authorization = 1 and contract_id = " + rs.getString("contract_id");
	rs2 = db.dbQuery(sql);
%>
<tr>
<td><%= rs.getString("division") + " " 
	+ rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
<td><%= rs.getString("company_name") + (rs.getString("name") != null ?
		" - " + FormHelper.stringTable(rs.getString("name")) : "") %></td>
<td class="aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<%
	if (rs2.first()) {
%>
<td class="aright"><%= rs2.getString("count") %></td>
<td class="aright"><%= FormHelper.cur(rs2.getDouble("sum")) %></td>
<td class="aright"><%= FormHelper.cur(rs.getDouble("amount") +
	rs2.getDouble("sum")) %></td>
<td>SA<%= rs.getString("contract_id") %></td>
<%
	} else {
%>
<td class="aright"><%= 0 %></td>
<td class="aright"><%= FormHelper.cur(0) %></td>
<td class="aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<td>SA<%= rs.getString("contract_id") %></td>
<%
	}
%>
</tr>
<%
	rs2.getStatement().close();
}
rs.getStatement().close();
db.disconnect();
%>
</tbody>
</table>
</body>
</html>