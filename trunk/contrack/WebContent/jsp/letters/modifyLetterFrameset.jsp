<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.LETTERS, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>Modify Letter</title>
</head>
<frameset cols="100,*" frameborder="0">
	<frame src="modifyLetterLeft.jsp?letter_id=<%=request.getParameter("letter_id")%>" noresize scrolling="no" name="left">
	<frame src="modifyLetter.jsp?letter_id=<%=request.getParameter("letter_id")%>" name="main">
</frameset>
</html>