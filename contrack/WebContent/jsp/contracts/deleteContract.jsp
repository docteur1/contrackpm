<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Subcontract, accounting.Result, accounting.Action" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="java.sql.ResultSet, java.util.EnumSet" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<script>
<%
if (!sec.ok(Name.SUBCONTRACTS, Permission.DELETE)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
String id = request.getParameter("id");
String msg = "";
Database db = new Database();
Subcontract sub = AccountingUtils.getSubcontract(Integer.parseInt(id));
String query = "select count(*) from change_request_detail where contract_id = " + id;
ResultSet rs = db.dbQuery(query);
if (rs.first() && rs.getInt(1) != 0) msg += "\\n-Has " + rs.getInt(1) + " change authorizations";
if (rs != null) rs.getStatement().close();
query = "select count(*) from submittals where contract_id = " + id;
rs = db.dbQuery(query);
if (rs.first() && rs.getInt(1) != 0) msg += "\\n-Has " + rs.getInt(1) + " submittals";
if (rs != null) rs.getStatement().close();
query = "select count(*) from pay_requests where contract_id = " + id;
rs = db.dbQuery(query);
if (rs.first() && rs.getInt(1) != 0) msg += "\\n-Has " + rs.getInt(1) + " pay requests";
if (rs != null) rs.getStatement().close();
rs = null;
if (msg.equals("")) {
	if (attr.hasAccounting()) {
		Result result = AccountingUtils.getAccounting(session).deleteSubcontact(sub);
		EnumSet<Action> es = EnumSet.of(Action.DELETED, Action.NOT_FOUND, Action.NO_ACTION);
		if (es.contains(result.getAction()))
			db.dbInsert("delete from contracts where contract_id = " + id);
		else msg = "\\n" + result.getMessage();
	} else db.dbInsert("delete from contracts where contract_id = " + id);
	com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.SUBCONTRACT, id, session);
}
if (!msg.equals("")) {
	msg = "Unable to delete contract\\n----------------------" + msg;
	out.print("window.alert(\"" + msg + "\")");
}
db.disconnect();
%>
	window.location.href = "reviewContracts.jsp";
</script>
