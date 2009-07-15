<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="com.sinkluge.security.Security, java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<html>
<head>
<link href="../stylesheets/v2.css" rel="stylesheet" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/accountajax.js"></script>
<script src="../utils/jsonrpc.js"></script>
<script>
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
	response.sendRedirect("../accesDenied.html");
	return;
}
String companyID = request.getParameter("company_id");
String contactID = request.getParameter("contact_id");
%>
	function done(msg) {
		window.location = "newContract3.jsp?company_id=<%= companyID + (contactID != null ? 
				"&contact_id=" + contactID : "") %>" + (msg != null ? "&msg=" + escape(msg) : "");
	}
<%
JSONRPCBridge.registerClass("accounting", com.sinkluge.JSON.AccountingJSON.class);
Database db = new Database();
ResultSet rs = db.dbQuery("select contract_id from contracts where company_id = " + companyID
		+ " order by contract_id desc limit 1");
if (rs.first()) {
%>
	var companyName = "<%= AccountingUtils.getCompanyNameByContract(rs.getInt(1)) %>";
	var contractID = <%= rs.getInt(1) %>;
	try {
		var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
		var nextFunction = byName;
		jsonrpc.accounting.getCompanyByContract(cb, contractID);
	} catch (e) {
		alert(e);
	}
<%		
} else out.println("done();");
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</script>
</head>
<body>
<img style="position: absolute; left: 100px; top: 100px;" src="../../images/loading_circle.gif" />
<div style="position: relative; left: 100px;">Please wait while Contrack searches accounting database...</div>
</body>
</html>