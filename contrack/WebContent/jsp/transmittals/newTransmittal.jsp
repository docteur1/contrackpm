<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.reports.ReportContact"%>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="com.sinkluge.servlets.PDFReport"%>
<html>
<%
boolean my = request.getParameter("my") != null;
String docPath = request.getParameter("docPath");
String add = request.getParameter("add");
if (!my && !sec.ok(Security.TRANSMITTALS, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>New <%= my ? "My " : "" %>Transmittal</title>
	<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script>
		var q = "?<%= docPath != null ? "docPath=" + response.encodeURL(docPath) + "&" : "" 
			%><%= my ? "my=t&" : "" %><%= add != null ? "add=" + add + "&" : "" %>";
	</script>
</head>
<body>
<div class="title">New <%= my ? "My " : "" %>Transmittal</div><hr>
<%
if (docPath != null) {
%>
<fieldset style="width: 400px; margin-bottom: 8px;">
<legend>Add To</legend>
<table>
<tr>
	<td class="lbl">Project</td>
	<td><input type="radio" name="add" value="project" checked onchange="q='?<%= docPath != null ? 
			"docPath=" + docPath + "&" : "" %><%= add != null ? "add=" + add + "&" : "" %>';"></td>
</tr>
<tr>
	<td class="lbl">My Transmittals</td>
	<td><input type="radio" name="add" value="my" onchange="q='?my=t&<%= docPath != null ? 
			"docPath=" + docPath + "&" : "" %><%= add != null ? "add=" + add + "&" : "" %>';"></td>
</tr>
</table>
</fieldset>
<%
}
%>
<fieldset style="width: 400px;">
<legend>Select a Recipient</legend>
<%
ResultSet rs = null;
String query;
boolean hasComp = false;
Database db = new Database();
if (docPath != null) {
	String id = null;
	if (docPath.indexOf("id=") != -1) id = docPath.substring(docPath.indexOf("id=") + 3);
	com.sinkluge.reports.Report r = PDFReport.getReport(request, docPath, id, null, db, attr, in);
	ReportContact rp = r.getReportContact(id, db);
	if (rp != null && rp.getCompanyId() != 0) {
		query = "select company_name from company where company_id = " + rp.getCompanyId();
		rs = db.dbQuery(query);
		if (rs.first()) {
			hasComp = true;
%>
	<input type="button" value="Send to &quot;<%= rs.getString(1) %>&quot;" 
		onclick="window.location='frameset.jsp' + q + 'company_id=<%= rp.getCompanyId() %>';"><br>
<%
		}
		rs.getStatement().close();
	}
}
query = "(select distinct c.company_name, c.company_id, type "
	+ "from job_contacts left join company as c using(company_id) "
	+ "where job_id = " + attr.getJobId() + ")";
query += "union (select distinct c.company_name, c.company_id, null as type "
	+ "from contracts left join company as c using(company_id) "
	+ "where contracts.job_id = " + attr.getJobId() + ") order by company_name, type desc";
rs = db.dbQuery(query);
%>
<select style="margin-top: 10px;" onchange="window.location='frameset.jsp' + q + 'company_id=' + this.value;">
	<option>--<%= hasComp ? "Or " : "" %>Select Project Company--</option>
<%
while (rs.next()) out.println("<option value=\"" + rs.getString("company_id") + "\">" + rs.getString("company_name") 
		+ "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
String search = request.getParameter("search");
%>
</select>
<form method="POST">
<div class="bold" style="margin-top: 15px;">Or Search for a Company</div>
<input type="text" id="search" name="search" value="<%= FormHelper.string(search) %>"> &nbsp; 
<input type="submit" value="Search">
</form>
<%
if (search != null) {
%>
<div class="bold" style="margin-top: 10px;">Search Results:</div>
<%
	PreparedStatement ps = db.preStmt("select company_id, company_name from company where "
			+ "company_name like ? order by company_name limit 50");
	ps.setString(1, search + "%");
	rs = ps.executeQuery();
	if (!rs.isBeforeFirst()) out.println("<div class=\"bold red\">No Results Found!</div>");
	while (rs.next()) out.println("<div class=\"link\" onclick=\"window.location='frameset.jsp' + q + '"
			+ "company_id=" + rs.getString("company_id") + "';\">"
			+ rs.getString("company_name") + "</div><br>");
	rs.getStatement().close();
}
%>
<input style="margin-top: 15px;" type="button" onclick="window.location='frameset.jsp' + q;"
	 value="Or Enter a Blank Company">
</fieldset>
<script>
	var search = document.getElementById("search");
	search.select();
	search.focus();
</script>
</body>
</html>
<%
db.disconnect();
%>