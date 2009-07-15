<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Cost, accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.util.List" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.database.Database" %>
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Reconcile</title>
<script>
<%
// Get the summed costs and update the table...
String id = request.getParameter("id");
Code code = AccountingUtils.getCode(id);
List<Cost> costs = AccountingUtils.getAccounting(session).getCosts(code);
Cost cost;
double amount = 0, hours = 0;
if (costs != null) {
	for (Iterator<Cost> i = costs.iterator(); i.hasNext(); ) {
		cost = i.next();
		amount += cost.getCost();
		hours += cost.getHours();
	}
}
Database db = new Database();
db.dbInsert("update job_cost_detail set pm_cost_to_date = " + amount + ", pm_hours_to_date = " + hours 
	+ " where cost_code_id = " + id);
db.disconnect();
%>
	if (window.opener) window.opener.location.reload();
	window.location = "<%= request.getParameter("r") != null ? "voucherDetail" : "phaseDetail" %>.jsp?id=<%= id %>";
</script>
</head>
</html>