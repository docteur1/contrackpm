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
String id = request.getParameter("id");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Changes</title>
<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/table.js"></script>
<script>
	function openWin(loc, x, y) {
		var msgWindow = open(loc, "crCostEdit", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function printCr() {
		var msgWindow = open("printCr.jsp?id=<%= id %>", "print");
		msgWindow.focus();
	}
	function cr(id) {
		openWin("../changeRequests/crFrameset.jsp?id=" + id, 700, 600);
	}
	function ca(id) {
		openWin("../changeRequests/crdFrameset.jsp?id=" + id, 700, 600);
	}
</script>
</head>
<body>
<%
String code = "00 00000-? Description";
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
<div class="title">Changes</div><hr>
 <%= code %> &nbsp;
<div class="link" onclick="window.close();">Close</div> &nbsp;
<div class="link" onclick="printCr();">Print</div>
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">CR #</td>
	<td class="head nosort">CA #</td>
	<td class="head">Company</td>
	<td class="head">Description</td>
	<td class="head">Status</td>
	<td class="head">Amount</td>
	<td class="head">Fee</td>
	<td class="head">Bonds</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean color = true;
boolean caOnly = false;
double amount = 0, fee = 0, bonds = 0;
while (rs.next()) {
	color = !color;
	caOnly = rs.getString("cr_id") == null;
	if (!caOnly && "Approved".equals(rs.getString("status"))) {
		amount += rs.getDouble("amount");
		fee += rs.getDouble("fee");
		bonds += rs.getDouble("bonds");
	}
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left"><%= !caOnly ? "<div class=\"link\""
		+ "onclick=\"cr(" + rs.getString("cr_id") + ");\">" + rs.getString("num")
		+ "</div>" : "&nbsp;" %></td>
	<td class="right"><%= rs.getBoolean("authorization") ? "<div class=\"link\""
		+ "onclick=\"ca(" + rs.getString("crd_id") + ");\">" 
		+ rs.getString("change_auth_num") + "</div>" : "&nbsp;" %></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("company_name")) %></td>
	<td class="it"><%= rs.getString("title") != null ? rs.getString("title") 
			: FormHelper.left(rs.getString("work_description"), 50) %></td>
	<td class="it"><%= caOnly ? "&nbsp;" : rs.getString("status") %></td>
	<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
	<td class="it aright"><%= caOnly ? "&nbsp;" : FormHelper.cur(rs.getDouble("fee")) %></td>
	<td class="it aright"><%= caOnly ? "&nbsp;" : FormHelper.cur(rs.getDouble("bonds")) %></td>
	<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(rs.getString("crd_id"), com.sinkluge.Type.CRD, "window", request) %></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
color = !color;
%>
<tr class="sortbottom" onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left aright bold" colspan="5">Total (Approved)</td>
	<td class="it aright bold"><%= FormHelper.cur(amount) %></td>
	<td class="it aright bold"><%= FormHelper.cur(fee) %></td>
	<td class="it aright bold"><%= FormHelper.cur(bonds) %></td>
	<td class="right">&nbsp;</td>
</tr>
</table>
</div>
</body>
</html>