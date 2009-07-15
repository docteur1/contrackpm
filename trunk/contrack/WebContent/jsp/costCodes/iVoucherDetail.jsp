<%@page session="true"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.security.Security" %>
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
	<title>Voucher Detail</title>
</head>
<frameset rows="37,*" frameborder="0" framespacing="0" border="0" id="fs">
	<frame src="iVoucherDetailTop.jsp?id=<%=request.getParameter("id")%>&ccid=<%= request.getParameter("ccid") %>" name="header" scrolling="no">
   <frame src="iVoucherDetailMain.jsp?id=<%=request.getParameter("id")%>&ccid=<%= request.getParameter("ccid") %>" name="main">
</frameset>
</html>
