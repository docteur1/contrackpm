<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.Type" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.database.Database" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
	String id = request.getParameter("id");
boolean my = request.getParameter("my") != null;
if (!my && !sec.ok(Name.TRANSMITTALS, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css" />
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script>
	function openWin(loc, x, y) {
		var msgWindow = open(loc, "transL", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function printTrans() {
		var msgWindow = open("../utils/print.jsp?doc=Transmittal.pdf?id=<%= id %>", "print");
		msgWindow.focus();
	}
</script>
</head>
<body class="left">
<div class="bold"><%=my ? "My " : ""%>Transmittal</div><hr>
<%
	if (my || sec.ok(Name.TRANSMITTALS, Permission.WRITE)) {
%>
<input class="left" type="button" value="Save" id="save" onclick="parent.main.save();">
<input class="left" type="button" value="Spell" onclick="parent.main.spell();">
<%
	}
if ((my || sec.ok(Name.TRANSMITTALS, Permission.PRINT)) && id != null) {
%>
<input class="left" type="button" value="Print" onclick="printTrans();">
<%
	out.print(Widgets.docsButton(request.getParameter("id"), !my ? Type.TRANSMITTAL : Type.MY_TRANSMITTAL, 
		"left", request));
}
%>
<input class="left" type="button" value="Close" onclick="parent.close();">
</body>
</html>