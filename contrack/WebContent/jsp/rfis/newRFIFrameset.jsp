<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.RFI, Security.WRITE)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>New RFI</title>
</head>
<frameset cols="95,*" frameborder="0">
	<frame src="newRFILeft.jsp" name="left" noresize scrolling="no">
	<frame src="newRFI.jsp" name="main">
</frameset>
</html>