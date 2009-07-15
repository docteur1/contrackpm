<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.Type" %>
<%@page import="com.sinkluge.security.Security,com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
	if (!sec.ok(Security.RFI, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script>
		function eSubmit(loc) {
			if (window.confirm("Send an email notifying contact of rfi?")) parent.window.location = loc;
		}
	</script>
</head>
<body bgcolor="#DCDCDC">
<b>Modify RFI</b>
<hr>
<table>
<%
	if(sec.ok(Security.RFI, Security.WRITE)){
%>
<tr>
<td><input type="button" value="Save" onClick="parent.main.save();" accesskey="s"></td>
</tr>
<tr>
<td><input type="button" value="Spelling" onClick="parent.main.spell();" accesskey="k"></td>
</tr>
<%
	}
%>
<tr>
<td><%= Widgets.docsButton(request.getParameter("id"), Type.RFI, request)%></td>
</tr>
<tr>
<td><%= Widgets.eSubmit(request.getParameter("id"), Type.RFI, "parent", request) %></td>
</tr>
<tr>
<td><input type="button" value="Print" accesskey="p" onClick="msgWin = window.open(''); msgWin.location='../utils/print.jsp?doc=rfi.pdf?id=<%= request.getParameter("id") %>'; msgWin.focus();"></td>
</tr>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();" accesskey="c"></td>
</tr>
</table>
</body>
</html>
