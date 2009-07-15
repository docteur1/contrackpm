<%@page session="true" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/styleDetail.css" media="all">
</head>
<body>
<table cellspacing="0" cellpadding="0">
<%
String cost_code_id = request.getParameter("ccid");
String id = request.getParameter("id");
%>
<tr>
	<td class="p12" colspan="2"><b>Voucher: <%=id%></b></td>
	<td colspan="5" style="text-align: right;">
<%
int count = AccountingUtils.countDocuments(id, session);
if (count > 0) {
%>
<button accesskey="g" onclick="var win=window.open('../utils/print.jsp?doc=imageAcc.pdf?id=<%= id %>');win.focus();">Ima<u>g</u>es(<%= count %>)</button> &nbsp;
<%
}
if (sec.ok(Security.COST_DATA, Security.PRINT)){
%>
<button accesskey="p" onClick="parent.document.location='printVouchers.jsp?id=<%= cost_code_id %>';"><u>P</u>rint</button> &nbsp;
<%
}
%>
<button accesskey="e" onClick="parent.document.location='phaseDetail.jsp?id=<%= cost_code_id %>';"><u>J</u>ob Cost Detail</button> &nbsp;
<button accesskey="i" onClick="parent.document.location='voucherInquiry.jsp?ccid=<%= cost_code_id %>&id=<%= id %>';">Voucher <u>I</u>nquiry</button> &nbsp;
<button accesskey="b" onClick="parent.document.location='voucherDetail.jsp?id=<%= cost_code_id %>';"><u>B</u>ack</button>
</tr>
<tr class="yellow">
	<td class="w80"><b>Code</b></td>
	<td class="g w130"><b>Name</b></td>
	<td class="r w50"><b>Amount</b></td>
	<td class="r g w50"><b>Paid</b></td>
	<td class="r w50"><b>Ret</b></td>
	<td class="r g w50"><b>Disc</b></td>
 	<td class="w150"><b>Description</b></td>
</tr>
</table>
</body>
</html>
