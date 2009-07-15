<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sinkluge.utilities.FormHelper, java.io.File" %>
<%@ page import="java.util.Properties, java.io.FileOutputStream" %>
<%@ page import="java.sql.ResultSet, java.sql.PreparedStatement, com.sinkluge.database.Database" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(com.sinkluge.security.Name.ADMIN, com.sinkluge.security.Permission.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript">
		function del(id){
			if(confirm("Delete this site?")) location = "sites.jsp?del=t&id=" + id;
		}
		var cls;
		function n(id) {
			id.className = cls;
		}
		function b(id) {
			cls = id.className;
			id.className = "yellow";
		}
	</script>
</head>
<body>
<form id="main" action="sites.jsp" method="POST" onSubmit="return checkForm(this);">
<font size="+1">Sites</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Sites<hr>
<%
String id = request.getParameter("id");
Database db = new Database();
if (request.getParameter("del") != null ) {
	ResultSet rs = db.dbQuery("select count(*) from job where site_id = " + id);
	if (rs.first() && rs.getInt(1) != 0) {
%>
	<div class="bold red">Unable to delete, there are <%= rs.getInt(1) %> project(s) associated with this site.
		<br>&nbsp;</div>
<%
	} else {
		db.dbInsert("delete from cost_types where site_id = " + id);
		db.dbInsert("delete from divisions where site_id = " + id);
		db.dbInsert("delete from sites where site_id = " + id);
		db.dbInsert("delete from settings where id = 'site" + id + "'");
		db.dbInsert("delete from cost_codes where site_id = " + id);
	}
	rs.getStatement().close();
} else if (request.getParameter("site_name") != null) {
	PreparedStatement ps = db.preStmt("insert into sites (site_name) values (?)");
	ps.setString(1, request.getParameter("site_name"));
	ps.executeUpdate();
	ResultSet ids = ps.getGeneratedKeys();
	ids.next();
	String newId = ids.getString(1);
	db.dbInsert("insert into settings (id, name, val) select 'site" + newId + "', name, val from "
			+ "settings where id = 'site1'");
	db.dbInsert("insert into settings (id, name, val) select 'ce" + newId + "', name, val from "
			+ "settings where id = 'ce1'");
	ids.close();
	ps.close();
	db.dbInsert("insert into divisions (division, description, site_id) select division, description, " 
		+ newId + " from divisions where site_id = 1");
	db.dbInsert("insert into cost_types (letter, description, labor, mapping, contract_title, contract, "
		+ "contractee_title, site_work, contractable, site_id) select letter, description, labor, mapping, "
		+ "contract_title, contract, contractee_title, site_work, contractable, " + newId + " from cost_types "
		+ "where site_id = 1");
	db.dbInsert("insert into cost_codes (division, cost_code, cost_type, description, site_id) "
		+ "select division, cost_code, cost_type, description, " + newId 
		+ " from cost_codes where site_id = 1");
	response.sendRedirect("uploadLogo.jsp?site_id=" + newId);
	return;
} else if (request.getParameter("change") != null) {
	db.dbInsert("update sites set def = 0");
	db.dbInsert("update sites set def = 1 where site_id = " + id);
}
%>
<table>
<tr>
	<td class="lbl">Default Site:</td>
	<td><select name="this_site_id" onchange="window.location='sites.jsp?change=t&id=' + this.value;">
<%
String query = "select * from sites";
ResultSet rs = db.dbQuery(query);
while (rs.next()) out.println("<option value=\"" + rs.getString("site_id") + "\" " + 
		FormHelper.sel(rs.getBoolean("def")) + ">" + rs.getString("site_name") + "</option>");

%>
		</select>
	</td>
</tr>
<tr>
	<td class="lbl">Add Site:</td>
	<td><input type="text" name="site_name"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Save"></td>
</tr>
</table>
<table style="margin-top: 10px;" cellspacing="0" cellpadding="3">
<tr>
	<td class="head left">Delete</td>
	<td class="head right">Value</td>
</tr>
<%
rs.beforeFirst();
boolean color = false;
while (rs.next()) {
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
	if (!rs.getBoolean("def")) {
%>
	<td class="left right"><a href="javascript: del(<%= rs.getString("site_id") %>);">Delete</a></td>
<%
	} else out.print("<td class=\"left right\">&nbsp;</td>");
%>
	<td class="right"><%= rs.getString("site_name") %></td>
</tr>
<%
	color = !color;
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</form>
<script>
	var d = document.getElementById("main");
	var f = d.site_name;
	f.required = true;
	f.eName = "Site Name";
	f.focus();
</script>
</body>
</html>