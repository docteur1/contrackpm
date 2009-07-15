<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.PreparedStatement, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String query = "update cost_codes set description = ? where code_id = " + request.getParameter("id");
Database db = new Database();
PreparedStatement ps = db.preStmt(query);
ps.setString(1, request.getParameter("description"));
ps.executeUpdate();
if (ps != null) ps.close();
db.disconnect();
%>
<script>
	opener.location.reload();
	window.close();
</script>