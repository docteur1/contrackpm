<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="java.sql.ResultSet, java.util.Date, java.sql.Timestamp" %>
<%@page import="com.sinkluge.utilities.DateUtils, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<script src="../../utils/accountajax.js"></script>
<script src="../../utils/jsonrpc.js"></script>
<script>
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
	response.sendRedirect("../,,/accessDenied.html");
	return;
}
String id = request.getParameter("pr_id");
%>
	function done() {
		window.parent.opener.location.reload();
		window.location = "modifyPR.jsp?pr_id=<%= id %>&saved=true";
	}
<%
String query = "select * from pay_requests where pr_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
if (rs.first()) {
	String t;
	if (sec.ok(Security.APPROVE_PAYMENT, Security.WRITE)) {
		rs.updateDate("date_approved", DateUtils.getSQLShort(request.getParameter("date_approved")));
	}
	if (sec.ok(Security.PENDING_CO, Security.WRITE)) {
		rs.updateDate("date_paid", DateUtils.getSQLShort(request.getParameter("date_paid")));
		t = request.getParameter("ref_num");
		if (t == null || t.equals("")) t = null;
		rs.updateString("ref_num", t);
		rs.updateString("paid", request.getParameter("paid"));
	}
	t = request.getParameter("account_id");
	if (t == null || t.equals("")) t = null;
	rs.updateString("account_id", t);
	rs.updateString("lien_waiver", request.getParameter("lien_waiver"));
	rs.updateString("invoice_num", request.getParameter("invoice_num"));
	rs.updateString("value_of_work", request.getParameter("vwctd"));
	rs.updateString("adj_value_of_work", request.getParameter("adjvwctd"));
	rs.updateString("previous_billings", request.getParameter("ptd"));
	rs.updateString("adj_previous_billings", request.getParameter("adjptd"));
	rs.updateString("retention", request.getParameter("ret"));
	rs.updateString("adj_retention", request.getParameter("adjret"));
	rs.updateString("internal_comments", request.getParameter("internal_comments"));
	rs.updateString("external_comments", request.getParameter("external_comments"));
	rs.updateRow();
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PR, 
		id, session);
	int contractID = rs.getInt("contract_id");
	if (rs.getInt("account_id") != 0 && AccountingUtils.companyNeedsIDByContract(contractID)) {
		JSONRPCBridge.registerClass("accounting", com.sinkluge.JSON.AccountingJSON.class);
		
%>
	var companyName = "<%= AccountingUtils.getCompanyNameByContract(contractID) %>";
	var contractID = <%= contractID %>;
	try {
		var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
		var nextFunction = byContract;
		jsonrpc.accounting.getCompanyByVoucher(cb, "<%= rs.getString("account_id") %>");
	} catch (e) {
		alert(e);
	}
<%		
	} else out.println("done();");
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</script>