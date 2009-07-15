<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="com.sinkluge.security.Security, java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<html>
<head>
<script src="../utils/accountajax.js"></script>
<script src="../utils/jsonrpc.js"></script>
<script>
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
	response.sendRedirect("../accesDenied.html");
	return;
}
String contractID = request.getParameter("id");
%>
	function done(msg) {
		window.location = "modifyContract.jsp?id=<%= contractID %>&msg=" + (msg == null ? "Saved" : escape(msg));
	}
<%
JSONRPCBridge.registerClass("accounting", com.sinkluge.JSON.AccountingJSON.class);
String voucherID = null;
Database db = new Database();
ResultSet rs = db.dbQuery("select account_id from pay_requests where contract_id = " + contractID
		+ " and account_id is not null and account_id != 0 limit 1");
if (rs.next()) voucherID = rs.getString(1);
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
var companyName = "<%= AccountingUtils.getCompanyNameByContract(Integer.parseInt(contractID)) %>";
var contractID = <%= contractID %>;
try {
	var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
<%
if (voucherID != null) {
%>
	var nextFunction = byContract;
	jsonrpc.accounting.getCompanyByVoucher(cb, "<%= voucherID %>");
<%
} else {
%>
	var nextFunction = byOldContract;
	jsonrpc.accounting.getCompanyByContract(cb, contractID);
<%
}
%>
} catch (e) {
	alert(e);
}
</script>
</head>
<body>
<img style="position: absolute; left: 100px; top: 100px;" src="../../images/loading_circle.gif"></img>
</body>
</html>