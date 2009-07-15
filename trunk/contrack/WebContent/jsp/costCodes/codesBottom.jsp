<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Name.COSTS, Permission.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
int job_id = attr.getJobId();
String query = "select sum(estimate) as est, sum(budget) as budg, sum(pm_cost_to_date) as ctd, sum(cost_to_complete) as ctcomp "
	+ "from job_cost_detail where job_id= " + job_id + " group by job_id";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
query = "select sum(amount) as contract from contracts where job_id = " + job_id;
ResultSet contracts = db.dbQuery(query);
query = "select sum(amount) as amount from changes where job_id = " + job_id;
ResultSet co_sum = db.dbQuery(query);
DecimalFormat df = new DecimalFormat("#,###");
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/style.css">
</head>
<body>
<table cellspacing="0" cellpadding="0">
<%
float budget = 0, ctd = 0, co = 0, ctc = 0, est = 0, con = 0;

if (co_sum.next()) co = co_sum.getFloat("amount");
if (rs.next()) {
	budget = rs.getFloat("budg");
	ctd = rs.getFloat("ctd");
	ctc = rs.getFloat("ctcomp");
	est = rs.getFloat("est");
}
if (contracts.next()) con = contracts.getFloat("contract");
%>
	<tr class="yellow">
		<td align="right" style="width: 183px;"><b>Totals:</b></td>
		<td class="rg60"><b><%= df.format(est) %></b></td>
		<td class="r60"><b><%= df.format(con) %></b></td>
		<td class="rg60"><b><%= df.format(budget) %></b></td>
		<td class="r60"><b><%= df.format(co) %></b></td>
		<td class="rg60"><b><a href="../servlets/CSV/costDetails.csv"><%= df.format(ctd) %></a></b></td>
		<td class="r60">&nbsp;</td>
		<td class="rg60"><b><%= df.format(ctc) %></b></td>
		<td class="r60"><b><%= df.format(budget + co - ctd - ctc) %></b></td>
	</tr>
</table>
<%
if (rs != null) rs.close();
rs = null;
if (contracts != null) contracts.close();
contracts = null;
if (co_sum != null) co_sum.close();
co_sum = null;
db.disconnect();
%>
</body>
</html>