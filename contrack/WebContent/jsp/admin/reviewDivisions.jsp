<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
int siteId = Integer.parseInt(request.getParameter("site_id"));
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script src="../utils/table.js"></script>
	<script language="javascript">
		function del(id) {
			if (confirm("Delete this division?")) location = "processDivision.jsp?site_id=<%= siteId %>&del=" + id;
		}
	</script>
</head>
<body>
<font size="+1">Divisions</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Divisions &nbsp;&nbsp; <a href="processDivision.jsp?site_id=<%= siteId %>&id=0">Add</a><hr>
<table style="margin-bottom: 8px;">
	<tr>
		<td class="lbl">Site</td>
		<td colspan="3"><select name="site_id" onChange="window.location='reviewDivisions.jsp?site_id=' + this.value;">
<%
Database db = new Database();
ResultSet sites = db.dbQuery("select site_id, site_name from sites");
while (sites.next()) out.println("<option value=\"" + sites.getString(1) + "\" " + 
		FormHelper.sel(sites.getInt(1), siteId) + ">" + sites.getString(2) + "</option>");
if (sites != null) sites.getStatement().close();
%>
		</select></td>
	</tr>
</table>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
		<td class="left nosort head">Delete</td>
		<td class="nosort head">Edit</td>
		<td class="head">Division</td>
		<td class="right head">Description</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
ResultSet rs = db.dbQuery("select * from divisions where site_id = " + siteId + " order by costorder(division)");
String div = null;
boolean color = false;
while (rs.next()) {
	div = rs.getString("division");
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
		<td class="left"><a href="javascript: del('<%= div %>');">Delete</a></td>
		<td class="right"><a href="processDivision.jsp?site_id=<%= siteId %>&id=<%= div %>">Edit</a></td>
		<td class="it" align="right"><%= div %></td>
		<td class="right"><%= rs.getString("description") %></td>
	</tr>
<%
	color = !color;
}
if (rs != null) rs.getStatement().close();
db.disconnect();
rs = null;
%>
</table>
</div>
</body>
</html>