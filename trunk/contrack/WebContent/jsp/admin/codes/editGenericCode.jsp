<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.WRITE)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<LINK REL="stylesheet" HREF="../../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<title>Edit Phase Code</title>
	<script language="javascript" src="../utils/verify.js"></script>
</head>
<body>
<form id="main" action="processEditGenericCode.jsp" method="POST" onsubmit="return checkForm(this);">

<%
String siteId = request.getParameter("site_id");
String id = request.getParameter("id");
String query = "select * from cost_codes where site_id = " + siteId + " and code_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (rs.next()) {
%>
<font size="+1"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("cost_type") %></font><hr>
<input type="hidden" name="id" value="<%= id %>">
<input type="hidden" name="site_id" value="<%= siteId %>">
	<b>Description:</b>&nbsp;&nbsp;
	<input type="text" name="description" size=30 value="<%= rs.getString("description") %>">
<p>
		<input type="submit" value="Save">
		&nbsp;&nbsp;<input type="button" value="Cancel" onClick="window.close();">

<%
	}
	if (rs != null) rs.getStatement().close();
	db.disconnect();
%>

</form>
<script language="javascript">
	var f = document.getElementById("main");
	
	var d = f.description;
	d.required = true;
	d.eName = "Description";
</script>
</body>
</html>
