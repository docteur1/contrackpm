<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="com.sinkluge.UserData, com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<script>
<%
UserData user = UserData.getInstance(in, attr.getUserId());
user.put("title", request.getParameter("title"));
user.put("email", request.getParameter("email"));
user.put("address", request.getParameter("address"));
user.put("city", request.getParameter("city"));
user.put("state", request.getParameter("state"));
user.put("zip", request.getParameter("zip"));
user.put("phone", request.getParameter("phone"));
user.put("ext", request.getParameter("ext"));
user.put("mobile", request.getParameter("mobile"));
user.put("fax", request.getParameter("fax"));
user.put("radio", request.getParameter("radio"));
String query = "update job_team set email = '" + request.getParameter("email") + "', mobile = '" 
	+ request.getParameter("mobile") + "' where user_id = " + attr.getUserId();
Database db = new Database();
db.dbInsert(query);
query = "update users set font_size = " + request.getParameter("font_size") + ", email ='"
	+ request.getParameter("email") + "' where id = " + attr.getUserId();
db.dbInsert(query);
user.setData(in);
attr.setEmail(request.getParameter("email"));
attr.setFontSize(Integer.parseInt(request.getParameter("font_size"))); 
user.close();
db.disconnect();
%>
	parent.logout = false;
	parent.location = "../?loc=admin/personalAdmin.jsp?saved=true";
</script>
</html>