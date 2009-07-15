<%@page contentType="text/html"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Voucher, accounting.Code, accounting.VoucherDistribution" %>
<%@page import="com.sinkluge.utilities.FormHelper, java.util.List" %>
<%@page import="com.sinkluge.security.Security, accounting.Accounting" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.COST_DATA, Security.PRINT)) response.sendRedirect("../accessDenied.html");
String cost_code_id = request.getParameter("id");
Code code = AccountingUtils.getCode(cost_code_id);
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="../stylesheets/print.css" media="all">
	<title>Voucher Detail</title>
	<script language="javascript">
		function printThis() {
			document.getElementById("printLink").style.visibility = "hidden";
			self.print();
		}
	</script>
</head>
<body>
<div><font size="+1"><%= attr.getJobNum() + ": " + attr.getJobName() %></font></div>
<div><b><%= code.getDivision() + " " + code.getCostCode() + "-" + code.getPhaseCode() + ": " + code.getName() %></b> 
	&nbsp; <a href="javascript: printThis();" id="printLink">Print</a></div>
<hr>
<table cellspacing="0">
	<thead>
			<tr>
			<td class="head">Voucher</td>
				<td class="head">Name</td>
				<td class="head">Invoice</td>
				<td class="head">PO</td>
				<td class="head">Date</td>
				<td align="right" class="head">Cost</td>
				<td align="right" class="head">Paid</td>
				<td align="right" class="head">Retention</td>
				<td align="right" class="head">Disc</td>
				<td class="head">Description</td>
			</tr>
	</thead>
<tbody>
<%
int count = 0;
double amount = 0, ptd = 0, ret = 0, disc = 0;
VoucherDistribution vd;
Voucher v;
Accounting acc = AccountingUtils.getAccounting(session);
List<VoucherDistribution> vds = acc.getVoucherDistributions(code);
String desc;
for (Iterator<VoucherDistribution> i = vds.iterator(); i.hasNext(); ) {
	vd = i.next();
	amount += vd.getAmount();
	ptd += vd.getPaid();
	ret += vd.getRetention();
	disc += vd.getDiscount();
	count++;
	v = acc.getVoucher(vd.getVoucherId());
	desc = vd.getDescription();
	if (desc == null) desc = v.getDescription();
%>
        <tr>
         <td><%= v.getId() %></td>
          <td><%= FormHelper.stringTable(v.getName()) %></td>
          <td><%= FormHelper.stringTable(v.getInvoiceNum()) %></td>
          <td><%= FormHelper.stringTable(v.getPoNum()) %></td>
          <td><%= FormHelper.medDate(v.getDate()) %></td>
          <td align="right"><%= FormHelper.cur(vd.getAmount()) %></td>
          <td align="right"><%= FormHelper.cur(vd.getPaid()) %></td>
          <td align="right"><%= FormHelper.cur(vd.getRetention()) %></td>
          <td align="right"><%= FormHelper.cur(vd.getDiscount()) %></td>
          <td><%= FormHelper.stringTable(desc) %></td>
        </tr>
<%
}
vds.clear();
%>
</tbody>
<tfoot>
	<tr>
		<td class="foot" colspan="2">Items: <%= count %></td>
   	<td class="foot" colspan="3" align="right">Totals</td>
      <td class="foot" align="right"><%= FormHelper.cur(amount) %></td>
      <td class="foot" align="right"><%= FormHelper.cur(ptd) %></td>
      <td class="foot" align="right"><%= FormHelper.cur(ret) %></td>
      <td class="foot" align="right"><%= FormHelper.cur(disc) %></td>
      <td class="foot">&nbsp;</td>
	</tr>
</tfoot>
</table>
</body>
</html>