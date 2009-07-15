<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBMITTALS,4)) response.sendRedirect("../accessDenied.html");
String contract_id = request.getParameter("contract_id");
if (contract_id != null) contract_id = "?contract_id=" + contract_id;
else contract_id = "";
%>
<html>
<head>
	<title>New Submittal</title>
</head>
<frameset cols="85,*" frameborder="0">
	<frame src="newSubmittalLeft.jsp" noresize scrolling="no">
	<frame src="newSubmittal.jsp<%= contract_id %>" name="main">
</frameset>
</html>