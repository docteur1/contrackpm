<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.DELETE)) response.sendRedirect("../accessDenied.html");
String query = "delete from cost_codes where code_id = " + request.getParameter("id");
Database db = new Database();
db.dbInsert(query);
db.disconnect();
response.sendRedirect("genericCodes.jsp?site_id=" + request.getParameter("site_id"));
%>
