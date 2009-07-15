<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.DataUtils" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Verify" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script language="javascript">
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");

Verify v = new Verify();

Database db = new Database();
ResultSet rs = null;
String query = null;

String id = request.getParameter("id");


query = "select * from job_cost_detail where cost_code_id = " + id;
rs = db.dbQuery(query, true);

rs.first();
String t = request.getParameter("description");
if (v.blank(t)) v.msg("Description is required");
else rs.updateString("code_description", t);

if (request.getParameter("locked") == null) {
	t = request.getParameter("estimate");
	if (v.cur(t)) rs.updateString("estimate", DataUtils.decimal(t));
	else v.msg("Estimate is an invalid decimal number");
	
	t = request.getParameter("budget");
	if (v.cur(t)) rs.updateString("budget", DataUtils.decimal(t));
	else v.msg("Budget is an invalid decimal number");
}

t = request.getParameter("complete");
if (v.cur(t)) rs.updateString("cost_to_complete", DataUtils.decimal(t));
else v.msg("$ to Complete is an invalid decimal number");

t = request.getParameter("percent");
if (v.cur(t)) rs.updateString("percent_complete", DataUtils.decimal(t));
else v.msg("% Complete is an invalid decimal number");

t = request.getParameter("comment");
if (v.blank(t)) t = "";
rs.updateString("comment", t);


boolean error = false;
if (v.message.equals("")) {
	rs.updateRow();
	if (attr.hasAccounting()) {
		Code budget = new Code();
		budget.setJobNum(attr.getJobNum());
		budget.setName(request.getParameter("description"));
		budget.setDivision(rs.getString("division"));
		budget.setCostCode(rs.getString("cost_code"));
		budget.setPhaseCode(rs.getString("phase_code"));
		budget.setAmount(rs.getDouble("budget"));
		AccountingUtils.getAccounting(session).updateCode(budget);
	}
}
if (rs != null) rs.getStatement().close();
rs = null;

String ccid = id;

if (error) {
	db.disconnect();
%>
alert("Unable to save phase information\n-----------------------------------------\n<%= v.message %>");
history.back();
<%
} else {
	query = "select cost_code, phase_code, division from job_cost_detail where cost_code_id = " + ccid;
	rs = db.dbQuery(query);
	String cost_code = "0", phase_code = "0", division = "01";
	if (rs.next()) {
		cost_code = rs.getString("cost_code");
		phase_code = rs.getString("phase_code");
		division = rs.getString("division");
	}
	if (rs != null) rs.close();
	rs = null;
	if (request.getParameter("command") != null && !"".equals(request.getParameter("command"))) {
		boolean next = request.getParameter("command").equals("n");
		if (next) query = "select cost_code_id, division from job_cost_detail where ((cost_code = '" 
			+ cost_code + "' and phase_code > '" + phase_code + "' and division = '" + division + "'"
			+ ") or (division = '" + division + "' and costorder(cost_code) > costorder('" + cost_code + "')) "
			+ "or (costorder(division) > costorder('" + division + "'))) and job_id = " + attr.getJobId() 
			+ " order by costorder(division), costorder(cost_code), phase_code limit 1";
		else query = "select cost_code_id, division from job_cost_detail where ((cost_code = '" 
			+ cost_code + "' and phase_code < '" + phase_code + "' and division = '" + division + "'"
			+ ") or (division = '" + division + "' and costorder(cost_code) < costorder('" + cost_code + "')) "
			+ "or (costorder(division) < costorder('" + division + "'))) and job_id = " + attr.getJobId() 
			+ " order by costorder(division) desc, costorder(cost_code) desc, phase_code desc limit 1";
		rs = db.dbQuery(query);
		if (rs.next()) {
			t = rs.getString("cost_code_id");
			division = rs.getString("division");
		}
		
		if (!next) ccid = t;
	} else {
		t = id;
		ccid = id;
	}
	if (rs != null) rs.close();
	rs = null;
	db.disconnect();
%>
	parent.main.location.href= "codesMain.jsp?div=<%= division %>&id=<%= ccid %>";
	parent.footer.location.reload();
	parent.header.location = "codesTop.jsp?div=<%= division %>";
	window.location = "editCode.jsp?id=<%= t %>&saved=true";
<%
}
%>
</script>
