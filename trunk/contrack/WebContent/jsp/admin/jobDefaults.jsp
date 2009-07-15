<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="java.sql.ResultSet, java.util.Hashtable, com.sinkluge.database.Database,
	com.sinkluge.security.Security" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%!
String getField(Hashtable<String, String> props, String name) {
	return "<input type=\"text\" name=\"" + name + "\" value=\"" + props.get(name) + "\">";
}
%>
<%
if (!sec.ok(com.sinkluge.security.Name.ADMIN, com.sinkluge.security.Permission.READ)){
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script src="../utils/verify.js"></script>
</head>
<body>
<form id="main" action="jobDefaults.jsp" method="POST" onsubmit="return checkForm(this);">
<font size="+1">Job Defaults</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Job Defaults<hr>
<%
Database db = new Database();
Hashtable<String, String> props = new Hashtable<String,String>();
ResultSet rs = db.dbQuery("select * from settings where id = 'job'", true);
String name;
if (request.getParameter("retention_rate") != null) {
	while (rs.next()) {
		name = rs.getString("name");
		props.put(name, request.getParameter(name));
		rs.updateString("val", request.getParameter(name));
		rs.updateRow();
	}
	out.print("<div class=\"red bold\">Saved</div><hr>");
} else {
	while (rs.next()) {
		name = rs.getString("name");
		props.put(name, rs.getString("val"));
	}
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
<table>
<tr>
	<td class="lbl">Retention Rate:</td>
	<td><%= getField(props, "retention_rate") %></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Save"></td>
</tr>
</table>
</form>
<script>
	var d = document.getElementById("main");
	var f = d.retention_rate;
	f.focus();
	f.select();
	f.required = true;
	f.eName = "Retention Rate";
	f.isFloat = true;
</script>
</body>
</html>