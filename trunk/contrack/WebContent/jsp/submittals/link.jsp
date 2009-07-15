<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.security.Security, java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
if (!sec.ok(Security.SUBMITTALS, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("id");
Database db = new Database();
if (request.getParameter("del") != null) {
	db.dbInsert("delete from submittal_links where submittal_id = " + id + " and contract_id = "
			+ request.getParameter("contract_id"));
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.SUBMITTAL,
			id, "Submittal link to subcontract SA" + request.getParameter("contract_id") +
			" removed",	session);
} else if (request.getParameter("contract_id") != null) {
	db.dbInsert("insert ignore into submittal_links (submittal_id, contract_id) values (" + id + ","
			+ request.getParameter("contract_id") + ")");
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.SUBMITTAL,
		id, "Submittal linked to subcontract SA" + request.getParameter("contract_id"), 
		session);
}
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<script>
		parent.left.location="linkLeft.jsp?id=<%= id %>";
	</script>
</head>
<body>
<font size="+1">Link Submittal Documents</font><hr>
<table style="margin-bottom: 10px;">
<tr>
	<td class"lbl">Contract:</td>
	<td><select id="contract_id" onChange="window.location='link.jsp?id=<%= id %>&contract_id=' + this.value;">
		<option>Link to contract...</option>
<%
String query = "select contract_id from submittals where submittal_id = " + id;
int contract_id = 0;
ResultSet rs = db.dbQuery(query);
if (rs.first()) contract_id = rs.getInt("contract_id");
rs.getStatement().close();
query = "select contract_id, division, cost_code, phase_code, code_description, company_name from contracts join company "
	+ "using (company_id) join job_cost_detail using (cost_code_id) where contracts.job_id = " + attr.getJobId()
	+ " and contract_id != " + contract_id + " order by costorder(division), costorder(cost_code), phase_code";
rs = db.dbQuery(query);
ResultSet rs2;
while (rs.next()) {
	query = "select * from submittal_links where submittal_id = " + id + " and contract_id = " + rs.getString("contract_id");
	rs2 = db.dbQuery(query);
	if (!rs2.isBeforeFirst()) {
		out.println("<option value=\"" + rs.getString(1) + "\">" + rs.getString("division") + " " + rs.getString("cost_code")
			+ "-" + rs.getString("phase_code") + ": " + rs.getString("company_name") + ": " + rs.getString("code_description")
			+ "</option>");
	}
	rs2.getStatement().close();
}
rs2 = null;
rs.getStatement().close();
%>
</select></td>
</tr>
</table>
<table cellspacing="0" cellpadding="3">
<tr>
	<td class="head left">Delete</td>
	<td class="head right">Contract</td>
</tr>
<%
query = "select contracts.contract_id, division, cost_code, phase_code, code_description, company_name from contracts "
	+ "join company using (company_id) join job_cost_detail using (cost_code_id) join submittal_links using(contract_id) where "
	+ "submittal_id = " + id + " order by costorder(division), costorder(cost_code), phase_code";
rs = db.dbQuery(query);
while (rs.next()) {
%>
<tr>
	<td class="left right"><a href="link.jsp?del=true&id=<%= id %>&contract_id=<%= rs.getString("contract_id") %>">
		Delete</a>
	</td>
	<td class="right"><%= rs.getString("division") + " " + rs.getString("cost_code")
			+ "-" + rs.getString("phase_code") + ": " + rs.getString("company_name") + ": " 
			+ rs.getString("code_description") %></td>
</tr>
<%
}
rs.getStatement().close();
%>
</table>
<%
rs = null;
db.disconnect();
%>
</body>
</html>