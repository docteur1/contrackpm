<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.database.Database" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<script>
<%
String file_id = request.getParameter("file_id");
if (file_id != null) {
	Database db = new Database();
	db.dbInsert("delete from files where file_id = " + file_id);
	db.disconnect();
%>
	if (window.opener) window.opener.location.reload();
	window.location="upload.jsp?id=<%= request.getParameter("id") %>&type=<%= request.getParameter("type") %>";
<%
}
%>
</script>
</html>