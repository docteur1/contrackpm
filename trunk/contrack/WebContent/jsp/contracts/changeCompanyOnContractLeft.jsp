<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,4)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("id");
%>
<html>
<head>
	<link href="../stylesheets/v2.css" rel="stylesheet" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body bgcolor="#DCDCDC">
<b>Modify<br>Subcontract
<hr>
<table>
<tr>
<td><input type="button" value="Back" onClick="parent.main.location='modifyContract.jsp?id=<%=id%>';"></td>
</tr>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();"></td>
</tr>
</body>
