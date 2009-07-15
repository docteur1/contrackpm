<%@ page language="java" contentType="text/plain; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
String id = request.getParameter("id");
String sql = "select * from submittals where submittal_id = " + id;
ResultSet rs = db.dbQuery(sql, true);
if (rs.first()) {
	rs.updateBoolean("architect_stamp", request.getParameter("stamp") != null);
	rs.updateString("comment_from_architect", request.getParameter("comments"));
	if (request.getParameter("stamp") != null)
			rs.updateDate("date_from_architect", new java.sql.Date(new java.util.Date().getTime()));
	rs.updateBoolean("e_update", true);
	rs.updateRow();
}
rs.getStatement().close();
db.disconnect();
db.msg = "Saved.";
response.sendRedirect("modifySubmittal.jsp?id=" + id);
%>