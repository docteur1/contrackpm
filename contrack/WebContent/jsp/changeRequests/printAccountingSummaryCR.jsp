<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="accounting.CR, accounting.Accounting"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
Logger log = Logger.getLogger(this.getClass());
if (!sec.ok(Security.SUBCONTRACT, Security.READ) && !attr.hasAccounting()) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
ResultSet rs;
String sql;
String title = null;
Database db = new Database();
if (id != null) {
	sql = "select * from change_orders where co_id = " + id;
	rs = db.dbQuery(sql);
	if (rs.next()) title = "CO# " + rs.getString("co_num") + ": " + rs.getString("co_description");
	rs.getStatement().close();
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
</head>
<body>
<div class="title">Accounting Comparison<%= title != null ? " of " + title : "" %></div><hr>
<table>
<thead>
<tr>
	<td class="head">CR #</td>
	<td class="head">Title</td>
	<td class="head">Amount</td>
	<td class="head">Exists</td>
	<td class="head">Acc Title</td>
	<td class="head">Acc Amt</td>
	<td class="head">Match</td>
	<td class="head right">ID</td>
</tr>
</thead>
<tbody>
<%
sql = "select cr.cr_id, num, title, sum(amount + fee + bonds) as amount from change_requests as cr "
	+ "join change_request_detail using(cr_id) where cr.job_id = " + attr.getJobId()
	+ (id != null ? " and co_id = " + id : "") + " group by cr.cr_id order by num desc";
rs = db.dbQuery(sql);
Accounting acc = AccountingUtils.getAccounting(session);
double amount, accCr;
CR cr;
while (rs.next()) {
	amount = rs.getDouble("amount");
%>
<tr>
<td class="aright"><%= rs.getString("num") %></td>
<td><%= rs.getString("title") %></td>
<td><%= FormHelper.cur(amount) %></td>
<%
	cr = acc.getCR(attr.getJobNum(), rs.getString("num"));
	if (cr != null) {
		log.debug("cr returned");
		accCr = acc.getCROwner(cr);
		log.debug("change auth amount: " + accCr);
%>
<td class="acenter"><%= Widgets.checkmark(true, request) %></td>
<td><%= cr.getTitle() %></td>
<td class="aright"><%= FormHelper.cur(accCr) %></td>
<td class="acenter"><%= Widgets.checkmark(accCr == amount, request) %></td>
<%
	} else {
		log.debug("no cr found");
%>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<td>&nbsp;</td>
<%
	}
%>
<td>CR<%= rs.getString("cr_id") %></td>
</tr>
<%
}
acc.close();
rs.getStatement().close();
db.disconnect();
%>
</tbody>
</table>
</body>
</html>