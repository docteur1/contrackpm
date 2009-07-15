<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, java.util.Map" %>
<%@page import="com.sinkluge.User" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<LINK REL="stylesheet" HREF="stylesheets/v2.css" TYPE="text/css">
	<title>Access Denied</title>
</head>
<body>
<div class="title red">Access Denied</div><hr>
<div class="bold">You do not have sufficient permissions to view/execute this page on this project!<br>
	<br>The following users are allowed to grant permissions on this project.</div>
<p>
<%
String sql = "select user_id from job_permissions where name = '" + Name.PERMISSIONS 
	+ "' and val like '%" + Permission.WRITE + "%' and job_id = " + attr.getJobId();

Database db = new Database();
ResultSet rs = db.dbQuery(sql);
User user;
while (rs.next()) {
	user = User.getUser(rs.getInt(1));
	if (user != null) {
		out.println("<div class=\"link\" onclick=\"window.location='mailto:&quot;" + user.getFullName()
		    + "&quot; <" + user.getEmail() + ">';\">" + user.getFullName() + "</div><br>");
	} else out.println(rs.getString(1) + " (Unknown/Inactive user)<br>");
}
rs.getStatement().close();
db.disconnect();
%>
</p>
<p>Administrators can also set permissions.</p>
</body>
</html>