<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper"%>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission,
	com.sinkluge.database.Database"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="utils/table.js"></script>
<script>
	function openVoucher(sc_id, voucherNum) {
		var w = window.open("utils/print.jsp?doc=imageAcc.pdf?id=" + voucherNum 
			+ "&sc_id=" + sc_id, "print");
		w.focus();
	}
</script>
</head>
<body>
<div class="title">Main</div><hr>
<%
ResultSet rs = null;
String sql;
Database db = new Database();
boolean admin = sec.ok(Name.ADMIN, Permission.READ);
if (!admin) sql = "select count(*) from pay_requests as pr join owner_pay_requests as opr using(opr_id) join "
	+ "user_jobs as uj on opr.job_id = uj.job_id join job_permissions as jp on uj.job_id = jp.job_id and "
	+ "uj.user_id = jp.user_id where uj.user_id = " + attr.getUserId() + " and e_update = 1 "
	+ "and jp.name = '" + Name.SUBCONTRACTS + "' and jp.val like '%" + Permission.READ + "%'";
else sql = "select count(*) from pay_requests as pr join owner_pay_requests as opr using(opr_id) join "
	+ "user_jobs as uj on opr.job_id = uj.job_id where uj.user_id = " + attr.getUserId() + " and e_update = 1";
rs = db.dbQuery(sql);
if (rs.first() && rs.getInt(1) != 0) {
%>
<div><%= rs.getInt(1) %> updated <div class="link" 
	onclick="window.location='contracts/payRequests/eUpdatePRs.jsp'">pay request(s)</div>.</div>
<%
}
rs.getStatement().close();
rs = null;
if (!admin) sql = "select count(*) from rfi join "
	+ "user_jobs as uj on rfi.job_id = uj.job_id join job_permissions as jp on uj.job_id = jp.job_id and "
	+ "uj.user_id = jp.user_id where uj.user_id = " + attr.getUserId() + " and e_update = 1 "
	+ "and jp.name = '" + Name.RFIS + "' and jp.val like '%" + Permission.READ + "%'";
else sql = "select count(*) from rfi join "
	+ "user_jobs as uj on rfi.job_id = uj.job_id where uj.user_id = " + attr.getUserId() + " and e_update = 1";
rs = db.dbQuery(sql);
if (rs.first() && rs.getInt(1) != 0) {
%>
<div><%= rs.getInt(1) %> updated <div class="link" 
	onclick="window.location='rfis/eUpdateRFIs.jsp'">RFI(s)</div>.</div>
<%
}
rs.getStatement().close();
rs = null;
if (!admin) sql = "select count(*) from submittals as sm join "
	+ "user_jobs as uj on sm.job_id = uj.job_id join job_permissions as jp on uj.job_id = jp.job_id and "
	+ "uj.user_id = jp.user_id where uj.user_id = " + attr.getUserId() + " and e_update = 1 "
	+ "and jp.name = '" + Name.SUBMITTALS + "' and jp.val like '%" + Permission.READ + "%'";
else sql = "select count(*) from submittals join "
	+ "user_jobs as uj on submittals.job_id = uj.job_id where uj.user_id = " + attr.getUserId() 
	+ " and e_update = 1";
rs = db.dbQuery(sql);
if (rs.first() && rs.getInt(1) != 0) {
%>
<div><%= rs.getInt(1) %> updated <div class="link" 
	onclick="window.location='submittals/eUpdateSubmittals.jsp'">submittal(s)</div>.</div>
<%
}
rs.getStatement().close();
rs = null;
if (sec.ok(Name.APPROVE_PAYMENT, Permission.READ) && in.hasKF) {
	if (!admin && !sec.ok(Name.ACCOUNTING, Permission.READ))
		sql = "select sc.*, job.job_num from suspense_cache as sc join "
			+ "job on sc.job_id = job.job_id join job_permissions as jp on job.job_id = jp.job_id "
			+ "where jp.user_id = " + attr.getUserId() + " and jp.name = '"
			+ Name.APPROVE_PAYMENT + "' and jp.val like '%" + Permission.READ 
			+ "%' order by costorder(job_num) desc, sc_id";
	else 
		sql = "select sc.*, job.job_num from suspense_cache as sc join "
			+ "job on sc.job_id = job.job_id "
			+ "where job.active = 'y' order by costorder(job_num) desc, sc_id";
	rs = db.dbQuery(sql);
	if (rs.isBeforeFirst()) {
%>
<div class="bold" style="margin-top: 8px; margin-bottom: 8px;">Invoices needing your attention:</div>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">View</td>
	<td class="head">Proj #</td>
	<td class="head">Voucher #</td>
	<td class="head">Company</td>
	<td class="head">PO</td>
	<td class="head">Invoice</td>
	<td class="head">Date</td>
	<td class="head">Action</td>
	<td class="head right">Description</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
		boolean color = true;
		while (rs.next()) {
			color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<td class="left right"><div class="link" onclick="openVoucher(<%= rs.getString("sc_id") %>, 
	<%= rs.getString("voucher_id") %>);">View</div></td>
<td class="it aright"><%= rs.getString("job_num") %></td>
<td class="it aright"><%= rs.getString("voucher_id") %></td>
<td class="it"><%= rs.getString("company") %></td>
<td class="it aright"><%= FormHelper.stringTable(rs.getString("po_num")) %></td>
<td class="it aright"><%= rs.getString("invoice_num") %></td>
<td class="it aright"><%= FormHelper.medDate(rs.getDate("voucher_date")) %></td>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<td class="right"><%= FormHelper.stringTable(rs.getString("description")) %></td>
</tr>
<%
		}
	}
	rs.getStatement().close();
}
db.disconnect();
%>
</table>
</div>
</body>
</html>