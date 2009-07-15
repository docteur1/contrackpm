<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="accounting.Subcontract, accounting.Accounting, accounting.Company"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
	Logger log = Logger.getLogger(this.getClass());
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
<title>Accounting Subcontract Comparison</title>
<link rel="SHORTCUT ICON" href="../../images/ct64.ico">
</head>
<body>
<div class="title">Accounting Subcontract Comparison</div><hr>
<table>
<thead>
<tr>
	<td class="head">Code</td>
	<td class="head">Company</td>
	<td class="head">Current</td>
	<td class="head">Account Cmp</td>
	<td class="head">Exists</td>
	<td class="head">Account Amt</td>
	<td class="head">Match</td>
	<td class="head">Acc ID</td>
	<td class="head">ID</td>
</tr>
</thead>
<tbody>
<%
	String sql = "select cost_code, altContractId, phase_code, division, company_name, name, account_id, "
	+ "cp.company_id, cn.contract_id, cn.amount, cn.contract_id from contracts as cn "
	+ "join company as cp on cn.company_id = cp.company_id left join "
	+ "contacts as ct on cn.contact_id = ct.contact_id left join job_cost_detail as jcd on "
	+ "jcd.cost_code_id = cn.cost_code_id left join company_account_ids as cai "
	+ "on (cn.company_id = cai.company_id and cai.site_id = " + attr.getSiteId() 
	+ ") where cn.job_id = " + attr.getJobId() + " order by costorder(division), "
	+ "costorder(cost_code), costorder(phase_code)";
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
ResultSet rs2;
boolean color = true;
Subcontract sub;
Accounting acc = AccountingUtils.getAccounting(session);
double accChangeAuths;
String altContractId;
Company c;
while (rs.next()) {
	sql = "select sum(amount) as sum from change_request_detail "
		+ "where authorization = 1 and contract_id = " + rs.getString("contract_id");
	rs2 = db.dbQuery(sql);
	color = !color;
%>
<tr>
<td class="aright"><%= rs.getString("division") + " " 
	+ rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
<td><%= rs.getString("company_name") + (rs.getString("name") != null ?
		" - " + FormHelper.stringTable(rs.getString("name")) : "") %></td>
<%
	if (rs2.first()) {
%>
<td class="aright"><%= FormHelper.cur(rs.getDouble("amount") 
	+ rs2.getDouble("sum")) %></td>
<%
	} else {
%>
<td class="aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<%
	}
	c = acc.getCompany(rs.getString("account_id"));
%>
<td class="it"><%= c != null ? c.getName() + " (" + c.getAccountId() + ")" : "&nbsp;" %></td>
<%
	altContractId = rs.getString("altContractId");
	if (altContractId != null) {
		log.debug("Looking for contract by altId: " + altContractId);
		sub = acc.getSubcontract(altContractId, rs.getString("phase_code"));
	} else {
		sub = AccountingUtils.getSubcontract(rs.getInt("contract_id"));
		log.debug("Looking for contract by data");
		if (sub != null) sub = acc.getSubcontract(sub);
	}
	if (sub != null) {
		accChangeAuths = acc.getCATotal(sub.getAltContractId());
		if (sub.getAltContractId() != null && !sub.getAltContractId().equals(altContractId))
		{
			db.dbInsert("update contracts set altContractId = '" + sub.getAltContractId()
				+ "' where contract_id = " + rs.getString("contract_id"));
		}
%>
<td class="acenter"><%= Widgets.checkmark(true, request) %></td>
<td class="aright"><%= FormHelper.cur(sub.getAmount() + accChangeAuths) %></td>
<td class="acenter"><%= Widgets.checkmark(sub.getAmount() + accChangeAuths
		== rs.getDouble("amount") + rs2.getDouble("sum"), request) %></td>
<td class="aright"><%= sub.getAltContractId() %></td>

<%
	} else {
		log.debug("no subcontract found");
%>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<%
	}
	rs2.getStatement().close();
%>
<td class="aright">SA<%= rs.getString("contract_id") %></td>
</tr>
<%
}
rs.getStatement().close();
acc.close();
db.disconnect();
%>
</tbody>
</table>
</body>
</html>