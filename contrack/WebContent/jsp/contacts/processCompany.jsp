<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.sql.PreparedStatement, com.sinkluge.database.Database" %>
<script>
<%
String safety = request.getParameter("safety")==null?"n":"y";

String query = "insert ignore into company (company_name, description, "
		+ "website, federal_id, license_number, safety_manual, "
		+ "address, city, state, zip, phone, fax) values (?,?,?,?,?,?,?,?,?,?,?,?)";
Database db = new Database();
PreparedStatement ps = db.preStmt(query);
ps.setString(1, request.getParameter("name"));
ps.setString(2, request.getParameter("description"));
ps.setString(3, request.getParameter("website"));
ps.setString(4, request.getParameter("federal_id"));
ps.setString(5, request.getParameter("licenseno"));
ps.setString(6, safety);
ps.setString(7, request.getParameter("address"));
ps.setString(8, request.getParameter("city"));
ps.setString(9, request.getParameter("state"));
ps.setString(10, request.getParameter("zip"));
ps.setString(11, request.getParameter("phone"));
ps.setString(12, request.getParameter("fax"));
int count = ps.executeUpdate();
if (count != 0 ) {
	ResultSet rs = ps.getGeneratedKeys();
	String id = null;
	if (rs.next()) id = rs.getString(1);
	if (rs != null) rs.close();
	if (ps != null) ps.close();
	db.disconnect();
	if (id != null) {
		com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.COMPANY, id, session);
		response.sendRedirect("modifyCompany.jsp?id=" + id);
	}
	else response.sendRedirect("reviewCompanies.jsp");
} else {
	if (ps != null) ps.close();
	db.disconnect();
%>
	window.alert("A company named \"<%= request.getParameter("name") %>\" already exists!");
	history.back();
<%
}
%>
</script>