<%@ page language="java" contentType="text/plain; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
ResultSet rs = db.dbQuery("select * from rfi where rfi_id = " + request.getParameter("id"), true);
if (rs.first()) {
	rs.updateString("reply", request.getParameter("reply"));
	rs.updateDate("date_received", new java.sql.Date(new java.util.Date().getTime()));
	rs.updateBoolean("e_update", true);
	rs.updateRow();
	db.msg = "Saved";
}
rs.getStatement().close();
rs = null;
db.disconnect();
response.sendRedirect("modifyRFI.jsp?id=" + request.getParameter("id"));
%>