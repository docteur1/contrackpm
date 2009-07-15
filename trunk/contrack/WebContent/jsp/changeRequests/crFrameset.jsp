<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>Change Request</title>
</head>
<%
if (!sec.ok(Security.CO, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
%>
<frameset cols="110,*" border="0">
	<frame src="crLeft.jsp<%= id != null ? "?id=" + id : "" %>" noresize scrolling="no" name="left">
	<frame src="cr.jsp<%= id != null ? "?id=" + id : "" %>" name="main">
</frameset>
</html>