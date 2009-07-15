<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<jsp:useBean id="db" class="com.sinkluge.database.Database" />
<script>
<%
String msg = "";
String id = request.getParameter("id");
String query = "select count(*) from letter_contacts where contact_id = " + id;
db.connect();
ResultSet rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg = "-Has as many as " + rs.getString(1) + " letters\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from job_contacts where contact_id = " + id;
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Is a job contact on " + rs.getString(1) + " jobs\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from contracts where contact_id = " + id;
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " contracts\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from rfi where contact_id = " + id;
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " RFIs\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from transmittal where contact_id = " + id;
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " Transmittals\\n";
if (rs != null) rs.getStatement().close();
if (msg.equals("")) {
	query = "select email from contacts where contact_id = " + id;
	String email = null;
	rs = db.dbQuery(query);
	if (rs.next()) email = rs.getString(1);
	if (rs != null) rs.getStatement().close();
	query = "delete from contacts where contact_id = " + id;
	if (db.dbInsert(query) != 0 && email != null && !email.equals("")) {
		com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.CONTACT, id, session);
		query = "select contact_id from contacts where email = '" + email + "'";
		rs = db.dbQuery(query);
		if (!rs.next()) {
			query = "delete from contact_users where email = '" + email + "'";
			db.dbInsert(query);
			query = "delete from contact_roles where email = '" + email + "'";
			db.dbInsert(query);
		}
		if (rs != null) rs.getStatement().close();
	}
	db.disconnect();
	response.sendRedirect("modifyCompany.jsp?id=" + request.getParameter("company_id"));
} else {
	db.disconnect();
%>
	alert("Unable to delete contact\n------------------------------\n<%= msg %>");
	window.location = "modifyCompany.jsp?id=<%= request.getParameter("company_id") %>";
<%
}
%>
</script>
