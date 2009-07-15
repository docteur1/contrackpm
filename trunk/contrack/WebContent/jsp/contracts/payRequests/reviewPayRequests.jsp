<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.security.Security, java.util.Date" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sw = sec.ok(Security.SUBCONTRACT, Security.WRITE);
boolean sp = sec.ok(Security.SUBCONTRACT, Security.PRINT);
String oprId = request.getParameter("id");
// Are we still in the same job?
String query = "select period from owner_pay_requests where "
	+ "opr_id = " + oprId + " and job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (!rs.next()) {
	if (rs != null) rs.close();
	rs = null;
	response.sendRedirect("reviewOwnerPayRequests.jsp");
	return;
}
if (rs != null) rs.close();
rs = null;
query = "select period, locked from owner_pay_requests where opr_id = " + oprId;
rs = db.dbQuery(query);
Date d;
String period = "ERROR";
boolean locked = false;
if (rs.next()) {
	period = rs.getString(1);
	locked = rs.getBoolean(2);
}
if (rs != null) rs.close();
rs = null;
boolean ret = period.equals("Retention");
sw = sw && !ret;
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../../utils/table.js"></script>
	<script>
		function openWin(loc, x, y) {
			var msgWindow = open(loc, "cr", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
				+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function edit(id) {
			openWin("modifyPRFrameset.jsp?id=" + id, 700, 600);
		}
		function del(id) {
			if (window.confirm("Delete this pay request?"))
				window.location = "deletePR.jsp?id=" + id;
		}
		function p(id, fp) {
			var msgWindow = open("../../utils/print.jsp?doc=pr" + 
				(fp ? "Final" : "Month") + ".pdf?id=" + id, "print");
			msgWindow.focus();
		}
		function info(id) {
			openWin("showPRInfo.jsp?id=" + id, 400, 250);
		}
	</script>
</head>
<body>
<div class="title">Pay Requests: <%= period %><%= (locked?" - CLOSED" : "") %></div><hr>
<div class="link" onclick="window.location='reviewOwnerPayRequests.jsp';">Pay Periods</div> &gt;
Pay Requests: <%= period %><%= (locked?" - CLOSED" : "") %> &nbsp;
<%= !ret ? "<div class=\"link\" onclick=\"openWin('newPRFrameset.jsp?opr_id="
		+ oprId + "', 700, 600);\">New</div> &nbsp; " : "" %>
<a href="../../utils/print.jsp?doc=pr<%= (!ret?"":"Retention") %>Report.pdf?id=<%= 
	oprId %>" target="print">Print</a>
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<%= sw ? "<td class=\"head left nosort\">Delete</td>" : "" %>
	<td class="head<%= !sw ? " left " : " " %>nosort">Edit</td>
	<%= sp && !ret ? "<td class=\"head nosort\">Print</td>" : "" %>
	<td class="head">Code</td>
	<td class="head">Request</td>
	<%= ret ? "" : "<td class=\"head\">Final</td>" %>
	<td class="head">Company</td>
	<td class="head">Ext Created</td>
	<td class="head">eUpdate</td>
	<td class="head">Accepted</td>
	<td class="head">Paid</td>
	<td class="head">Rec Accnt</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
String id;
query = "select pr.*, company_name, cost_code, phase_code, division from pay_requests "
	+ "as pr join contracts as n using(contract_id) join company using(company_id) "
	+ "join job_cost_detail using(cost_code_id) where pr.opr_id = " + oprId 
	+ " order by costorder(division), costorder(cost_code)"
	+ ", costorder(phase_code)";
rs = db.dbQuery(query);
boolean color = true;
boolean fin;
String accountId;
while (rs.next()) {
	id 	= rs.getString("pr_id");
	fin = rs.getBoolean("final");
	color = !color;
	accountId = rs.getString("account_id");
	if (accountId == null || "0".equals(accountId)) accountId = "";
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
	if (sw) {
%>
	<td class="left"><div class="link" onclick="del(<%=	id %>)">Delete</div></td>
<%
	}
%>
	<td class="<%= !sw ? "left" : "it" %>">
		<div class="link" onclick="edit(<%= id %>);">Edit</div></td>
<%
	if (sp && !ret) {
%>
	<td class="it"><div class="link" onclick="p(<%= id %>, <%= fin %>);">Print</div>
		</td>
<%
	}
%>
	<td class="left aright"><%= rs.getString("division") + " " + rs.getString("cost_code") 
		+ "-" + rs.getString("phase_code") %></td>
	<td class="it aright"><%= rs.getString("request_num") %></td>
	<%= ret ? "" : "<td class=\"input acenter\">" +
			Widgets.checkmark(fin, request) + "</td>" %>
	<td class="it"><%= rs.getString("company_name") %></td>
	<td class="input acenter"><%= Widgets.checkmark(rs.getBoolean("ext_created"), 
		request) %></td>
	<td class="input acenter"><%= Widgets.checkmark(rs.getBoolean("e_update"), request) %></td>
	<td class="it aright"><%= FormHelper.medDate(rs.getDate("date_approved")) %></td>
	<td class="it aright"><%= FormHelper.medDate(rs.getDate("date_paid")) %></td>
	<td class="input acenter"><%= Widgets.checkmark(!"".equals(accountId), 
		request) %></td>
	<td class="right"><%= Widgets.logLinkWithId(rs.getString("pr_id"), com.sinkluge.Type.PR, 
		"window", request) %></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>