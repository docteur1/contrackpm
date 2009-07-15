<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.Statement" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%

db.connect();
Statement stmt_update = db.getStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
String pr_id = request.getParameter("pr_id");
String query = "select * from pay_requests where pr_id = " + pr_id;
ResultSet rs = stmt_update.executeQuery(query);
String t;
if (rs.next()) {
	t = request.getParameter("external_comments");
	if (t == null) t = "";
	rs.updateString("external_comments", t);
	rs.updateBoolean("e_update", true);
	rs.updateRow();
	db.msg = "Saved.";
}
if (rs != null) rs.close();
rs = null;
if (stmt_update != null) stmt_update.close();
stmt_update = null;
db.disconnect();
response.sendRedirect("viewRetention.jsp?pr_id=" + pr_id);
%>