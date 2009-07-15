<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
if (!sec.ok(Security.CO, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title><%
String id = request.getParameter("id");
String scId = request.getParameter("contract_id");
String sql = "select authorization from change_request_detail where crd_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
if ((rs.first() && rs.getBoolean(1)) || id == null) out.print("Change Authorization");
else out.print("Change Request Detail");
rs.getStatement().close();
rs = null;
if (scId != null) {
	sql = "select cost_code_id from contracts where contract_id = " + scId;
	rs = db.dbQuery(sql);
	if (rs.first()) scId = rs.getString(1) + "n" + scId;
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%></title>
</head>
<frameset cols="110,*" border="0">
	<frame src="crdLeft.jsp<%= id != null ? "?id=" + id : "" %>" noresize scrolling="no" name="left">
	<frame src="crd.jsp<%= id != null ? "?id=" + id : "" 
			+ (scId != null ? "?sc_id=" + scId : "") %>" name="main">
</frameset>
</html>