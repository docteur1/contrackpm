<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Name.SUBCONTRACTS, Permission.WRITE)) response.sendRedirect("../accessDenied.html");
String opr_id = request.getParameter("opr_id");
%>
<html>
<head>
	<link href="../../stylesheets/v2.css" rel="stylesheet" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript">
		parent.left.location="newPRLeft.jsp";
	</script>
</head>
<body>
<font size="+1">Select a Contract</font><hr>
<%
//String query = "drop temporary table if exists pr_temp";
Database db = new Database();
//db.dbInsert(query);
//query = "create temporary table pr_temp (index (contract_id)) type = heap select contract_id from pay_requests where opr_id = " + opr_id;
//db.dbInsert(query);
// Get the list of companies that do not have pr's already (hence the left join)
String query = "select contracts.contract_id, division, cost_code, phase_code, code_description, company_name, pr_id from job_cost_detail as jcd, company, contracts "
	+ "left join pay_requests as pr on (pr.contract_id = contracts.contract_id and opr_id = " + opr_id + ") where pr.contract_id is null and contracts.company_id = company.company_id and "
	+ "jcd.cost_code_id = contracts.cost_code_id and contracts.job_id = " + attr.getJobId() + " order by costorder(division), costorder(cost_code), phase_code";
ResultSet rs = db.dbQuery(query);
%>
<form name="search" action="newPR2.jsp" method="POST">
	<input type="hidden" name="opr_id" value="<%= opr_id %>">
<table>
<tr>
<td class="lbl">Select a Contract</td>
<td><select name="contract_id">
<%
ResultSet rs2;
int count = 0;
// if they have a pr_id then they already have a pr!
while(rs.next() && rs.getString("pr_id") == null) {
	// Make sure the company doesn't already have a final pay request
	query = "select contract_id from pay_requests where final = 1 "
		+ "and contract_id = " +  rs.getString("contract_id");
	rs2 = db.dbQuery(query);
	if (!rs2.next()) {
		out.println("<option value=\"" + rs.getString("contract_id") + "\">" + rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code")
			+ " " + rs.getString("company_name") + ": " + rs.getString("code_description") + "</option>");
		count++;
	}
	if (rs2 != null) rs2.getStatement().close();
}
if (rs != null) rs.close();
rs = null;
//db.dbInsert("drop temporary table pr_temp");
db.disconnect();
%>
	</select></td>
</tr>
<tr>
	<td class="lbl">Final Payment</td>
	<td><input type="checkbox" name="final" value="y"></td>
</tr>
</table>
</form>
<script>
	if (<%= count %> == 0) {
		alert ("No contracts without pay requests during this\nperiod or without a submitted final payment\nare found!");
		parent.window.close();
	}
</script>
</body>
</html>

