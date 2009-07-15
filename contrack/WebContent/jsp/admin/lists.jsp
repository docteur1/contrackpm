<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sinkluge.utilities.FormHelper" %>
<%@ page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(com.sinkluge.security.Name.ADMIN, com.sinkluge.security.Permission.READ)){
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript">
		function del(id, val){
			if(confirm("Delete list item?")) location = "lists.jsp?action=del&id=" + id + "&val=" + val;
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
<form id="main" action="lists.jsp" method="POST" onSubmit="return checkForm(this);">
<font size="+1">List</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; List<hr>
<%
String id = request.getParameter("id");
id = id==null?"project_category":id;
Database db = new Database();
if (request.getParameter("val") != null) 
	db.dbInsert("insert ignore into lists (id, val) values ('" + id + "', '" + request.getParameter("val") + "')");
if (request.getParameter("action") != null ) 
	db.dbInsert("delete from lists where id = '" + id + "' and val = '" + request.getParameter("val") + "'");
%>
<table>
<tr>
	<td class="lbl">List:</td>
	<td><select id="list" name="id" onchange="location='lists.jsp?id=' + document.getElementById('list').value;">
		<option value="project_category" <%= FormHelper.sel("project_category", id) %>>Project Categories</option>
		<option value="project_contract" <%= FormHelper.sel("project_contract", id) %>>Project Contracts</option>
		<option value="project_team_role" <%= FormHelper.sel("project_team_role", id) %>>Project Team Roles</option>
		<option value="submittal_stamp" <%= FormHelper.sel("submittal_stamp", id) %>>Submittal Stamp</option>
		<option value="submittal_status" <%= FormHelper.sel("submittal_status", id) %>>Submittal Status</option>
		<option value="submittal_type" <%= FormHelper.sel("submittal_type", id) %>>Submittal Type</option>
		</select>
	</td>
</tr>
<tr>
	<td class="lbl">Value:</td>
	<td><input type="text" name="val"></td>
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
String query = "select val from lists where id = '" + id + "' order by val";
ResultSet rs = db.dbQuery(query);
boolean color = false;
while (rs.next()) {
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
	if (!id.equals("project_team_role") || !rs.getString("val").equals("Project Manager")) {
%>
	<td class="left right"><a href="javascript: del('<%= id %>', '<%= rs.getString(1) %>');">Delete</a></td>
<%
	} else out.print("<td class=\"left right\">&nbsp;</td>");
%>
	<td class="right"><%= rs.getString(1) %></td>
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
	var f = d.val;
	f.required = true;
	f.eName = "Value";
	f.focus();
</script>
</body>
</html>