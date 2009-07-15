<%@page session="true" %>
<%@page contentType="text/html"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT, sec.PRINT)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
%>
<html>
	<head>
		<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
		<title>Print Lien Waiver</title>
		<script language="javascript" src="../utils/verify.js"></script>
		<script language="javascript" src="../utils/calendar.js"></script>
	</head>
<body>
	<form name = "lien" method="POST" action="createCustomLienWaiver.jsp" onSubmit="return checkForm(this);">
	<font size="+1">Lien Waiver</font><hr>
	<table>
		<tr>
			<td><b>Company: </b></td>
			<td><input type="text" name="company" value="<%= request.getParameter("company") %>"></td>
		</tr>
		<tr>
			<td><b>Amount: </b></td>
			<td><input type="text" size="8" value="" name="amount"></td>
		</tr>
		<tr>
			<td><b><a href="javascript: insertDate('date')">Date:</a> </b></td>
			<td><input type="text" id="date" name="date" maxlength=10 size=8 value="">
						<img id="caldate" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		</tr>
	</table>
	<fieldset>
	<legend>Type</legend>
	<table>
		<tr>
			<td><b>Conditional: </b></td>
			<td><input type="radio" name="type" value="Conditional" checked></td>
		</tr>
		<tr>
			<td><b>Unconditional: </b></td>
			<td><input type="radio" name="type" value="Unconditional"></td>
		</tr>
		<tr>
			<td><b>Final: </b></td>
			<td><input type="radio" name="type" value="Final"></td>
		</tr>
	</table>
	</fieldset><p>
	<input type="submit" value="Create">

<input type="hidden" name="address" value="<%= request.getParameter("address") %>">
<input type="hidden" name="city" value="<%= request.getParameter("city") %>">
<input type="hidden" name="state" value="<%= request.getParameter("state") %>">
<input type="hidden" name="zip" value="<%= request.getParameter("zip") %>">
<input type="hidden" name="phone" value="<%= request.getParameter("phone") %>">
<input type="hidden" name="fax" value="<%= request.getParameter("fax") %>">
	</form>
	<script language="javascript">
		document.lien.amount.focus();
		document.lien.amount.select();
		var d = document.lien;
		var f = d.company;
		f.required = true;
		f.eName = "Company";
		f =d.amount;
		f.required = true;
		f.isFloat = true;
		f.eName = "Amount";
		f = d.date;
		insertDate("date");
		f.required = true;
		f.isDate = true;
		f.eName = "Date";
		initCal();
	</script>
</body>
</html>
