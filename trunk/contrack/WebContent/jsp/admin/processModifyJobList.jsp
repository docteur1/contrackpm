<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
String query = "select job_id from job";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String jobId;
query = "delete from user_jobs where user_id = " + attr.getUserId();
db.dbInsert(query);
while (rs.next()) {
	jobId = rs.getString("job_id");
	if (request.getParameter(jobId) != null) {
		query = "insert into user_jobs (user_id, job_id) values (" + attr.getUserId() + 
			", " + jobId + ")";
		db.dbInsert(query); 
	}
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
	<script language="javascript">
		parent.reload = false;
		parent.loadProjectList(false);
		window.location="modifyJobList.jsp?save=true&path=<%= request.getParameter("path") %>";
	</script>
