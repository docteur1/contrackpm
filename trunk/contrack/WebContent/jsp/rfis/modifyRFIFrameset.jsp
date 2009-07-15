<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.RFI,4)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>Modify RFI</title>
</head>
<frameset cols="95,*" frameborder="0">
	<frame src="modifyRFILeft.jsp?id=<%= request.getParameter("id") %>" name="left" noresize scrolling="no">
	<frame src="modifyRFI.jsp?id=<%= request.getParameter("id") %><%= (request.getParameter("save")!=null?"&save=true":"") %>" name="main">
</frameset>

</html>