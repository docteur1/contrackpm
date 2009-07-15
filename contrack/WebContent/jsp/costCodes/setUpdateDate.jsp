<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="accounting.Accounting, com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<head>
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
Database db = new Database();
db.dbInsert("update job set date_costs_updated = now() where job_id = " + attr.getJobId());
if (attr.hasAccounting()) {
	Accounting acc = AccountingUtils.getAccounting(session);
	String query = "select division, cost_code, sum(cost_to_complete) as est, code_description from job_cost_detail where job_id = " +
		attr.getJobId() + " group by division, cost_code";
	ResultSet rs = db.dbQuery(query);
	Code code = new Code();
	code.setJobNum(attr.getJobNum());
	int status;
	while (rs.next()) {
		code.setCostCode(rs.getString("cost_code"));
		code.setDivision(rs.getString("division"));
		code.setAmount(rs.getDouble("est"));
		code.setName(rs.getString("code_description"));
		acc.updateEstimate(code);

	}
	if (rs != null) rs.getStatement().close();
}
db.disconnect();
%>
<script>
	window.location = "codesTop.jsp";
	parent.parent.hideMessage();
</script>
</head>
</html>

