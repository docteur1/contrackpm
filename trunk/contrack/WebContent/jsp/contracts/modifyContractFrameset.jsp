<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("id");
%>
<html>
<head>
	<title>Modify Contract</title>
</head>
<frameset cols="120,*" frameborder="0">
	<frame src="modifyContractLeft.jsp?id=<%=id%>" noresize scrolling="no" name="left">
	<frame src="modifyContract.jsp?id=<%=id%>" name="main">
</frameset>
</html>