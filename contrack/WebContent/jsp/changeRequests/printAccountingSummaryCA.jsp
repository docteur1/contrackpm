<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="accounting.CRD, accounting.Company, accounting.Accounting"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
Logger log = Logger.getLogger(this.getClass());
if (!sec.ok(Security.SUBCONTRACT, Security.READ) && !attr.hasAccounting()) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String contractId = request.getParameter("id");
ResultSet rs;
String sql;
String companyName = "";
Database db = new Database();
if (contractId != null) {
	sql = "select company_name from contracts join company "
		+ "using(company_id) where contract_id = " + contractId;
	rs = db.dbQuery(sql);
	if (rs.first()) companyName = rs.getString("company_name");
	rs.getStatement().close();
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
<link rel="SHORTCUT ICON" href="../../images/ct64.ico">
<title>Accounting CA Comparison<%= contractId != null ? " - " 
		+ companyName : "" %></title>
</head>
<body>
<div class="title">Accounting CA Comparison<%= contractId != null ? " - " 
		+ companyName : "" %></div><hr>
<table>
<thead>
<tr>
	<td class="head">CA #</td>
	<td class="head">Company</td>
	<td class="head aright">Amount</td>
	<td class="head">Exists</td>
	<td class="head">Account Cmp</td>
	<td class="head aright">Account Amt</td>
	<td class="head">Match</td>
	<td class="head aright">Acc ID</td>
	<td class="head">ID</td>
</tr>
</thead>
<tbody>
<%
sql = "select change_auth_num, crd_id, company_name, crd.amount, num from change_request_detail as crd "
	+ "join contracts using(contract_id) join company using(company_id) left join change_requests as cr "
	+ "using(cr_id) where crd.job_id = " + attr.getJobId() + (contractId != null ? " and contract_id = " 
	+ contractId : "") +" and authorization = 1 order by change_auth_num desc";
rs = db.dbQuery(sql);
Accounting acc = AccountingUtils.getAccounting(session);
double ca, accCa;
CRD crd;
Company company;
while (rs.next()) {
	ca = rs.getDouble("amount");
%>
<tr>
<td class="aright"><%= rs.getString("change_auth_num") %></td>
<td><%= rs.getString("company_name") %></td>
<td class="aright"><%= FormHelper.cur(ca) %></td>
<%
	crd = AccountingUtils.getCRD(rs.getString("crd_id"), acc);
	if (crd != null) {
		crd = acc.getCRD(crd);
		if (crd != null) {
			accCa = crd.getContract();
			if (log.isDebugEnabled()) {
				log.debug("change auth amount: " + accCa);
				log.debug("ca returned");
			}
			if (crd.getSub() != null) company = acc.getCompany(crd.getSub().getAltCompanyId());
			else company = null;
%>
<td class="acenter"><%= Widgets.checkmark(true, request) %></td>
<td><%= company != null ? company.getName() + " (" + company.getAccountId() + ")": "&nbsp;" %></td>
<td class="aright"><%= FormHelper.cur(accCa) %></td>
<td class="acenter"><%= Widgets.checkmark(accCa == ca, request) %></td>
<td class="aright"><%= crd.getCaAltId() %></td>
<%
		} else {
			log.debug("no subcontract found");
%>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<%
		}
	}
%>
<td>CD<%= rs.getString("crd_id") %></td>
</tr>
<%
}
rs.getStatement().close();
db.disconnect();
%>
</tbody>
</table>
</body>
</html>