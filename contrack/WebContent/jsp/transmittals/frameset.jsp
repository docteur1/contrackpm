<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%
String id = request.getParameter("id");
String companyId = request.getParameter("company_id");
boolean my = request.getParameter("my") != null;
String docPath = request.getParameter("docPath");
String add = request.getParameter("add");
String params = "?";
if (id != null) params += "id=" + id + "&";
if (companyId != null) params += "company_id=" + companyId + "&";
if (my) params += "my=t&";
if (docPath != null) params += "docPath=" + response.encodeURL(docPath) + "&";
if (add != null) params += "add=" + add;

if (!my && !sec.ok(Security.TRANSMITTALS, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title><%= my ? "My " : "" %>Transmittal</title>
</head>
<frameset cols="110,*" border="0">
	<frame src="transmittalLeft.jsp<%= params %>" noresize scrolling="no" name="left">
	<frame src="transmittal.jsp<%= params %>" name="main">
</frameset>
</html>