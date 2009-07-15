<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.TRANSMITTALS, Security.PRINT)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean my = request.getParameter("my") != null;
%>
<html>
<head>
	<title><%= my ? "My" : attr.getJobName() %> Transmittal Summary</title>
	<link rel=stylesheet href="../stylesheets/print.css" type="text/css" media="all">
</head>
<body>
	<div class="title"><%= my ? "My" : attr.getJobName() %> Transmittal Summary</div> 
	<hr>
<%
String query = "select * from transmittal left join contacts using(contact_id) left join company "
	+ "on transmittal.company_id = company.company_id where " + (my ? "username = '" 
	+ attr.getUserName() + "' and my = 1" : "job_id = " + attr.getJobId()) + " order by created desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String company, contact;
%>
<table>
	<thead>
	<tr>
		<td class="head">Date</td>
		<td class="head">Attention</td>
		<td class="head">Company</td>
		<td class="head">Status</td>
		<td class="head">Description</td>
		<td class="head">ID</td>
	</tr>
	</thead>
	<tbody>
<%
while (rs.next()){
	if (rs.getInt("transmittal.company_id") == 0) {
		company = rs.getString("transmittal.company_name");
		contact = rs.getString("transmittal.attn");
	} else {
		company = rs.getString("company.company_name");
		contact = rs.getString("name");
	}
%>
	<tr>
		<td><%= FormHelper.medDate(rs.getDate("created")) %></td>
		<td><%= contact %></td>
		<td><%= company %></td>
		<td><%= rs.getString("transmittal_status") %></td>
		<td><%= FormHelper.stringTable(rs.getString("description")) %></td>
		<td>TR<%= rs.getString("id") %></td>
	</tr>
<%
}
rs.close();
db.disconnect();
%>
	</tbody>
</table>

</body>
</html>
