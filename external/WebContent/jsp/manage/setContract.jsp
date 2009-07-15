<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
String id = request.getParameter("id");
String query;
if (id.indexOf("c") == 0)  {
	db.contract_id = Integer.parseInt(id.substring(1));
	query = "select job.job_id, job_name, site_id from contracts join job using(job_id) where "
		+ "contract_id = " + db.contract_id;
} else {
	db.contract_id = 0;
	query = "select job.job_id, job_name, site_id from job where "
		+ "job_id = " + id.substring(1);
}
db.connect();
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
if (rs.next()) {
	db.job_id = rs.getInt("job_id");
	db.job_name = rs.getString("job_name");
	db.site_id = rs.getInt("site_id");
}
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.load();
db.disconnect();
response.sendRedirect(request.getContextPath() + request.getParameter("requesting_path"));
%>