<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.LETTERS, Security.WRITE)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>New Letter</title>
</head>
<frameset cols="100,*" frameborder="0">
	<frame src="newLetterLeft.jsp" noresize scrolling="no" name="left">
	<frame src="newLetter.jsp" name="main">
</frameset>
</html>