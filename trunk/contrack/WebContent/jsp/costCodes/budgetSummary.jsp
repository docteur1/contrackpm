<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />

<%
if (!sec.ok(Name.COSTS, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
SimpleDateFormat formatter = new SimpleDateFormat("MMMM d, yyyy");
DecimalFormat df = new DecimalFormat("$#,##0.00");
Database db = new Database();
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
		<title>Budget Summary</title>
	</head>
<body>
<div class="title"><%= attr.getJobNum() + ": " + attr.getJobName() %></div>
<div><%=formatter.format(new java.util.Date())%></div>
<hr>
<%
String query = "select * from job_cost_detail where job_id = " + attr.getJobId() + " order by costorder(division), costorder(cost_code), costorder(phase_code)";
ResultSet rs = db.dbQuery(query);

%>
		<table cellspacing="0">
			<thead>
			<tr>
				<td class="head">Div Phase-Type</td>
				<td class="head">Description</td>
				<td class="head aright">Estimate</td>
				<td class="head aright">Budget</td>
				<td class="head">Entered</td>
			</tr>
			</thead>
			<%
			while (rs.next()){
			%>
			<tr>
				<td align="right"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") %>&nbsp;</td>
				<td>&nbsp;<%= rs.getString("code_description") %></td>
				<td align="right"><%= df.format(rs.getFloat("estimate")) %>&nbsp;</td>
				<td align="right"><%= df.format(rs.getFloat("budget")) %>&nbsp;</td>
				<td align="center"><input type="checkbox"></td>
			</tr>
			<%
			}
			rs.close();
			rs = null;
			db.disconnect();
			%>
		</table>

	</body>

</html>
