<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
int siteId = Integer.parseInt(request.getParameter("site_id"));
String del = request.getParameter("del");
boolean process = request.getParameter("f") != null;
String id = request.getParameter("id");
String exec = "";
Database db = new Database();
if (del != null) {
	db.dbInsert("delete from divisions where division = '" + del + "' and site_id = " + siteId);
	db.disconnect();
	response.sendRedirect("reviewDivisions.jsp?site_id=" + siteId);
} else if (process) {
	id = request.getParameter("division");
	boolean isNew = request.getParameter("new") != null;
	if (isNew) exec = "insert ignore into divisions (division, description, site_id) values (?,?,?)";
	else exec = "update divisions set division=?, description=? where site_id = ? and division = ?";
	PreparedStatement ps = db.preStmt(exec);
	ps.setString(1, id);
	ps.setString(2, request.getParameter("desc"));
	ps.setInt(3, siteId);
	if (!isNew) ps.setString(4, id);
	int count = ps.executeUpdate();
	if (count == 0) {
%>
<script>
	alert("The division was not created!\n\nCheck for duplicate division numbers.");
</script>
<%
	}
	ps.close();
	db.disconnect();
	ps = null;
%>
<script>
	location = "reviewDivisions.jsp?site_id=<%= siteId %>";
</script>
<%
} else {
	id = request.getParameter("id");
	ResultSet rs = db.dbQuery("select * from divisions where division = '" + id + "' and site_id = " + siteId);
	String desc = "";
	if (rs.next()) desc = rs.getString("description");
	else id = "";
	if (rs != null) rs.close();
	db.disconnect();
	rs = null;
	
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
</head>
<body>
<form name="div" action="processDivision.jsp" method="post" onSubmit="return checkForm(this);">
<input type="hidden" name="site_id" value="<%= siteId %>">
<%
if (id.equals("")) out.print("<input type=\"hidden\" name=\"new\" value=\"true\">");
%>
<font size="+1">Division</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; <a href="reviewDivisions.jsp?site_id=<%= siteId %>">Divisions</a> &gt; Division
<%
ResultSet site = db.dbQuery("select site_name from sites where site_id = " + siteId);
if (site.next()) out.print(site.getString(1));
if (site != null) site.getStatement().close();
%>
<hr>
<table>
	<tr>
		<td class="lbl">Division</td>
		<td><input type="text" name="division" value="<%= id %>" maxlength="15"><input type="hidden" name="f" value="true"></td>
	</tr>
	<tr>
		<td class="lbl">Description</td>
		<td><input type="text" name="desc" value="<%= desc %>"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Save"></td>
	</tr>
</table>
<script language="javascript">
	var f = document.div;
	var d = f.division;
	d.required = true;
	d.eName = "Division";
	
	d = f.desc;
	d.required = true;
	d.eName = "Description";
</script>
</body>
</html>
<%
}
%>