<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script language="javascript">
<%
if (!sec.ok(Security.ACCOUNT, Security.DELETE)) response.sendRedirect("../accessDenied.html");

String id = request.getParameter("id");
String query = "select count(*) from change_request_detail where cost_code_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
int cos = 1;
if (rs.next()) cos = rs.getInt(1);
if (rs != null) rs.getStatement().close();
rs = null;
String division = "01";
Code budget = AccountingUtils.getCode(id);
if (budget != null) division = budget.getDivision();
query = "select contract_id from contracts where cost_code_id = " + id;
rs = db.dbQuery(query);
if (rs.next()) {
	if (rs != null) rs.close();
	rs = null;
	db.disconnect();
%>
	alert("Unable to delete phase code!\n--------------------------------\nContract exists.\n\nIf you must delete this code, first\nchange the associated contact.");
	document.location = "editCode.jsp?id=<%= id %>";
<%
} else if (cos != 0) {
	if (rs != null) rs.close();
	rs = null;
	db.disconnect();
%>
	alert("Unable to delete phase code!\n--------------------------------\nAssociated with <%= cos %> change requests details(s).\n\nIf you must delete this code, first\nchange any associated change request detail(s).");
	document.location = "editCode.jsp?id=<%= id %>";
<%
}else {
	if (rs != null) rs.close();
	rs = null;
	query = "delete from job_cost_detail where cost_code_id = " + id;
	int count = db.dbInsert(query);
	db.disconnect();
	if (count == 1) {
		if (budget != null && attr.hasAccounting()) AccountingUtils.getAccounting(session).deleteCode(budget); 
%>
	parent.document.location = "codes.jsp?div=<%= division %>";
<%
	} else {
%>
	alert("Unable to delete phase code!\n----------------------------------\nContact an administrator.");
	document.location = "editCode.jsp?id=<%= id %>";
<%
	}
}
%>
</script>

