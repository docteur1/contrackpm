<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, accounting.Accounting" %>
<%@page import="accounting.Cost, accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.SimpleMailer" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
if (request.getParameter("data") == null) {
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" media="all" >
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script language="javascript" src="../utils/verify.js"></script>
<script language="javascript" src="../utils/spell.js"></script>
<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
<script language="javascript">
	function sendRequest(frm) {
		frm.data.value = document.getElementById("data").innerHTML;
		frm.action = "jobCostInquiry.jsp";
		frm.method = "POST";
		if (checkForm(frm)) frm.submit();
	}
</script>
<title>Job Cost Inquiry</title>
</head>
<body>
<font size="+1">Job Cost Inquiry</font><hr>
<a href="phaseDetail.jsp?id=<%= request.getParameter("ccid") %>">Job Cost Detail</a> &gt; Job Cost Inquiry<hr>
<%
String id = request.getParameter("id");
Accounting acc = AccountingUtils.getAccounting(session);
Cost data = acc.getCost(id);
Code code = data.getCode();
if (attr.isLabor(code.getPhaseCode()) && !sec.ok(Security.LABOR_COSTS, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<table id="data">
	<tr>
		<td class="lbl">ID</td>
		<td><%= data.getId() %></td>
		<td class="lbl">Name</td>
		<td><%= FormHelper.stringTable(data.getName()) %></td>
	</tr>
	<tr>
		<td class="lbl">Job</td>
		<td><%= code.getJobNum() %></td>
		<td class="lbl">Date</td>
		<td><%= FormHelper.medDate(data.getDate()) %></td>
	</tr>
	<tr>
		<td class="lbl">Cost Code</td>
		<td><%= code.getDivision() + "." + code.getCostCode() %></td>
		<td class="lbl">Cost</td>
		<td><%= FormHelper.cur(data.getCost()) %></td>
	</tr>
	<tr>
		<td class="lbl">Phase Code</td>
		<td><%= code.getPhaseCode() %></td>
		<td class="lbl">Hours</td>
		<td><%= data.getHours() %></td>
	</tr>
	<tr>
		<td class="lbl">Invoice #</td>
		<td><%= FormHelper.stringTable(data.getInvoiceNum()) %></td>
		<td class="lbl">Description</td>
		<td><%= FormHelper.stringTable(data.getDescription()) %></td>
	</tr>
</table>
<form name="main">
<textarea name="request" cols="100" rows="6"></textarea><br>
<input type="button" value="Send Request" onClick="sendRequest(this.form);"> &nbsp;
<input type="button" value="Spelling" onClick="spellCheck(this.form);">
<input type="hidden" name="data">
<input type="hidden" name="ccid" value="<%= request.getParameter("ccid") %>">
</form>
<script language="javascript">
	f = document.main;
	d = f.request;
	d.required = true;
	d.spell = true;
</script>
</body>
</html>
<%
} else {
	String msg = "<style>*{font-family:Arial;font-size:10pt;}.lbl{text-align:right;font-weight:bold;}</style>";
	msg += "<table>" + request.getParameter("data") + "</table><hr>";
	msg += "<div style=\"width: 500px;\">" + request.getParameter("request").replaceAll("\n","<br>") + "</div>";
	SimpleMailer.sendMessage(attr.getEmail(), attr.getFullName(), attr.get("accounting_email"), null, attr.get("short_name") + " - Job Cost Request", msg, "text/html", in);
	response.sendRedirect("phaseDetail.jsp?id=" + request.getParameter("ccid"));
}
%>