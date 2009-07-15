<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,2)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>New Contract</title>
</head>
<frameset cols="85,*" frameborder="0">
	<frame src="newContractLeft.jsp" noresize scrolling="no" name="left">
	<frame src="newContract.jsp" name="main">
</frameset>
</html>