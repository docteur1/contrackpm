<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,2)) response.sendRedirect("../accessDenied.html");
String opr_id = request.getParameter("opr_id");
%>
<html>
<head>
	<title>New Pay Request</title>
</head>
<frameset cols="75,*" frameborder="0">
	<frame src="newPRLeft.jsp?opr_id=<%= opr_id %>" noresize scrolling="no" name="left">
	<frame src="newPR.jsp?opr_id=<%= opr_id %>" name="main">
</frameset>
</html>