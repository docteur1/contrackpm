<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.Statement, java.sql.ResultSet, java.sql.PreparedStatement"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="list" scope="session" class="com.sinkluge.list.List" />
<%
in.loadProperties();
ResultSet rs;
// How does the path look
if (in.path == null || !application.getRealPath("").equals(in.path)) {
	in.path = application.getRealPath("");
}
String userName = request.getRemoteUser();
db.email = userName;
String query = "select company_id, contact_id, name, company_name, has_temp_password, font_size from contact_users join contacts "
	+ "using(email) join company using(company_id) where contact_users.email = '" + userName 
	+ "' order by company_name";
db.connect();
Statement stmt = db.getStatement();
rs = stmt.executeQuery(query);
boolean has_temp_password = false;
if (rs.first()) {
	db.company_id = rs.getInt("company_id");
	db.contact_id = rs.getInt("contact_id");
	db.contact_name = rs.getString("name");
	db.company_name = rs.getString("company_name");
	has_temp_password = rs.getBoolean("has_temp_password");
	db.font_size = rs.getInt("font_size");
	PreparedStatement ps = db.preStmt("insert ignore into ext_sessions (id, name, host, email, agent) values (?, ?, ?, ?, ?)");
	ps.setString(1, session.getId());
	ps.setString(2, db.contact_name);
	ps.setString(3, request.getRemoteHost());
	ps.setString(4, request.getRemoteUser());
	ps.setString(5, request.getHeader("user-agent"));
	ps.executeUpdate();
	ps.close();
	ps = null;
}
if (rs != null) rs.close();
query = "select distinct job.job_id, job_name, site_id from job "
	+ "join job_contacts using(job_id) where company_id = "
	+ db.company_id + " and job.active = 'y' order by job_num desc";
rs = stmt.executeQuery(query);
while (rs.next()) {
	if (rs.isFirst()) {
		db.job_id = rs.getInt("job_id");
		db.job_name = rs.getString("job_name");
		db.site_id = rs.getInt("site_id");
	}
	list.addJob(rs.getInt("job_id"), rs.getString("job_name"));
}
if (rs != null) rs.close();
query = "select contract_id, job.job_id, job_name, code_description, site_id from contracts join job using(job_id) "
	+ "join job_cost_detail using(cost_code_id) where job.active = 'y' "
	+ "and company_id = " + db.company_id + " order by job.job_num desc";
rs = stmt.executeQuery(query);
while (rs.next()) {
	if (rs.isFirst()) {
		db.contract_id = rs.getInt(1);
		db.job_id = rs.getInt(2);
		db.job_name = rs.getString(3);
		db.site_id = rs.getInt(5);
	}
	list.addContract(rs.getInt(2), rs.getString(3), rs.getInt(1), rs.getString(4));
}
if (list.isEmpty()) {
	db.job_id = 0;
	db.contract_id = 0;
	db.site_id = 0;
}
db.load();
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.disconnect();
Cookie user_name = new Cookie("EPEXTUSER",userName);
user_name.setMaxAge(60*60*24*365);
user_name.setPath("/");
response.addCookie(user_name);
if (!has_temp_password) response.sendRedirect("manage/index.jsp");
else response.sendRedirect("user/changePasswordFirst.jsp");
%>