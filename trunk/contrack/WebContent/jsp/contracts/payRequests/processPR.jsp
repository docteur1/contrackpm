<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.sql.ResultSet, java.util.Date, java.sql.Timestamp" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script language="javascript">
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
	response.sendRedirect("../,,/accessDenied.html");
	return;
}
int id = 0;
String query = "select pr_id from pay_requests where opr_id = " + request.getParameter("opr_id")
	+ " and contract_id = " + request.getParameter("contract_id");
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (!rs.isBeforeFirst()) {
	if (rs != null) rs.getStatement().close();
	query = "select * from pay_requests";
	rs = db.dbQuery(query, true);
	rs.moveToInsertRow();
	rs.updateString("opr_id", request.getParameter("opr_id"));
	rs.updateString("contract_id", request.getParameter("contract_id"));
	rs.updateString("lien_waiver", request.getParameter("lien_waiver"));
	rs.updateString("invoice_num", request.getParameter("invoice_num"));
	rs.updateString("co", request.getParameter("co"));
	rs.updateString("value_of_work", request.getParameter("vwctd"));
	rs.updateString("adj_value_of_work", request.getParameter("vwctd"));
	rs.updateString("previous_billings", request.getParameter("ptd"));
	rs.updateString("adj_previous_billings", request.getParameter("ptd"));
	rs.updateString("retention", request.getParameter("ret"));
	rs.updateString("adj_retention", request.getParameter("ret"));
	rs.updateDate("date_created", new java.sql.Date(new Date().getTime()));
	rs.updateString("request_num", request.getParameter("request_num"));
	rs.updateString("internal_comments", request.getParameter("internal_comments"));
	rs.updateString("external_comments", request.getParameter("external_comments"));
	rs.updateBoolean("final", request.getParameter("final") != null);
	rs.insertRow();
	if (rs.last()) id = rs.getInt("pr_id");
	if (id != 0) com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.PR, 
			Integer.toString(id), session);
	if (request.getParameter("final") != null) {
		// Create Retention
		rs.moveToInsertRow();
		query = "select * from owner_pay_requests where period = 'Retention' and"
			+ " job_id = " + attr.getJobId();
		ResultSet retId = db.dbQuery(query, true);
		if (!retId.isBeforeFirst()) {
			retId.moveToInsertRow();
			retId.updateString("period", "Retention");
			retId.updateInt("job_id", attr.getJobId());
			retId.insertRow();
			retId.last();
		} else retId.first();
		rs.updateString("opr_id", retId.getString("opr_id"));
		rs.updateString("contract_id", request.getParameter("contract_id"));
		rs.updateString("lien_waiver", request.getParameter("lien_waiver"));
		rs.updateDate("date_created", new java.sql.Date(new Date().getTime()));
		rs.updateInt("request_num", Integer.parseInt(request.getParameter("request_num")) + 1);
		rs.insertRow();
		if (retId != null) retId.getStatement().close();
		retId = null;
	}
} else {
%>
	window.alert("Pay Requests for this contract already\nexists in this pay period");
	window.parent.close();
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
parent.opener.location.reload();
parent.location = "modifyPRFrameset.jsp?id=<%= id %>";
</script>