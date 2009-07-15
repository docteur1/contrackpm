<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<html>
<script language="javascript">
<%
String id = request.getParameter("id");
Database db = new Database();
String query = "select count(*) from contracts where company_id = "+ request.getParameter("id");
ResultSet rs = db.dbQuery(query);
String msg = "";
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " contracts\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from rfi where company_id = " + id;
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " RFIs\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from letter_contacts where company_id = " + id;
rs = db.dbQuery(query);
if (rs.next() && rs.getInt(1) != 0) msg += "-Has as many as " + rs.getString(1) + " Letters\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from contacts where company_id = " + id;
rs = db.dbQuery(query);
if (rs.next()  && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " contacts\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from transmittal where company_id = " + id;
rs = db.dbQuery(query);
if (rs.next()  && rs.getInt(1) != 0) msg += "-Has " + rs.getString(1) + " transmittals\\n";
if (rs != null) rs.getStatement().close();
query = "select count(*) from job_contacts where company_id = " + id;
rs = db.dbQuery(query);
if (rs.next()  && rs.getInt(1) != 0) msg += "-Is a contact on " + rs.getString(1) + " projects\\n";
if (rs != null) rs.getStatement().close();
if (msg.equals("")) {
	query = "delete from company where company_id = " + id;
	db.dbInsert(query);
	com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.COMPANY, id, session);
%>
	document.location = "reviewCompanies.jsp";
<%
} else {
%>
	window.alert("Unable to delete company\n----------------------\nDelete the following first:\n<%= msg %>");
	history.back();
<%
}
db.disconnect();
%>
</script>
</html>