<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Voucher, accounting.Check" %>
<%@page import="java.util.Iterator, accounting.Accounting" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.security.Security, java.util.List" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../stylesheets/v2.css" media="all" >
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<title>Voucher Info</title>
</head>
<body>
<font size="+1">Voucher Info</font><hr>
<%
String id = request.getParameter("id");
Accounting acc = AccountingUtils.getAccounting(session);
Voucher data = acc.getVoucher(id);
if (data != null) {
%>
<table>
	<tr>
		<td class="lbl">Voucher</td>
		<td><%= data.getId() %></td>
		<td class="lbl">Date</td>
		<td><%= FormHelper.medDate(data.getDate()) %></td>
	</tr>
	<tr>
		<td class="lbl">Job</td>
		<td><%= attr.getJobNum() %></td>
		<td class="lbl">Amount</td>
		<td><%= FormHelper.cur(data.getAmount()) %></td>
	</tr>
	<tr>
		<td class="lbl">Name</td>
		<td><%= FormHelper.stringTable(data.getName()) %></td>
		<td class="lbl">Paid</td>
		<td><%= FormHelper.cur(data.getPaid()) %></td>
	</tr>
	<tr>
		<td class="lbl">Invoice #</td>
		<td><%= FormHelper.stringTable(data.getInvoiceNum()) %></td>
		<td class="lbl">Retention</td>
		<td><%= FormHelper.cur(data.getRetention()) %></td>
	</tr>
	<tr>
		<td class="lbl">PO #</td>
		<td><%= FormHelper.stringTable(data.getPoNum()) %></td>
		<td class="lbl">Disc</td>
		<td><%= FormHelper.cur(data.getDiscount()) %></td>
	</tr>
	<tr>
		<td class="lbl">Description</td>
		<td colspan="3"><%= FormHelper.stringTable(data.getDescription()) %></td>
	</tr>
</table>
<table cellspacing="0" cellpadding="3" style="margin-bottom: 8px; margin-top: 4px;">
	<tr>
		<td class="left head aright">Check #</td>
		<td class="head">Name</td>
		<td class="right head aright">Amount</td>
	</tr>
<%
	Check check;
	List<Check> checks = data.getChecks();
	for (Iterator<Check> i = checks.iterator(); i.hasNext(); ) {
		check = i.next();
%>
	<tr>
		<td class="left aright"><%= check.getCheckNum() %></td>
		<td class="it"><%= FormHelper.stringTable(check.getName()) %></td>
		<td class="right aright"><%= FormHelper.cur(check.getAmount()) %></td>
	</tr>
<%
	}
	checks.clear();
} else out.println("<div class=\"red bold\" style=\"margin-bottom: 8px;\">No data found!</div>");
%>
</table>
<input type="button" value="Close" onClick="window.close();"> &nbsp;
<%
int count = AccountingUtils.countDocuments(id, session);
if (count > 0) out.println("<input type=\"button\" onclick=\"var msgWin = window.open('../../utils/print.jsp?doc=imageAcc.pdf?id=" 
			+ id + "'); msgWin.focus();\" value=\"Images(" + count + ")\">");
acc.close();
%>
</body>
</html>