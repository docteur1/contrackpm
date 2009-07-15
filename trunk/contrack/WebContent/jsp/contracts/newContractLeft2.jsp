<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,2)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body bgcolor="#DCDCDC">
<b>New<br>Subcontract
<hr>
<table>
<tr>
<td><input type="button" value="Save" onClick="parent.main.save()" accesskey="s"></td>
</tr>
<tr>
<td><input type="button" value="Spelling" onClick="parent.main.spell();" accesskey="k"></td>
</tr>
<tr>
<td><input type="button" value="Back" onClick="parent.main.location='newContract.jsp'" accesskey="b"></td>
</tr>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();" accesskey="c"></td>
</tr>
</table>
</body>
