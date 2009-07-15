<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,2)) response.sendRedirect("../accessDenied.html");
String pr_id = request.getParameter("id");
%>
<html>
<head>
	<title>Modify Pay Request</title>
</head>
<frameset cols="75,*" frameborder="0">
	<frame src="modifyPRLeft.jsp?pr_id=<%= pr_id %>" noresize scrolling="no" name="left">
	<frame src="modifyPR.jsp?pr_id=<%= pr_id %>" name="main">
</frameset>
</html>