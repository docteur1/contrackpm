<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT, sec.PRINT)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
		<title>Print Lien Waiver</title>
		<script language="javascript" src="../utils/verify.js"></script>
		<script language="javascript" src="../utils/calendar.js"></script>
		<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
	</head>
<body>
	<form name = "lien" method="POST" action="createLienWaiver.jsp" onSubmit="return checkForm(this);">
	<div class="title">Lien Waiver</div><hr/>
<%
Database db = new Database();
if (request.getParameter("company_id") != null) {
	String query = "select company_name from company where company_id = " + request.getParameter("company_id");
	ResultSet rs = db.dbQuery(query);
	rs.next();
%>
	<input type="hidden" name="company_id" value="<%= request.getParameter("company_id") %>">
	<table>
		<tr>
			<td class="lbl">Company:</td>
			<td><%= rs.getString(1) %> <input type="hidden" name="company_id" value="<%= request.getParameter("company_id") %>"></td>
		</tr>
		<tr>
			<td class="lbl">Amount:</td>
			<td><input type="text" size="8" value="" name="amount"></td>
		</tr>
		<tr>
			<td class="lbl"><a href="javascript: insertDate('date')">Date:</a></td>
			<td><input type="text" id="date" name="date" maxlength=10 size=8 value="">
						<img id="caldate" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		</tr>
	</table>
	<fieldset>
	<legend>Type</legend>
	<table>
		<tr>
			<td class="lbl">Conditional:</td>
			<td><input type="radio" name="type" value="Conditional" checked></td>
		</tr>
		<tr>
			<td class="lbl">Unconditional:</td>
			<td><input type="radio" name="type" value="Unconditional"></td>
		</tr>
		<tr>
			<td class="lbl">Final:</td>
			<td><input type="radio" name="type" value="Final"></td>
		</tr>
	</table>
	</fieldset><br/>
	<input type="submit" value="Create">
<%
} else {
	String query = "select company_name, contracts.company_id from company, contracts where company.company_id = contracts.company_id and contract_id = " + request.getParameter("id");
	ResultSet rs = db.dbQuery(query);
	rs.next();
%>
	<table>
		<tr>
			<td class="lbl">Company:</td>
			<td><%= rs.getString(1) %> <input type="hidden" name="company_id" value="<%= rs.getString("company_id") %>"></td>
		</tr>
		<tr>
			<td class="lbl">Amount:</td>
			<td><input type="text" size="8" value="" name="amount"></td>
		</tr>
		<tr>
			<td class="lbl"><a href="javascript: insertDate('date')">Date:</a> </td>
			<td><input type="text" id="date" name="date" maxlength=10 size=8 value="">
						<img id="caldate" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" value="Create"></td>
		</tr>
	</table>
	<input type="hidden" name="type" value="<%= request.getParameter("type") %>"><p>
	<input type="hidden" name="contract_id" value="<%= request.getParameter("id") %>">
<%
}
db.disconnect();
%>

	</form>
	<script language="javascript">
		insertDate("date");
		document.lien.date.isDate = true;
		document.lien.date.required = true;
		document.lien.date.eName = "Date";
		document.lien.amount.focus();
		document.lien.amount.select();
		document.lien.amount.isFloat = true;
		document.lien.amount.required = true;
		document.lien.amount.eName = "Amount";
		initCal();
	</script>
</body>
</html>
