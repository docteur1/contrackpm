<%@page contentType="text/html"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Voucher, accounting.VoucherDistribution, accounting.Code" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.utilities.FormHelper, accounting.Accounting" %>
<%@page import="java.util.List" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Name.ACCOUNTING_DATA, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String cost_code_id = request.getParameter("id");

Code code = AccountingUtils.getCode(cost_code_id);
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/styleDetail.css" media="all">
	<script src="../utils/jsonrpc.js"></script>
	<script>
	    var bgcolor;
		function b(id) {
			bgcolor = id.style.backgroundColor;
			id.style.backgroundColor = "#FFFFCC";
		}
		function n(id) {
			id.style.backgroundColor = bgcolor;
		}
		function inquiry(id) {
			parent.location = "iVoucherDetail.jsp?ccid=<%= cost_code_id %>&id=" + id;
		}
		function openDocument(id) {
			var msgWin = window.open("../utils/print.jsp?doc=imageAcc.pdf?id=" + id, "print");
			msgWin.focus();
		}
	 	if (navigator.userAgent.indexOf("MSIE") != -1) parent.document.getElementById("fs").rows = "36,*";
	</script>
</head>
<body>
<table cellspacing="0" cellpadding="0">
<%
boolean gotOne = false;
double amount = 0, ptd = 0, ret = 0, disc = 0;
String vn, ovn = null;
boolean color = false;
Voucher v;
VoucherDistribution vd;
int count;
Accounting acc = AccountingUtils.getAccounting(session);
List<VoucherDistribution> vds = acc.getVoucherDistributions(code);
String desc;
boolean accPermission = sec.ok(Name.ACCOUNTING, Permission.READ);
for (Iterator<VoucherDistribution> i = vds.iterator(); i.hasNext(); ) {
	vd = i.next();
	v = acc.getVoucher(vd.getVoucherId());
	gotOne = true;
	amount += vd.getAmount();
	ptd += vd.getPaid();
	ret += vd.getRetention();
	disc += vd.getDiscount();
	vn = v.getId();
	count = AccountingUtils.countDocuments(vn, session);
	if (ovn == null) ovn = vn;
	if (!vn.equals(ovn)) {
		color = !color;
		ovn = vn;
	}
	desc = vd.getDescription();
	if (desc == null) desc = v.getDescription();
%>
	<tr <% if (color) out.println("class=\"blue\""); %> style="cursor: pointer;" onMouseOver="b(this);" 
		onMouseOut="n(this);" onClick="inquiry(<%= vn %>);" oncontextmenu="<%=
			count != 0 ? "openDocument(" + vn + "); return false;" : 
			"window.alert('No documents found!');" %>">
          <td class="w130"><%= FormHelper.stringTable(v.getName()) %></td>
          <td class="g w80"><%= FormHelper.stringTable(v.getInvoiceNum()) %></td>
          <td class="r w50"><%= FormHelper.stringTable(v.getPoNum()) %></td>
          <td class="g w72"><%= FormHelper.medDate(v.getDate()) %></td>
		<td class="r w50"><%= FormHelper.cur(vd.getAmount()) %></td>
		<td class="r g w50"><%= FormHelper.cur(vd.getPaid()) %></td>
		<td class="r w50"><%= FormHelper.cur(vd.getRetention()) %></td>
		<td class="r g w50"><%= FormHelper.cur(vd.getDiscount()) %></td>
          <td class="w150"><%= FormHelper.stringTable(desc) %></td>
          <td class="g c w10"><%= count != 0 ? "Yes" : "No" %></td>
        </tr>
 <%
}
vds.clear();
if (gotOne) {
%>
	<tr class="yellow">
   	<td style="text-align: right;" colspan="4"><b>Totals</b></td>
      <td class="r w50"><b><%= FormHelper.curNoDec(amount) %></b></td>
     	<td class="r g w50"><b><%= FormHelper.curNoDec(ptd) %></b></td>
     	<td class="r w50"><b><%= FormHelper.curNoDec(ret) %></b></td>
     	<td class="r g w50"><b><%= FormHelper.curNoDec(disc) %></b></td>
      <td colspan="2">&nbsp;</td>
	</tr>
</table>
<%
} else  out.println("&nbsp;<p><center><b><font color=\"red\">No records returned.</font></b><p>");
%>
</body>
</html>