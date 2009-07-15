<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.Statement, java.util.Date, java.sql.Timestamp" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
String query = "select * from pay_requests where pr_id = " + request.getParameter("pr_id");
db.connect();
Statement stmt = db.getStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
ResultSet rs = stmt.executeQuery(query);
rs.first();
rs.updateString("invoice_num", request.getParameter("inv_num"));
rs.updateString("value_of_work", request.getParameter("vwctd"));
rs.updateString("previous_billings", request.getParameter("ptd"));
rs.updateString("retention", request.getParameter("ret"));
rs.updateString("ext_mod_by", db.contact_name);
rs.updateTimestamp("ext_modified", new Timestamp(new Date().getTime()));
rs.updateString("external_comments", request.getParameter("external_comments"));
rs.updateBoolean("e_update", true);
rs.updateRow();
rs.close();
rs = null;
stmt.close();
stmt = null;
db.disconnect();
db.msg = "Saved";
response.sendRedirect("modifyPR.jsp?pr_id=" + request.getParameter("pr_id"));
%>