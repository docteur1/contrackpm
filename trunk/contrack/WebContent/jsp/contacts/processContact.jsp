<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.SQLException, java.sql.ResultSet" %>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.database.Database" %>
<script>
<%
String insert = "insert into contacts (name, title, company_id, address, city, state, zip, phone, extension, "
		+ "radio_num, pager, fax, email, mobile_phone) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
Database db = new Database();
PreparedStatement ps = db.preStmt(insert);
ps.setString(1,request.getParameter("name"));
ps.setString(2,request.getParameter("title"));
ps.setString(3,request.getParameter("id"));
ps.setString(4,request.getParameter("address"));
ps.setString(5,request.getParameter("city"));
ps.setString(6,request.getParameter("state"));
ps.setString(7,request.getParameter("zip"));
ps.setString(8,request.getParameter("phone"));
ps.setString(9,request.getParameter("extension"));
ps.setString(10,request.getParameter("radio_num"));
ps.setString(11,request.getParameter("pager"));
ps.setString(12,request.getParameter("fax"));
ps.setString(13, request.getParameter("email"));
ps.setString(14,request.getParameter("mobile_phone"));
try { 
	ps.executeUpdate();
	ResultSet rs = ps.getGeneratedKeys();
	String id = null;
	if (rs.first()) id = rs.getString(1);
	rs.getStatement().close();
	if (id != null) com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.CONTACT, id, session);
%>
	opener.location.reload();
	window.close();
<%
} catch (SQLException e) {
	System.err.println(e.getMessage());
%>
	window.alert("A contact named \"<%= request.getParameter("name") %>\" already exists for this company!");
	history.back();
<%
} finally {
	if (ps != null) ps.close();
	ps = null;
	db.disconnect();
}
%>
</script>

