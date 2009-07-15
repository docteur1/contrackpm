<%@ page language="java" contentType="text/plain; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
String id = request.getParameter("id");
String sql = "select * from submittals where submittal_id = " + id;
ResultSet rs = db.dbQuery(sql, true);
if (rs.first()) {
	rs.updateString("comment_from_sub", request.getParameter("comments"));
	rs.updateBoolean("e_update", true);
	rs.updateRow();
}
rs.getStatement().close();
db.disconnect();
db.msg = "Saved.";
response.sendRedirect("viewSubmittal.jsp?id=" + id);
%>