<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Voucher" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.SimpleMailer" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="java.util.List, accounting.Accounting" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) response.sendRedirect("../accessDenied.html");
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
		frm.action = "voucherInquiry.jsp";
		frm.method = "POST";
		if (checkForm(frm)) frm.submit();
	}
	function openPayRequest(id) {
		msgWindow=open('','pr','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=600,height=500,left=25,top=25');
		msgWindow.location.href = "../contracts/payRequests/modifyPRFrameset.jsp?id=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
</script>
<title>Voucher Inquiry</title>
</head>
<body>
<font size="+1">Voucher Inquiry</font><hr>
<%
if (request.getParameter("ccid") != null) {
%>
<a href="voucherDetail.jsp?id=<%= request.getParameter("ccid") %>">Job Cost Voucher Detail</a> &gt; 
<%
	if (request.getParameter("one") == null) {
%>
<a href="iVoucherDetail.jsp?id=<%= request.getParameter("id") %>&ccid=<%= request.getParameter("ccid") %>">Voucher Detail</a> &gt;
<%
	}
}
String id = request.getParameter("id");
Accounting acc = AccountingUtils.getAccounting(session);
Voucher data = acc.getVoucher(id);
%>
Voucher Inquiry &nbsp; <%= data.getPayRequestId() != 0 ? 
	"<a href=\"javascript: openPayRequest(" + data.getPayRequestId() + ");\">Pay Request</a> &nbsp;" : "" %>
<%
int count = AccountingUtils.countDocuments(id, session);
if (count > 0) out.println("<a href=\"../utils/print.jsp?doc=imageAcc.pdf?id=" 
		+ id + "\" target=\"_blank\"><b>Images(" + count + ")</b></a>");
%>
	<hr>
<table id="data">
	<tr>
		<td class="lbl">Voucher</td>
		<td><%= data.getId() %></td>
		<td class="lbl">Amount</td>
		<td><%= FormHelper.cur(data.getAmount()) %></td>
	</tr>
	<tr>
		<td class="lbl">Date</td>
		<td><%= FormHelper.medDate(data.getDate()) %></td>
		<td class="lbl">Paid</td>
		<td><%= FormHelper.cur(data.getPaid()) %></td>
	</tr>
	<tr>
		<td class="lbl">Name</td>
		<td><%= FormHelper.stringTable(data.getName()) %></td>
		<td class="lbl">Retention</td>
		<td><%= FormHelper.cur(data.getRetention()) %></td>
	</tr>
	<tr>
		<td class="lbl">Invoice #</td>
		<td><%= FormHelper.stringTable(data.getInvoiceNum()) %></td>
		<td class="lbl">Disc</td>
		<td><%= FormHelper.cur(data.getDiscount()) %></td>
	</tr>
	<tr>
		<td class="lbl">PO #</td>
		<td><%= FormHelper.stringTable(data.getPoNum()) %></td>
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
	SimpleMailer.sendMessage(attr.getEmail(), attr.getFullName(), attr.get("accounting_email"), null, attr.get("short_name") + " Voucher Request", msg, "text/html", in);
	response.sendRedirect("voucherDetail.jsp?id=" + request.getParameter("ccid"));
}
%>