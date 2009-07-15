<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.User" %>
<%@page import="java.util.Iterator, com.sinkluge.UserData" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.UserData" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
boolean sw = sec.ok(Security.JOB, Security.WRITE);
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script>
		function del(id){
			if(confirm("Remove team member from project?")) window.location = "jobTeam.jsp?action=del&id=" + id;
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
<form name="addMember" action="jobTeam.jsp" method="POST">
<div class="title">Project Team</div><hr>
<%= com.sinkluge.utilities.Widgets.logLink(Integer.toString(attr.getJobId()),
	com.sinkluge.Type.PROJECT, "window", "projects/jobTeam.jsp", request) %> &nbsp;
<%
if(sw) out.print("<a href=\"jobTeam.jsp\">Add Team Member</a>");
%>
<hr>
<%
String id = request.getParameter("id");
String name = request.getParameter("name");
int userId = Integer.parseInt(request.getParameter("user_id") != null ? request.getParameter("user_id") : "0");
String role = "";
String email = "";
String mobile = "";
String query = "select * from job_team where job_team_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
if (id != null && name != null) {
	// Modifying team member
	if (rs.next()) {
		userId = rs.getInt("user_id");
		role = request.getParameter("role");
		email = request.getParameter("email");
		mobile = request.getParameter("mobile");
		rs.updateString("role", role);
		if (userId == 0) {
			rs.updateString("name", name);
			com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
				Integer.toString(attr.getJobId()), "Updated " + name + 
				", a project team member.", session);
		} else {
			User user = User.getUser(userId);
			com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
				Integer.toString(attr.getJobId()), "Updated " + user.getFullName() + 
				", a project team member.", session);
		}
		rs.updateString("email", email);
		rs.updateString("mobile", mobile);
		rs.updateRow();
	}
} else if (id != null && request.getParameter("action") != null) {
	// Delete the row
	query = "delete from job_team where job_team_id = " + id;
	db.dbInsert(query);
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
		Integer.toString(attr.getJobId()), "Removed a project team member.", session);
	id = null;
} else if (id != null) {
	// reading team member
	if (rs.next()) {
		name = rs.getString("name");
		role = rs.getString("role");
		email = rs.getString("email");
		mobile = rs.getString("mobile");
	}
} else if (name != null) {
	// Insert the user
	rs.moveToInsertRow();
	role = request.getParameter("role");
	email = request.getParameter("email");
	mobile = request.getParameter("mobile");
	rs.updateInt("job_id", attr.getJobId());
	rs.updateString("name", name);
	rs.updateString("role", role);
	rs.updateString("email", email);
	rs.updateString("mobile", mobile);
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
		Integer.toString(attr.getJobId()), "Updated " + name + 
		" as a project team member.", session);
	rs.insertRow();
	rs.last();
	id = rs.getString("job_team_id");
} else if (userId != 0) {
	// Insert the drop down user
	rs.moveToInsertRow();
	User user = User.getUser(userId);
	name = user.getFullName();
	email = user.getEmail();
	UserData ud = UserData.getInstance(in, user);
	mobile = ud.get("mobile");
	role = request.getParameter("role");
	rs.updateInt("job_id", attr.getJobId());
	rs.updateInt("user_id", userId);
	rs.updateString("name", name);
	rs.updateString("email", email);
	rs.updateString("role", role);
	rs.updateString("mobile", mobile);
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT,
		Integer.toString(attr.getJobId()), "Added " + name + 
		" as a project team member.", session);
	rs.insertRow();
	rs.last();
	id = rs.getString("job_team_id");
}
if (rs != null) rs.getStatement().close();
if (sw) {
%>
<table style="margin-bottom: 10px;">
<tr>
	<td class="lbl">Add Team Member:</td>
	<td colspan="3"><%= com.sinkluge.utilities.Widgets.userList(0, "user_id") %>
	<select name="role">	
<%
query = "select name from job_team where role = 'Project Manager' and job_id = " + attr.getJobId();
rs = db.dbQuery(query);
boolean hasPM = rs.first();
if (rs != null) rs.getStatement().close();
query = "select val from lists where id = 'project_team_role' order by val";
rs = db.dbQuery(query);
while (rs.next()) {
	if (!hasPM || !rs.getString(1).equals("Project Manager"))
		out.print("<option>" + rs.getString(1) + "</option>");
}
if (rs != null) rs.getStatement().close();
%>
		</select> <input type="submit" value="Add"></td>
</tr>
</form>
<form id="main" action="jobTeam.jsp" method="POST" onsubmit="return checkForm(this);">
<tr>
	<td colspan="4"><hr>
<%
if (id != null) out.print("<input type=\"hidden\" name=\"id\" value=\"" + id + "\">");
%>	
	</td>
</tr>
<tr>
	<td class="lbl">Name:</td>
	<td><input type="text" name="name" value="<%= FormHelper.string(name) %>"></td>
	<td class="lbl">Role:</td>
	<td><select name="role">
<%
query = "select val from lists where id = 'project_team_role' order by val";
rs = db.dbQuery(query);
while (rs.next()) {
	if (!hasPM || !rs.getString(1).equals("Project Manager") || role.equals("Project Manager"))
		out.print("<option " + FormHelper.sel(role, rs.getString(1)) + ">" + rs.getString(1) + "</option>");
}
if (rs != null) rs.getStatement().close();
%>
		</select></td>
</tr>
<tr>
	<td class="lbl">Email:</td>
	<td><input type="text" name="email" value="<%= email %>"></td>
	<td class="lbl">Mobile:</td>
	<td><input type="text" name="mobile" maxlength="14" value="<%= FormHelper.string(mobile) %>"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td colspan="3">
<%
if (id != null) out.print("<input type=\"submit\" value=\"Save\">");
else out.print("<input type=\"submit\" value=\"Add\">");
%>
		</td>
</tr>
</table>
</form>
<script>
	var d = document.getElementById("main");
	var f = d.name;
	f.select();
	f.focus();
	f.required = true;
	f.eName = "Name";
	
	f = d.email;
	f.isEmail = true;
	f.eName = "Email";
	
	f = d.mobile;
	f.isPhone = true;
	f.eName = "Mobile";
</script>
<%
} // end if (sw)
%>
<table cellspacing="0" cellpadding="3">
<tr>
	<td class="left head">Remove</td>
	<td class="head">Edit</td>
	<td class="head">Name</td>
	<td class="head">Role</td>
	<td class="head">Email</td>
	<td class="right head">Mobile</td>
</tr>
<%
query = "select * from job_team where job_id = " + attr.getJobId() + " order by role, name";
db.connect();
rs = db.dbQuery(query);
boolean color = true;
while(rs.next()) {
	color = !color;
	email = rs.getString("email");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <%= FormHelper.color(color) %>>
	<td class="left"><a href="javascript: del(<%= rs.getString("job_team_id") %>)">Remove</a></td>
	<td class="right"><a href="jobTeam.jsp?id=<%= rs.getString("job_team_id") %>">Edit</a></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("name")) %></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("role")) %>
	<td class="it">
<%
	if (email != null) out.print("<a href=\"mailto: " + FormHelper.stringTable(rs.getString("name")) 
		+ " <" + email + ">\">" + email + "</a>");
	else out.println("&nbsp;");
%>
		</td>
	<td class="right"><%= FormHelper.stringTable(rs.getString("mobile")) %></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</body>
</html>