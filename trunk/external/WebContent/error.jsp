<%@page contentType="text/plain"%>
<%
response.sendRedirect(request.getContextPath() + "/login.jsp?error=true");
%>