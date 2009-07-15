<%@page contentType="text/html"%>
<%@page import="org.apache.log4j.Logger"%>
<html>
<head>
	<link rel="SHORTCUT ICON" href="<%= request.getContextPath() %>/images/ct64.ico">
	<title>Contrack - Not Logged In</title>
	<style>
		fieldset, input, td {
			font-family: Arial;
			font-size: 10pt;
			color: white;
		}
		a, a:visited, a:link {
			color: white;
		}
		a:hover {
			color: red;
		}
	</style>
</head>
<body bgcolor="black">
	<table><tr>
	<td>
		<img src="<%= request.getContextPath() %>/images/contrack.gif">
	</td></tr>
	<tr><td align="center" style="font-weight: bold">&nbsp;<p>Signed out. Click <a href="jsp/">here</a> to log in.</p>
	<%= (request.getParameter("reason") != null && 
		request.getParameter("reason").indexOf("User Requested") == -1 
		? "<p>Reason for ending session: " + request.getParameter("reason") + ".</p>" : "") %>
	</td></tr>
</table>
</body>
</html>
<%
if (session != null && !session.isNew()) {
	session.setAttribute("reason", request.getParameter("reason"));
	session.invalidate();
} else if (session != null) session.invalidate();
if (System.getProperty("com.sinkluge.Test") != null) {
	Logger log = Logger.getLogger(this.getClass());
	log.debug("Redirecting to jsp/ (auto-login)");
	response.sendRedirect("jsp/");
}
%>