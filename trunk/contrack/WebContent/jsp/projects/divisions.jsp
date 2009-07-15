<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sd = sec.ok(Security.ACCOUNT, Security.DELETE);
boolean sw = sec.ok(Security.ACCOUNT, Security.WRITE);
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="../utils/table.js"></script>
<script src="../utils/verify.js"></script>
<%
if (sd) {
%>
<script>
	function del(id) {
		if (window.confirm("Delete this division?")) window.location = "divisions.jsp?del=" + id;
	}
</script>
<%
}
%>
</head>
<body>
<div class="title">Project Divisions</div><hr>
<div class="link" onclick="window.location='divisions.jsp';">New</div>
&nbsp; <%= com.sinkluge.utilities.Widgets.logLink(Integer.toString(attr.getJobId()),
	com.sinkluge.Type.PROJECT, "window", "projects/divisions.jsp", request) %> &nbsp;<hr>
<%
String id = request.getParameter("id");
boolean saved = false;
ResultSet rs = null;
String del = request.getParameter("del");
Database db = new Database();
if (del != null && sd) {
	rs = db.dbQuery("select count(*) from job_cost_detail as jcd join job_divisions as jd on "
		+ "jcd.job_id = jd.job_id and jcd.division = jd.division where jd_id = " + del + " "
		+ " and jd.job_id = " + attr.getJobId());
	if (rs.first() && rs.getInt(1) != 0) out.println("<div class=\"red bold\">"
		+ "Unable to delete division: Associated with " + rs.getInt(1) + " codes.</div><hr>");
	else {
		rs.getStatement().close();
		rs = db.dbQuery("select * from job_divisions where jd_id = " + del, true);
		if (rs.next()) {
			com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.PROJECT,
				Integer.toString(attr.getJobId()), "Deleted project division: " +
				rs.getString("division") + " " + rs.getString("description"), session);
			rs.deleteRow();
		}
	}
	rs.getStatement().close();
	rs = null;
}
if (sw) {
	String division = request.getParameter("division");
	String description = "";
	if (division != null) {
		rs = db.dbQuery("select * from job_divisions where jd_id = " + id, true);
		if (!rs.first()) {
			rs.moveToInsertRow();
			rs.updateInt("job_id", attr.getJobId());
		}
		rs.updateString("division", division);
		description = request.getParameter("description");
		rs.updateString("description", description);
		try {
			if (id == null) {
				com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
					Integer.toString(attr.getJobId()), "Added project division: " +
					division + " " + description, session);
				rs.insertRow();
				rs.last();
				id = rs.getString("jd_id");
			} else {
				com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
						Integer.toString(attr.getJobId()), "Updated project division: " +
						division + " " + description, session);
				rs.updateRow();
			}
			saved = true;
		} catch (java.sql.SQLException e) {
			out.println("<div class=\"red bold\">ERROR! No duplicated divisions allowed!</div><hr>");
		}
	} else if (id != null) {
		rs = db.dbQuery("select * from job_divisions where jd_id = " + id);
		if (rs.first()) {
			division = rs.getString("division");
			description = rs.getString("description");
		}
	}
	if (rs != null) rs.getStatement().close();
	if (saved) out.println("<div class=\"red bold\">Saved</div><hr>");
%>
<form method="POST" id="main" onsubmit="return checkForm(this);">
<%= id != null ? "<input type=\"hidden\" name=\"id\" value=\"" + id + "\">" : "" %>
<table>
<tr>
	<td class="lbl">Division</td>
	<td><input type="text" name="division" value="<%= FormHelper.string(division) %>" maxlength="15"></td>
</tr>
<tr>
	<td class="lbl">Description</td>
	<td><input type="text" name="description" value="<%= description%>" maxlength="50"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="<%= id == null ? "Add" : "Save" %>"></td>
</tr>
</table>
</form>
<script>
	var m = document.getElementById("main");
	var f = m.division;
	f.required = true;
	f.eName = "Division";
	f.select();
	f.focus();
	f = m.description;
	f.required = true;
	f.eName = "Description";
</script>
<%
}
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<%= sd ? "<td class=\"head left nosort\">Delete</td>" : "" %>
	<%= sw ? "<td class=\"head nosort " + (!sd ? "left" : "") + "\">Edit</td>" : "" %>
	<td class="head <%= !sw && !sd ? "left" : "" %>">Division</td>
	<td class="head right">Description</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean color = false;
rs = db.dbQuery("select * from job_divisions where job_id = " + attr.getJobId() + " order by "
	+ "costorder(division)");
while (rs.next()) {
	color = !color;
	id = rs.getString("jd_id");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<%= sd ? "<td class=\"left\"><div class=\"link\" onclick=\"del(" + id + ");\">Delete</div></td>" : "" %>
	<%= sw ? "<td class=\"" + (!sd ? "left" : "it") + "\"><div class=\"link\" onclick=\"window.location="
		+ "'divisions.jsp?id=" + id + "';\">Edit</div></td>" : "" %>
	<td class="left"><%= rs.getString("division") %></td>
	<td class="right"><%= rs.getString("description") %></td>
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