<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.Widgets" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.database.Database" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
if (!sec.ok(Security.CO, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
Database db = new Database();
ResultSet rs = db.dbQuery("select authorization from change_request_detail where authorization = 1 and crd_id = " 
		+ id);
boolean auth = rs.first();
rs.getStatement().close();
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css" />
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script>
	function openWin(loc, x, y) {
		var msgWindow = open(loc, "crL", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function printCA() {
		var msgWindow = open("../utils/print.jsp?doc=changeCA.pdf?id=<%= id %>", "print");
		msgWindow.focus();
	}
</script>
</head>
<body class="left">
<div class="bold"><%= auth || id == null ? "Change Authorization" 
		: "Change Request Detail" %></div><hr>
<%
if (sec.ok(Security.CO, Security.WRITE)) {
%>
<input class="left" type="button" value="Save" id="save" onclick="parent.main.save();">
<input class="left" type="button" value="Spell" onclick="parent.main.spell();">
<%
}
if (sec.ok(Security.CO, Security.PRINT) && id != null) {
%>
<input class="left" type="button" value="Print" onclick="printCA();">
<%
	out.print(Widgets.docsButton(request.getParameter("id"), com.sinkluge.Type.CRD, "left", request));
}
%>
<input class="left" type="button" value="Close" onclick="parent.close();">
<%
db.disconnect();
%>
</body>
</html>