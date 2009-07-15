<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission, com.sinkluge.utilities.FormHelper"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<script src="../utils/table.js"></script>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script>
		function openRFI(jobId) {
			parent.setProjectId(jobId, "rfis/reviewRFIs.jsp");
		}
	</script>
</head>
<body>
<div class="title">Modified RFIs</div><hr>
<div class="link" onclick="window.location='../main.jsp'">Home</div> &gt; RFIs<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="left head nosort">Open</td>
	<td class="head">Proj #</td>
	<td class="head">Project</td>
	<td class="head">RFI #</td>
	<td class="head">Company</td>
	<td class="head right">Description</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean color = true;
String sql;
if (sec.ok(Name.ADMIN, Permission.READ)) sql = "select job.job_id, job_num, job_name, rfi_num, company_name, "
	+ "left(request, 50) as dsc from rfi "
	+ "join job using(job_id) join company using(company_id) join user_jobs as uj on "
	+ "job.job_id = uj.job_id where uj.username = '" + attr.getUserName() + "' and e_update = 1 "
	+ "order by job_num desc, company_name";
else sql = "select job.job_id, job_num, job_name, rfi_num, company_name, "
	+ "left(request, 50) as dsc from rfi "
	+ "join job using(job_id) join company using(company_id) join user_jobs as uj on "
	+ "job.job_id = uj.job_id join job_permission as jp on jp.job_id = uj.job_id and "
	+ "jp.username = uj.username where uj.username = '" + attr.getUserName() + "' and e_update = 1 "
	+ "and jp.name = '" + Name.RFIS + "' and jp.val like '%" + Permission.READ + "%' order by job_num desc, " 
	+ "company_name";
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
while (rs.next()) {
	color = !color;
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
		<td class="left"><div class="link" onclick="openRFI(<%= rs.getString("job_id") %>);">Open</div></td>
		<td class="it"><%= rs.getString("job_num") %></td>
		<td class="it"><%= rs.getString("job_name") %></td>
		<td class="it"><%= FormHelper.stringTable(rs.getString("rfi_num")) %></td>
		<td class="it"><%= rs.getString("company_name") %></td>
		<td class="right"><%= rs.getString("dsc") %></td>
	</tr>
<%
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>