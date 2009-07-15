<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.DELETE)) {
	response.sendRedirect("../../accessDenied.jsp");
	return;
}
String id = request.getParameter("id");
String query = "select contract_id, final, pay_requests.opr_id from "
	+ "owner_pay_requests, pay_requests where pay_requests.opr_id = "
	+ "owner_pay_requests.opr_id and pr_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String contractId = null;
boolean fp = false;
String oprId = null;
if (rs.first()) {
	contractId = rs.getString(1);
	fp = rs.getBoolean(2);
	oprId = rs.getString(3);
}
if (rs != null) rs.getStatement().close();
rs = null;
String retId = null, retOprId = null;
if (fp) {
	query = "select pr_id, opr_id from pay_requests as pr join owner_pay_requests as opr "
		+ "using(opr_id) where contract_id = " + contractId + " and period = "
		+ "'Retention' and job_id = " + attr.getJobId();
	rs = db.dbQuery(query);
	if (rs.first()) {
		retId = rs.getString(1);
		retOprId = rs.getString(2);
	}
	if (rs != null) rs.getStatement().close();
	rs = null;
}
query = "delete from pay_requests where pr_id = " + request.getParameter("id");
db.dbInsert(query);
com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.PR, request.getParameter("id"), session);
query = "delete from files where type = 'PR' and id = " + request.getParameter("id");
db.dbInsert(query);
if (retId != null) {
	query = "delete from pay_requests where pr_id = " + retId;
	db.dbInsert(query);
	com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.PR, retId, session);
	query = "delete from files where type = 'PR' and id = " + retId;
	db.dbInsert(query);
	query = "select count(*) from pay_requests where opr_id = " + retOprId;
	rs = db.dbQuery(query);
	if (rs.first() && rs.getInt(1) == 0) {
		query = "delete from owner_pay_requests where opr_id = " + retOprId;
		db.dbInsert(query);
		com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.OPR,retOprId, session);
	}
	if (rs != null) rs.getStatement().close();
	rs = null;
}
db.disconnect();
if (request.getParameter("sub") == null)
	response.sendRedirect("reviewPayRequests.jsp?id="  + oprId);
else response.sendRedirect("subPayRequests.jsp?contract_id="  + contractId);
%>
