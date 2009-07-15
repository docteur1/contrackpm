<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.LETTERS, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body bgcolor="#DCDCDC">
<b>Letter<br>Recipients
<hr>
<table>
<%
if (sec.ok(Security.LETTERS, Security.WRITE)) {
%>
<tr>
<td><input type="button" value="Save" onClick="parent.main.save();"></td>
</tr>
<%
}
%>
<tr>
<td><input type="button" value="Back" onClick="parent.main.location='modifyLetter.jsp?letter_id=<%= request.getParameter("id") %>'"></td>
</tr>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();"></td>
</tr>
</table>
</body>
