<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, accounting.Accounting" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Code, com.sinkluge.utilities.Widgets" %>
<%@page import="java.util.Hashtable, java.util.List, java.util.Iterator" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />

<%
if (!sec.ok(Security.ACCOUNT, Security.PRINT)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
<title>Budget Comparison Report</title>
</head>
<body>
<div class="title"><%= attr.getJobNum() + ": " + attr.getJobName() %></div>
<hr>
<%
Accounting acc = AccountingUtils.getAccounting(session);
List<Code> codes = acc.getCodes(attr.getJobNum());
Hashtable<String, Code> ht = codes != null ? new Hashtable<String, Code>(codes.size())
		: new Hashtable<String, Code>(0);
Code budget;
for (Iterator<Code> i = codes.iterator(); i.hasNext();) {
	budget = i.next();
	ht.put(budget.getDivision() + "\t" + budget.getCostCode() + "\t" + budget.getPhaseCode(), budget);
}
if (codes != null) codes.clear();
String query = "select division, cost_code, phase_code, code_description, amount, budget from "
	+ "job_cost_detail as jcd left join changes using(cost_code_id) where jcd.job_id = "
	+ attr.getJobId() + " order by costorder(division), costorder(cost_code), "
	+ "costorder(phase_code)";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
%>
<table cellspacing="0">
	<thead>
		<tr>
			<td class="head">Code</td>
			<td class="head">Description</td>
			<td class="aright head">Budget</td>
			<td class="aright head">Acc Bdgt</td>
			<td class="head">Acc Description</td>
			<td class="head">Exists</td>
			<td class="head">Changes</td>
			<td class="head">Acc Chngs</td>
			<td class="head">Match</td>
		</tr>
	</thead>
	<tbody>
<%
String division, costCode, phaseCode;
double bCon, bAcc, cCon, cAcc;
boolean exists;
while (rs.next()) {
	division = rs.getString("division");
	costCode = rs.getString("cost_code");
	phaseCode = rs.getString("phase_code");
	budget = ht.get(division + "\t" + costCode + "\t" + phaseCode);
	bCon = rs.getDouble("budget");
	cCon = rs.getDouble("amount");
	bAcc = 0;
	cAcc = 0;
%>
	<tr>
		<td align="right"><%= division + " " + costCode + "-" + phaseCode %></td>
		<td><%= rs.getString("code_description") %></td>
		<td align="right"><%= FormHelper.cur(bCon) %></td>
<%
	if (budget != null) {
		exists = true;
		bAcc = budget.getAmount();
		cAcc = acc.getBudgetChangeTotal(budget);
%>
		<td align="right"><%= FormHelper.cur(bAcc) %></td>
		<td><%= budget.getName() %></td>
		<td class="acenter"><%= Widgets.checkmark(true, request) %></td>
<%
	} else {
		out.print("<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>");
		exists = false;
	}
%>
		<td><%= FormHelper.cur(cCon) %></td>
		<td><%= FormHelper.cur(cAcc) %></td>
		<td class="acenter"><%= Widgets.checkmark((bCon + cCon == bAcc + cAcc) && exists, 
				request) %></td>
	</tr>
<%
}
acc = null;
ht.clear();
ht = null;
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
	</tbody>
</table>
</body>
</html>
