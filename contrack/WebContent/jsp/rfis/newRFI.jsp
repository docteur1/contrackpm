<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.RFI, sec.WRITE)) response.sendRedirect("../accessDenied.html");
String query = "(select distinct c.company_name, c.company_id, type "
	+ "from job_contacts left join company as c using(company_id) "
	+ "where job_id = " + attr.getJobId() + ")";
query += "union (select distinct c.company_name, c.company_id, null as type "
	+ "from contracts left join company as c using(company_id) "
	+ "where contracts.job_id = " + attr.getJobId() + ") order by company_name, type desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
%>

<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script>
		function showCompanies() {
			<% if (request.getParameter("limit") == null) out.println("location = \"newRFI.jsp?limit=true\";");
			else out.println("location = \"newRFI.jsp\";");
			%>
		}
		parent.left.document.location = "newRFILeft.jsp";
	</script>

</head>
<body>
	<font size="+1">New RFI</font><hr>
		<select onChange="window.location='newRFI2.jsp?company_id=' + this.value;">
			<option>--Select Project Company--</option>
<%
while (rs.next()) out.println("<option value=\"" + rs.getString("company_id") + "\">" + rs.getString("company_name") 
		+ "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
String companyName = request.getParameter("company_name");
%>
		</select>
		<form name="newRFI" action="newRFI.jsp" method="POST">
		<hr>
		<table>
			<tr><td class="lbl">Search for Company:</td>
				<td><input type="text" name="company_name" value="<%= FormHelper.string(companyName) %>"></td>
				<td><input type="submit" value="Search"></td>
			</tr>
		</table>
			</form>
<script language="javascript">
	document.newRFI.company_name.focus();
</script>
<%
if (companyName != null) {
%>
<hr>
<b>Search Results:</b><p>
<%
query = "select company_id, company_name from company where company_name like ? order by company_name limit 30";
PreparedStatement ps = db.preStmt(query);
ps.setString(1, request.getParameter("company_name") + "%");
rs = ps.executeQuery();
while(rs.next()) {
%>
	<a href="newRFI2.jsp?company_id=<%=rs.getString("company_id")%>"><%= rs.getString("company_name") %></a><br>
<%
}
if (ps != null) ps.close();
if (rs != null) rs.close();
}
db.disconnect();
%>
	</body>
</html>
