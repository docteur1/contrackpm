<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
String id = request.getParameter("contract_id");
if (!sec.ok(Security.SUBCONTRACT,4)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sw = sec.ok(Security.SUBCONTRACT, Security.WRITE);
boolean sp = sec.ok(Security.SUBCONTRACT, Security.PRINT);
Database db = new Database();
ResultSet rs = db.dbQuery("select company_name from contracts join company using(company_id) where " 
		+ "contract_id = " + id + " and job_id = " + attr.getJobId());
String name = "ERROR";
if (rs.next()) name = rs.getString(1);
else {
	if (rs != null) rs.getStatement().close();
	db.disconnect();
	response.sendRedirect("../reviewContracts.jsp");
	return;
}
if (rs != null) rs.getStatement().close();
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel=stylesheet href="../../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script>
	function del(id) {
		if(confirm("Delete this pay request?")) location = "deletePR.jsp?sub=t&id=" + id;
	}
	function openWin(loc, h, w) {
		msgWindow = open('','pr','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=' + w + ',height=' + h + ',left=25,top=25');
		msgWindow.location.href = loc;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();		
	}
	function print(loc) {
		msgWindow = open("", "pr");
		msgWindow.location.href = loc;
		msgWindow.focus();	
	}
	var cls;
	function n(id) {
		id.className = cls;
	}
	function b(id) {
		cls = id.className;
		id.className = "yellow";
		if (cls.indexOf("bold") != -1) id.className += " bold";
	}
</script>
</head>
<body>
<font size="+1"><%= name %> - Pay Requests</font><hr>
<a href="../reviewContracts.jsp">Subcontracts</a> &gt; Pay Requests<hr>
<table cellspacing="0" cellpadding="3">
	<tr>
		<%= sw ? "<td class=\"left head nosort\">Delete</td><td class=\"head nosort\">Edit</td>" : "" %>
		<%= sp ? "<td class=\"" + (sw ? "" : "left") + "head nosort\">Print</td>" : "" %>
		<td class="head <%= !sp && !sw ? "left" : "" %> nosort">Info</td>
		<td class="head">Period</td>
		<td class="head aright">Request</td>
		<td class="head">Final</td>
		<td class="head">Ext Created</td>
		<td class="head">Accepted</td>
		<td class="head">Paid</td>
		<td class="head">Rec Account</td>
		<td class="head">Lien Waiver</td>
		<td class="head right">ID</td>
	</tr>
<%
String query = "select pr_id, pr.opr_id, company_name, request_num, ext_created, final, "
	+ "date_approved, pr.account_id, pr.lien_waiver, date_paid, period from pay_requests as pr "
	+ "join owner_pay_requests as opr using(opr_id) join contracts as c using(contract_id) "
	+ "join company as com using(company_id) where pr.contract_id = " + id + " order by request_num desc";
rs = db.dbQuery(query);
boolean color = true, fin, ret;
String period;
while (rs.next()) {
	color = !color;
	period = rs.getString("period");
	fin = "Final".equals(period);
	ret = "Retention".equals(period);
	id = rs.getString("pr_id");
%>
	<tr <%= FormHelper.color(color) %> onMouseOver="b(this);" onMouseOut="n(this);">
		<%= sw && !ret ? "<td class=\"left\"><div class=\"link\" onclick=\"del(" + id 
				+ ");\">Delete</div></td>" : sw ? "<td class=\"left\">&nbsp;</td>" : "" %>
		<%= sw ? "<td class=\"it\"><div class=\"link\" onclick=\"openWin('modifyPRFrameset.jsp?id=" 
				+ id + "',500,600);\">Edit</div></td>" : "" %>
		<%= sp && !ret ? "<td class=\"" + (sw ? "it" : "left") + "\"><div class=\"link\" onclick=\"print(" 
				+ "'../../utils/print.jsp?doc=prMonth.pdf?id=" + id 
				+ "');\">Print</div></td>" : sp && ret ? "<td class=\"it\">&nbsp;</td>" : "" %>
		<td class="<%= !sp && !sw ? "left" : "it" %>">
			<div class="link" onclick="openWin('showPRInfo.jsp?id=<%= id %>', 300, 300);">Info</div></td>
		<td class="right"><div class="link" onclick="window.location='reviewPayRequests.jsp?id=<%= rs.getString("opr_id") %>';"><%= period %></div></td>
		<td class="it aright"><%= rs.getString("request_num") %></td>
		<td class="input acenter"><%= Widgets.checkmark(rs.getBoolean("final"), 
			request) %></td>
		<td class="input acenter"><%= Widgets.checkmark(rs.getBoolean("ext_created"), request) %></td>
		<td class="it"><%= FormHelper.medDate(rs.getDate("date_approved")) %></td>
		<td class="it"><%= FormHelper.medDate(rs.getDate("date_paid")) %></td>
		<td class="input acenter"><%= Widgets.checkmark(rs.getLong("account_id") != 0, request) %></td>
		<td class="it"><%= FormHelper.stringTable(rs.getString("lien_waiver")) %></td>
		<td class="right">PR<%= id %></td>
	</tr>
<%
}
rs.getStatement().close();
%>
</table>
</body>
</html>
<%
db.disconnect();
%>