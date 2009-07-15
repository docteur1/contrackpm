<%@page contentType="text/html"%>
<%@page import="accounting.Accounting, com.sinkluge.accounting.AccountingUtils,
	java.util.Iterator, accounting.Voucher, accounting.VoucherDistribution,
	accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.util.List" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) response.sendRedirect("../accessDenied.html");
Accounting acc = AccountingUtils.getAccounting(session);
Voucher voucher = acc.getVoucher(request.getParameter("id"));
List<VoucherDistribution> vds = voucher.getVoucherDistributions();
%>
<html>
<head>
<link rel="stylesheet" type="text/css" href="stylesheets/styleDetail.css" media="all">
<script>
<%
if (vds.size() == 1) {
%>
	parent.document.location = "voucherInquiry.jsp?id=<%= request.getParameter("id") %>" +
		"&ccid=<%= request.getParameter("ccid") %>&one=true";
<%
	vds.clear();
	return;
}
%>
    var bgcolor;
	function b(id) {
		bgcolor = id.style.backgroundColor;
		id.style.backgroundColor = "#FFFFCC";
	}
	function n(id) {
		id.style.backgroundColor = bgcolor;
	}
 	if (navigator.appName == "Microsoft Internet Explorer") parent.document.getElementById("fs").rows = "36,*";
</script>
</head>
<body>
<table cellspacing="0" cellpadding="0">
<%
boolean gotOne = false;
Code code;
double amount = 0, ptd = 0, ret = 0, disc = 0, uamount = 0, uptd = 0, uret = 0, udisc = 0;
VoucherDistribution vd;
String desc;
for (Iterator<VoucherDistribution> i = vds.iterator(); i.hasNext(); ) {
	vd = i.next();
	gotOne = true;
	amount += vd.getAmount();
	ptd += vd.getPaid();
	ret += vd.getRetention();
	disc += vd.getDiscount();
	code = vd.getCode();
	desc = vd.getDescription();
	if (desc == null) desc = voucher.getDescription();
	if (code.getJobNum() == null || !code.getJobNum().equals(attr.getJobNum())){
		uamount += vd.getAmount();
		uptd += vd.getPaid();
		uret += vd.getRetention();
		udisc += vd.getDiscount();
	} else {
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);">
		<td class="w80"><%= code.getDivision() + " " + code.getCostCode() + "-" + code.getPhaseCode() %></td>
          <td class="g w130"><%= FormHelper.stringTable(voucher.getName()) %></td>
		<td class="r w50"><%= FormHelper.cur(vd.getAmount()) %></td>
		<td class="r g w50"><%= FormHelper.cur(vd.getPaid()) %></td>
		<td class="r w50"><%= FormHelper.cur(vd.getRetention()) %></td>
		<td class="r g w50"><%= FormHelper.cur(vd.getDiscount()) %></td>
          <td class="w150"><%= FormHelper.stringTable(desc) %></td>
        </tr>
 <%
	}
}
vds.clear();
if (uamount != 0) {
	%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);">
		<td>***</td>
		<td class="g"><%= FormHelper.stringTable(voucher.getName()) %></td>
		<td class="r"><%= FormHelper.cur(uamount) %></td>
		<td class="r g"><%= FormHelper.cur(uptd) %></td>
		<td class="r"><%= FormHelper.cur(uret) %></td>
		<td class="r g"><%= FormHelper.cur(udisc) %></td>
          <td>Total non-project items</td>
        </tr>
 <%
}
if (gotOne) {
%>
	<tr class="yellow">
   	<td style="text-align: right;" colspan="2"><b>Totals</b></td>
      <td class="r"><b><%= FormHelper.curNoDec(amount) %></b></td>
     	<td class="r g"><b><%= FormHelper.curNoDec(ptd) %></b></td>
     	<td class="r"><b><%= FormHelper.curNoDec(ret) %></b></td>
     	<td class="r g"><b><%= FormHelper.curNoDec(disc) %></b></td>
      <td>&nbsp;</td>
	</tr>
</table>
<%
} else  out.println("&nbsp;<p><center><b><font color=\"red\">No records returned.</font></b><p>");
%>
</body>
</html>