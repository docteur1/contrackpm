<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="db" class="com.sinkluge.database.Database" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
String add = request.getParameter("add");
String doc = request.getParameter("doc");
String type = request.getParameter("type");
String search = request.getParameter("search");
String query = null;
ResultSet rs = null;
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<title>Fax Document</title>
</head>
<body>
<form name="fax" action="searchFax.jsp" method="POST">
<font size="+1">Search</font><hr>
<a href="print.jsp?add=<%= add %>&doc=<%= doc %>">Print</a> &gt; 
<a href="fax.jsp?add=<%= add %>&doc=<%= doc %>">Fax</a> &gt; Search<hr>
<input type="hidden" name="id" value="<%= add %>">
<input type="hidden" name="doc" value="<%= doc%>">
<table>
	<tr>
		<td class="lbl">Search</td>
		<td><input type="text" id="search" name="search" value="<%= FormHelper.string(search) %>"></td>
		<td><select name="type">
			<option value="company_name" <%= FormHelper.sel(type, "company_name") %>>Company</option>
			<option value="name" <%= FormHelper.sel(type, "name") %>>Contact</option>
		</select></td>
		<td><input type="submit" value="Search"></td>
	</tr>
</table>
<%
if (type == null) {
	query = "(select c.company_name, c.company_id, n.contact_id, n.name from ((job_contacts left join contacts as n "
		+ "using(contact_id)) left join company as c on c.company_id = job_contacts.company_id) where job_id = " 
		+ attr.getJobId() + ") ";
	query += "union (select distinct c.company_name, c.company_id, n.contact_id, n.name from ((contracts left "
		+ "join contacts as n using(contact_id)) left join company as c on contracts.company_id = c.company_id) "
		+ "where contracts.job_id = " + attr.getJobId() + ") order by company_name, name";
	rs = db.dbQuery(query);
%>
<p><b>Select a Project Company/Contact:</b></p>
<%
	String name;
	while (rs.next()) {
		name = rs.getString("name");
		if (name == null) {
%>
<a href="fax.jsp?company_id=<%= rs.getString("company_id") %>&doc=<%= doc %>"><%= rs.getString("company_name") %><br>
<%
		} else {
%>
<a href="fax.jsp?contact_id=<%= rs.getString("contact_id") %>&doc=<%= doc %>"><%= rs.getString("company_name") %> - <%= name %><br>
<%			
		}
	}
	rs.getStatement().close();
} else {
	query = "select company_id, company_name, contact_id, name from company left join contacts using(company_id) "
		+ "where " + type + " like ? order by company_name, name limit 35";
	PreparedStatement ps = db.preStmt(query);
	ps.setString(1, search + "%");
	rs = ps.executeQuery();
%>
<p><b>Search Results:</b></p>
<%
	String name;
	while (rs.next()) {
		name = rs.getString("name");
		if (name == null) {
%>
<a href="fax.jsp?company_id=<%= rs.getString("company_id") %>&doc=<%= doc %>"><%= rs.getString("company_name") %><br>
<%
		} else {
%>
<a href="fax.jsp?contact_id=<%= rs.getString("contact_id") %>&doc=<%= doc %>"><%= rs.getString("company_name") %> - <%= name %><br>
<%			
		}
	}
	rs.close();	
	ps.close();
}
%>
</form>
<script>
	document.getElementById("search").select();
	document.getElementById("search").focus();
</script>
</body>
</html>