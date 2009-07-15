<%@ page language="java" contentType="text/plain; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet, java.sql.SQLException"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
String sql = "select * from company where company_id = " + db.company_id;
db.connect();
ResultSet rs = db.getStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE).executeQuery(sql);
rs.first();
rs.updateString("company_name", request.getParameter("company_name"));
rs.updateString("address", request.getParameter("address"));
rs.updateString("city", request.getParameter("city"));
rs.updateString("state", request.getParameter("state"));
rs.updateString("zip", request.getParameter("zip"));
rs.updateString("phone", request.getParameter("phone"));
rs.updateString("fax", request.getParameter("fax"));
rs.updateString("website", request.getParameter("website"));
rs.updateString("federal_id", request.getParameter("federal_id"));
rs.updateString("license_number", request.getParameter("license_number"));
try {
	rs.updateRow();
	db.msg="Saved.";
} catch (SQLException e) {
	db.msg="Not Saved. Company \"" + request.getParameter("company_name") + "\" already exists";
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
response.sendRedirect("index.jsp");
%>