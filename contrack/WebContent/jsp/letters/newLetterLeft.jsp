<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.LETTERS, Security.WRITE)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body bgcolor="#DCDCDC">
<b>New<br>Letter
<hr>
<table>
<tr>
<td><input type="button" value="Next" onClick="parent.main.save();"></td>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();"></td>
</tr>
</table>
</body>
