<%@page session="true" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/styleDetail.css" media="all">
</head>
<body>
<table cellspacing="0" cellpadding="0">
<%
String cost_code_id = request.getParameter("id");
String query = "select division, cost_code, phase_code from job_cost_detail where cost_code_id = " + cost_code_id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String cost_code = "";
String phase_code = "";
String division = "";
if (rs.next()) {
	division = rs.getString("division");
	cost_code = rs.getString("cost_code");
	phase_code = rs.getString("phase_code");
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
<tr>
	<td class="p12"><b><%= division + " " + cost_code + " - " + phase_code%></b></td>
	<td colspan="9" style="text-align: right;">
<%
if (sec.ok(Security.ACCOUNT, Security.WRITE)){
%>
<button accesskey="r" onClick="parent.document.location='reconcile.jsp?id=<%= cost_code_id %>&r=v';"><u>R</u>econcile</button> &nbsp;
<%
}
if (sec.ok(Security.COST_DATA, Security.PRINT)){
%>
<button accesskey="p" onClick="parent.document.location='printVouchers.jsp?id=<%= cost_code_id %>';"><u>P</u>rint</button> &nbsp;
<%
}
%>
<button accesskey="e" onClick="parent.document.location='phaseDetail.jsp?id=<%= cost_code_id %>';"><u>J</u>ob Cost Detail</button>
</tr>
<tr class="yellow">
	<td class="w130"><b>Name</b></td>
	<td class="g w80"><b>Invoice</b></td>
	<td class="r w50"><b>PO</b></td>
	<td class="g w72"><b>Date</b></td>
	<td class="r w50"><b>Amount</b></td>
	<td class="r g w50"><b>Paid</b></td>
	<td class="r w50"><b>Ret</b></td>
	<td class="r g w50"><b>Disc</b></td>
 	<td class="w150"><b>Description</b></td>
 	<td class="g w10"><b>Img</b></td>
</tr>
</table>
</body>
</html>
