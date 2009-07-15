<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.security.Security" %>
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<title>Job Cost Detail</title>
</head>
<frameset rows="37,*" frameborder="0" framespacing="0" border="0" id="fs">
	<frame src="phaseDetailTop.jsp?id=<%=request.getParameter("id")%>" name="header" scrolling="no">
   <frame src="phaseDetailMain.jsp?id=<%=request.getParameter("id")%>" name="main">
</frameset>
</html>
