<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(com.sinkluge.security.Name.SUBCONTRACTS, com.sinkluge.security.Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Subcontracts</title>
<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/table.js"></script>
<script>
	function openWin(loc, x, y) {
		var msgWindow = open(loc, "crCostEdit", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
		window.close();
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
sql = "select contract_id, company_name, amount from contracts join company using (company_id) " +
	"where cost_code_id = " + id + " order by company_name";
rs = db.dbQuery(sql);
%>
<div class="title">Subcontracts</div><hr>
 <%= code %> &nbsp;
<div class="link" onclick="window.close();">Close</div> &nbsp;
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<td class="head">Company</td>
	<td class="head">Amount</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean color = true;
double amount = 0;
while (rs.next()) {
	color = !color;
	amount += rs.getDouble("amount");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left"><div class="link" 
		onclick="openWin('../contracts/modifyContractFrameset.jsp?id=<%= rs.getString("contract_id") %>', 700, 600);">Edit</div></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("company_name")) %></td>
	<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
	<td class="right">SA<%= rs.getString("contract_id") %></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
color = !color;
%>
<tr class="sortbottom" onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left aright bold" colspan="2">Total (Approved)</td>
	<td class="it aright bold"><%= FormHelper.cur(amount) %></td>
	<td class="right">&nbsp;</td>
</tr>
</table>
</div>
</body>
</html>