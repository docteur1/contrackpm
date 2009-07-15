<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.DecimalFormat, com.sinkluge.database.Database" %>

<html>
<head>
	<script src="../utils/table.js"></script>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<%
DecimalFormat df = new DecimalFormat("#,##0.00");
String id = request.getParameter("id");
String query = "select company_name from company where company_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String s = "ERROR";
if (rs.next()) s = rs.getString("company_name");
if (rs != null) rs.getStatement().close();
query = "(select job.job_id, contract_id, job_num, division, cost_code, phase_code, code_description, "
	+ "amount, job_name from contracts join job on contracts.job_id = job.job_id join job_cost_detail as jcd "
	+ "using(cost_code_id) where company_id = " + id + " and jcd.cost_code_id = contracts.cost_code_id) "
	+ "union (select job.job_id, 0 as contract_id, job_num, null as division, null as cost_code, null as phase_code, "
	+ "type as code_description, 0 as amount, job_name from job_contacts join job using(job_id) where "
	+ "company_id = " + id + ") order by costorder(job_num) desc, costorder(division), costorder(cost_code), "
	+ "phase_code";
rs = db.dbQuery(query);
%>
<font size="+1">Contract History for <%= s %></font><hr>
	<a href="reviewCompanies.jsp">Companies</a> &gt;
	<a href="modifyCompany.jsp?id=<%= id %>">Company</a> &gt; Contract History
	&nbsp; <a href="modifyCompanyComments.jsp?id=<%= id %>">Strikes/Comments</a>
	<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="left head">Proj #</td>
	<td class="head">Project</td>
	<td class="head">Phase</td>
	<td class="head">Description</td>
	<td class="head">Contract Amount</td>
	<td class="head"># of CAs</td>
	<td class="head right">CA total</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
double amount = 0, changeOrderTotal = 0;
int contract_id;
int count=0;
String coQuery;
ResultSet coRS;
boolean gray = true;
while (rs.next()){
	amount = rs.getDouble("amount");
	gray = !gray;
	contract_id = rs.getInt("contract_id");
	changeOrderTotal = 0;
	coQuery = "select amount from change_request_detail where contract_id = " + contract_id;
	coRS = db.dbQuery(coQuery);
	count=0;
	while (coRS.next()){
		count++;
		changeOrderTotal += coRS.getDouble("amount");
	}
	if (coRS != null) coRS.getStatement().close();
	coRS = null;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (gray) out.print("class=\"gray\""); %>>
	<td class="left"><div class="link" onclick="parent.setProjectId(<%= rs.getString("job_id") 
		%>, 'contracts/reviewContracts.jsp');"><%= rs.getString("job_num") %></div></td>
	<td class="it"><%= rs.getString("job_name") %></td>
<%
if (contract_id != 0) {
%>
	<td class="it"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
	<td class="it"><%= rs.getString("code_description") %></td>
	<td class="it aright"><%=df.format(amount) %></td>
	<td class="it aright"><%=count %></td>
	<td class="right aright"><%= df.format(changeOrderTotal) %></td>
<%
} else {
%>
    <td class="it">&nbsp;</td>
    <td class="it"><%= rs.getString("code_description") %></td>
    <td class="it aright">0.00</td>
    <td class="it aright">0</td>
    <td class="right aright">0.00</td>
    
<%
}
%>
	</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</body>
</html>
