<%@ page language="java" contentType="text/plain; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("id");
String query = null;
Database db = new Database();
if (id != null) {
	if (request.getParameter("unlock") != null) {
		if (!sec.ok(Security.UNLOCK_BUDGET, Security.WRITE)) response.sendRedirect("../accessDenied.html");
		query = "update job_cost_detail set locked = 0 where cost_code_id = " + id;
	} else query = "update job_cost_detail set locked = 1 where cost_code_id = " + id;
	db.dbInsert(query);
	db.disconnect();
	response.sendRedirect("editCode.jsp?id=" + id);
} else {
	id = Integer.toString(attr.getJobId());
	if (request.getParameter("unlock") != null) {
		if (!sec.ok(Security.UNLOCK_BUDGET, Security.WRITE)) response.sendRedirect("../accessDenied.html");
		query = "update job_cost_detail set locked = 0 where job_id = " + id;
	} else query = "update job_cost_detail set locked = 1 where job_id = " + id;
	db.dbInsert(query);
	db.disconnect();
	response.sendRedirect("codes.jsp");
}
%>