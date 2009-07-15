<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.Type" %>
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
	function printCR() {
		var msgWindow = open("../utils/print.jsp?doc=changeCR.pdf?id=<%= id %>", "print");
		msgWindow.focus();
	}
</script>
</head>
<body class="left">
<div class="bold">Change Request</div><hr>
<%
Database db = new Database();
if (sec.ok(Security.CO, Security.WRITE)) {
	ResultSet rs = db.dbQuery("select status from change_requests where cr_id = " + id
		+ " and status = 'Approved'");
%>
<input class="left" type="button" value="Save" id="save"
	onclick="this.disabled=true;this.value='Saving...';if(!parent.main.save()){this.disabled=false;this.value='Save';}"
	<%= rs.first() ? "disabled" : "" %>>
<input class="left" type="button" value="Spell" onclick="parent.main.spell();">
<%
	rs.getStatement().close();
}
if (sec.ok(Security.CO, Security.PRINT) && id != null) {
%>
<input class="left" type="button" value="Print" onclick="printCR();">
<%
	out.print(Widgets.docsButton(request.getParameter("id"), Type.CR, "left", request));
}
%>
<input class="left" type="button" value="Close" onclick="parent.close();">
<%
db.disconnect();
%>
</body>
</html>