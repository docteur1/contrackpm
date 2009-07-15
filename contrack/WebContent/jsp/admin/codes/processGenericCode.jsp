<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<html>
<%
if (!sec.ok(Security.ADMIN, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String query = "insert ignore into cost_codes (cost_type, description, cost_code, division, site_id) values "
	+ "(?,?,?,?,?)";
Database db = new Database();
PreparedStatement ps = db.preStmt(query);
ps.setString(1, request.getParameter("cost_type"));
ps.setString(2, request.getParameter("description"));
ps.setString(3, request.getParameter("cost_code"));
ps.setString(4, request.getParameter("division"));
ps.setString(5, request.getParameter("site_id"));
ps.executeUpdate();
if (ps != null) ps.close();
db.disconnect();
%>
<script>
	opener.location.reload();
	window.close();
</script>
</html>
