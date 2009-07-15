<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="accounting.Accounting, com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Cost, accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<body>
<%
int totalUpdated = 0, totalInserted = 0, updated;
String query = "update job_cost_detail set pm_cost_to_date = 0, pm_hours_to_date = 0 where job_id = " + attr.getJobId();
Database db = new Database();
db.dbInsert(query);
ResultSet rs;
Cost data;
Code code;
Accounting acc = AccountingUtils.getAccounting(session);
for (Iterator<Cost> i = acc.getSummedCosts(attr.getJobNum()).iterator(); 
		i.hasNext(); ) {
	data = i.next();
	code = data.getCode();
	query = "select * from job_cost_detail where job_id = " + attr.getJobId() +
		" and cost_code = '" + code.getCostCode() + "' and phase_code = '" + code.getPhaseCode() + "'" +
		" and division = '" + code.getDivision() + "'";
	rs = db.dbQuery(query, true);
	if (rs.first()) {
		rs.updateDouble("pm_hours_to_date", data.getHours());
		rs.updateDouble("pm_cost_to_date", data.getCost());
		rs.updateRow();
		totalUpdated++;
	} else {
		rs.moveToInsertRow();
		// Load the code to get the name.
		code = acc.getCode(code);
		rs.updateDouble("pm_hours_to_date", data.getHours());
		rs.updateDouble("pm_cost_to_date", data.getCost());
		rs.updateString("cost_code", code.getCostCode());
		rs.updateString("phase_code", code.getPhaseCode());
		rs.updateString("division", code.getDivision());
		rs.updateInt("job_id", attr.getJobId());
		rs.updateString("code_description", code.getName());
		rs.updateString("comment", "Created by import");
		rs.insertRow();
		totalInserted++;
	}
	if (rs != null) rs.getStatement().close();
	rs = null;
}
db.disconnect();
%>
<script>
parent.showMessage(
		"Lines updated: <%= totalUpdated %><br/>" +
		"Lines created: <%= totalInserted %> (previously missing in Contrack)",
		"Costs to Data Updated");
window.location = "codes.jsp";
</script>
</body>
</html>