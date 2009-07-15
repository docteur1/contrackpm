<%@page contentType="text/plain"%>
<%@page session="true"%>
<%
if (request.getParameter("logoff") != null) {
	session.invalidate();
	response.sendRedirect("logout.jsp");
}
else response.sendRedirect("jsp/init.jsp");
%>