<%@page contentType="text/html"%>
<html>
<head>
	<title>Contrack - Not Logged In</title>
	<link rel="SHORTCUT ICON" href="<%= request.getContextPath() %>/ct64.ico">
	<style>
		fieldset, input, td {
			font-family: Arial;
			font-size: 10pt;
			color: white;
		}
		a, a:visited, a:link {
			color: white;
			text-decoration: underline;
		}
		a:hover {
			color: red;
		}
	</style>
</head>
<body bgcolor="#000000">
<form name="login" action="j_security_check" method="POST">
<table width="100%"><tr><td align="center">
	<table><tr><td align="center">
		<img src="<%= request.getContextPath() %>/contrack.gif">
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td align="center"><b>Logged out. Click <a href="jsp/init.jsp">here</a> to log in.<p>If finished close the browser window.</b></td></tr>
	</td></td></table>
</td></tr></table>
</body>
</html>
<%
session.invalidate();
%>