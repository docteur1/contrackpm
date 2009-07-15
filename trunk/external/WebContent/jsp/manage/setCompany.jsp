<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:useBean id="list" scope="session" class="com.sinkluge.list.List" />
<%
db.contract_id = 0;
String id = request.getParameter("company_id");
String query = "select distinct job.job_id, job_name from job "
	+ "join job_contacts using(job_id) where company_id = "
	+ id + " and job.active = 'y' order by job_num desc";
db.connect();
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
list.clear();
while (rs.next()) list.addJob(rs.getInt("job_id"), rs.getString("job_name"));
if (rs != null) rs.close();
query = "select contract_id, job.job_id, job_name, code_description, site_id from contracts join job using(job_id) "
	+ "join job_cost_detail using(cost_code_id) where job.active = 'y' "
	+ "and company_id = " + id + " order by job.job_num desc";
rs = stmt.executeQuery(query);
while (rs.next()) {
	if (rs.isFirst()) {
		db.contract_id = rs.getInt(1);
		db.job_id = rs.getInt(2);
		db.job_name = rs.getString(3);
		db.site_id = rs.getInt(5);
	}
	list.addContract(rs.getInt("job_id"), rs.getString("job_name"), rs.getInt("contract_id"), rs.getString("code_description"));
}
if (rs != null) rs.close();
rs = null;
query = "select contact_id, name, company_name from contacts join company using(company_id) where company_id = " + id + " and email = '" + db.email + "'";
rs = stmt.executeQuery(query);
if (rs.first()) {
	db.contact_id = rs.getInt(1);
	db.contact_name = rs.getString(2);
}
if (list.isEmpty()) {
	db.job_id = 0;
	db.contract_id = 0;
	db.site_id = 0;
}
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.load();
db.disconnect();
db.company_id = Integer.parseInt(id);
response.sendRedirect(request.getContextPath() + request.getParameter("requesting_path"));
%>