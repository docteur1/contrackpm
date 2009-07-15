<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.Widgets" %>
<%@page import="java.text.SimpleDateFormat, java.util.Date, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,sec.WRITE)) response.sendRedirect("../,,/accessDenied.html");
boolean sw = sec.ok(sec.SUBCONTRACT,sec.WRITE);
String id = request.getParameter("id");
String query = "select * from owner_pay_requests where opr_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String period = "Error";
Date d;
String paid_by_owner = "";
boolean final_payment = false;
boolean locked = false;
if (rs.next()) {
	d = rs.getDate("paid_by_owner");
	if (d != null) paid_by_owner = (new SimpleDateFormat("MM/dd/yyyy")).format(d);
	period  = rs.getString("period");
	locked = rs.getBoolean("locked");
}
if (rs != null) rs.close();
rs = null;
db.disconnect();
%>
<html>
<head>
	<link rel="stylesheet" href="../../stylesheets/v2.css" type="text/css">
	<%= Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../../utils/calendar.js"></script>
	<script language="javascript" src="../../utils/verify.js"></script>
</head>
<body>
<form name="opr" action="processModifyOPR.jsp" method="post" onSubmit="return checkForm(this);">
	<input type="hidden" name="id" value="<%= id %>">
<font size="+1">Modify Period</font><hr>
<%
if (request.getParameter("saved") != null) out.print("<font color=\"red\"><b>Saved</b></font><hr>");
%>
<table>
	<tr>
		<td class="lbl">Period:</td>
		<td><%= period %></td>
	</tr>
	<tr>
		<td class="lbl"><a href="javascript: insertDate('paid_by_owner')">Date Paid by Owner: </a>
		<td><input type="text" id="paid_by_owner" name="paid_by_owner" maxlength="10" size="8" value="<%= paid_by_owner %>">
			<img id="calpaid_by_owner" src="../../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
	</tr>
	<tr>
		<td class="lbl">Closed:</td>
<%
if (sec.ok(Security.APPROVE_PAYMENT, Security.WRITE)) {
%>
		<td><input type="checkbox" name="locked" value="y" <%= FormHelper.chk(locked) %>></td>
<%
} else {
%>
		<td><%= Widgets.checkmark(locked, request) %></td>
<%
}
%>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Save" accesskey="s"> 
			 <input type="button" value="Close" accesskey="c" onClick="window.close();"></td>
	</tr>
</table>
</form>
<script language="javascript">
	var f = document.opr;
	
	var d = f.paid_by_owner;
	d.isDate = true;
	d.eName = "Date Paid by Owner";
</script>
</body>
