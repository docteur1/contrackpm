<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.DataUtils" %>
<%@page import="accounting.Accounting, com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Verify" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String query = "select * from cost_codes";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String code = null, phase = null, division = null;
query = "select * from job_cost_detail where cost_code_id = 0";
ResultSet update = db.dbQuery(query, true);
Accounting acc = null;
Code budget = null;
String value;
Double num;
while (rs.next()) {
	if (request.getParameter("c" + rs.getString("code_id")) != null) {
		code = rs.getString("cost_code");
		phase = rs.getString("cost_type");
		division = rs.getString("division");
		update.moveToInsertRow();
		update.updateInt("job_id", attr.getJobId());
		update.updateString("cost_code", code);
		update.updateString("phase_code", phase);
		update.updateString("division", division);
		update.updateString("code_description", rs.getString("description"));
		value = request.getParameter("t" + rs.getString("code_id"));
		if (value != null) value = value.replaceAll(",", "");
		try {
			num = Double.parseDouble(value);
		} catch (NumberFormatException e) {
			num = 0d;
		}
		update.updateDouble("budget", num);
		update.updateDouble("estimate", num);
		update.insertRow();
		if (update.last()) {
			if (acc == null) acc = AccountingUtils.getAccounting(session);
			budget = new Code();
			budget.setName(update.getString("code_description"));
			budget.setDivision(division);
			budget.setCostCode(code);
			budget.setPhaseCode(phase);
			budget.setJobNum(attr.getJobNum());
			budget.setAmount(num);
			acc.updateCode(budget);
		}
	}
}
if (update != null) update.getStatement().close();
update = null;
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
response.sendRedirect("codes.jsp");
%>
