<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.DataUtils" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<script>
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String query = "select * from job_cost_detail where cost_code = '" + request.getParameter("cost_code") + "' "
	+ "and phase_code = '" + request.getParameter("phase") + "' and division = '" + request.getParameter("div") + "' "
	+ "and job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
if (rs.first()) {
%>
	window.alert("ERROR!\n--------------------------------------\nA budget line for <%= request.getParameter("div") + " " +
			request.getParameter("cost_code") + "-" + request.getParameter("phase") + ": " + rs.getString("code_description") %>\nalready exists!");
	history.back();
<%
	if (rs != null) rs.getStatement().close();
	rs = null;
	db.disconnect();
} else {
	rs.moveToInsertRow();
	rs.updateInt("job_id", attr.getJobId());
	rs.updateString("cost_code", request.getParameter("cost_code"));
	rs.updateString("code_description", request.getParameter("description"));
	rs.updateString("phase_code", request.getParameter("phase").toUpperCase());
	rs.updateString("division", request.getParameter("div"));
	rs.updateString("estimate", DataUtils.decimal(request.getParameter("estimate")));
	rs.updateString("budget", DataUtils.decimal(request.getParameter("budget")));
	rs.updateBoolean("locked", request.getParameter("lock") != null);
	rs.updateString("percent_complete", DataUtils.decimal(request.getParameter("percent")));
	rs.updateString("cost_to_complete", DataUtils.decimal(request.getParameter("complete")));
	rs.insertRow();
	String id = null;
	if (rs.last()) {
		id = rs.getString("cost_code_id");
		Code budget = new Code();
		if (attr.hasAccounting()) {
			budget.setName(request.getParameter("description"));
			budget.setJobNum(attr.getJobNum());
			budget.setDivision(request.getParameter("div"));
			budget.setCostCode(request.getParameter("cost_code"));
			budget.setPhaseCode(request.getParameter("phase").toUpperCase());
			budget.setAmount(Double.parseDouble(request.getParameter("budget")));
			AccountingUtils.getAccounting(session).updateCode(budget);
		}
	}
	if (rs != null) rs.getStatement().close();
	rs = null;
	db.disconnect();
	if (id != null) {
%>
	parent.location = "codes.jsp?id=<%= id %>&add=t&div=<%= request.getParameter("div") %>";
<%
	} else {
%>
	parent.location = "codes.jsp?div=<%= request.getParameter("div") %>";
<%
	}
}
%>
</script>
</html>