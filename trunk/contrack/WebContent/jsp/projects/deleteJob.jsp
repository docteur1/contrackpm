<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet" %>
<%@page session="true" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<script>
<%
String msg = "";
String query = "select count(*) from job_cost_detail where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " budget items\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from contracts where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " contracts\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from change_orders where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " change orders\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from submittals where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " submittals\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from rfi where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " RFIs\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from transmittal where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " transmittals\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from letters where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " letters\\n";
if (rs != null) rs.getStatement().close();
rs = null;
if (msg.equals("")) {
	query = "delete from job where job_id = " + attr.getJobId();
	db.dbInsert(query);
	query = "delete from user_jobs where job_id = " + attr.getJobId();
	db.dbInsert(query);
	query = "delete from job_permissions where job_id = " + attr.getJobId();
	db.dbInsert(query);
	query = "delete from job_contacts where job_id = " + attr.getJobId();
	db.dbInsert(query);
	query = "delete from job_divisions where job_id = " + attr.getJobId();
	db.dbInsert(query);
	query = "delete from files where type = 'PJ' and id = '" + attr.getJobId() + "'";
	db.dbInsert(query);
%>
	window.alert("Project successfully deleted.");
	window.parent.logout = false;
	window.parent.location = "../";
<%
} else {
%>
	window.alert("Unable to delete project\n-------------------\n<%= msg %>");
	window.location = "reviewJobInfo.jsp";
<%
}
db.disconnect();
%>
</script>
</html>