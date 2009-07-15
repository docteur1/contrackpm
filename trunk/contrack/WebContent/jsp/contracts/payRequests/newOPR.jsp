<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT,sec.WRITE)) response.sendRedirect("../,,/accessDenied.html");
boolean sw = sec.ok(sec.SUBCONTRACT,sec.WRITE);
int month = Integer.parseInt((new SimpleDateFormat("MM")).format(new java.util.Date()));
String year = (new SimpleDateFormat("yyyy")).format(new java.util.Date());
%>
<html>
<head>
	<link rel="stylesheet" href="../../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript">
		function changeInput(obj) {
			obj.form.month.disabled = obj.value != "s";
			obj.form.year.disabled = obj.value != "s";
		}
	</script>
	<script language="javascript" src="../../utils/calendar.js"></script>
	<script language="javascript" src="../../utils/verify.js"></script>
</head>
<body>
<form name="opr" action="processOPR.jsp" method="post" onSubmit="return checkForm(this);">
<font size="+1">New Pay Request Period</font><hr>
<a href="../reviewContracts.jsp">Subcontracts</a> &gt; <a href="reviewOwnerPayRequests.jsp">Periods</a> &gt; New Period
<hr>
<table>
	<tr>
		<td class="lbl">Month:</td>
		<td><select name="month">
			<option value="01" <% if (month == 1) out.print("selected"); %>>January</option>
			<option value="02" <% if (month == 2) out.print("selected"); %>>February</option>
			<option value="03" <% if (month == 3) out.print("selected"); %>>March</option>
			<option value="04" <% if (month == 4) out.print("selected"); %>>April</option>
			<option value="05" <% if (month == 5) out.print("selected"); %>>May</option>
			<option value="06" <% if (month == 6) out.print("selected"); %>>June</option>
			<option value="07" <% if (month == 7) out.print("selected"); %>>July</option>
			<option value="08" <% if (month == 8) out.print("selected"); %>>August</option>
			<option value="09" <% if (month == 9) out.print("selected"); %>>September</option>
			<option value="10" <% if (month == 10) out.print("selected"); %>>October</option>
			<option value="11" <% if (month == 11) out.print("selected"); %>>November</option>
			<option value="12" <% if (month == 12) out.print("selected"); %>>December</option>
			</select></td>
	</tr>
	<tr>
		<td class="lbl">Year:</td>
		<td><input type="text" name="year" maxlength="4" size="2" value="<%= year %>"></td>
	</tr>
	<tr>
		<td class="lbl"><a href="javascript: insertDate('paid_by_owner')">Date Paid by Owner: </a></td>
		<td><input type="text" id="paid_by_owner" name="paid_by_owner" maxlength="10" size="8" value="">
			<img id="calpaid_by_owner" src="../../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Save" accesskey="s"></td>
	</tr>
</table>
</form>
<script language="javascript">
	var f = document.opr;
	var d = f.year;
	d.required = true;
	d.isInt = true;
	d.eName = "Year";
	d.select();
	d.focus();
	
	d = f.paid_by_owner;
	d.isDate = true;
	d.eName = "Date Paid by Owner";
</script>
</body>
