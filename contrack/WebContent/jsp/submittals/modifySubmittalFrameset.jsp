<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBMITTALS, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>Modify Submittal</title>
		<script src="../utils/popup.js"></script>
</head>
<frameset cols="110,*" frameborder="0">
	<frame src="modifySubmittalLeft.jsp?subID=<%=request.getParameter("subID")%>" name="left" noresize scrolling="no">
	<frame src="modifySubmittal.jsp?subID=<%=request.getParameter("subID")%><%= (request.getParameter("save")!=null?"&save=true":"") %>" name="main">
</frameset>
</html>