<%@page contentType="text/html"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Cost, accounting.Code" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.FormHelper, accounting.Accounting, java.util.List" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.COST_DATA, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String cost_code_id = request.getParameter("id");
Code code = AccountingUtils.getCode(cost_code_id);
if (attr.isLabor(code.getPhaseCode()) && !sec.ok(Security.LABOR_COSTS, Security.READ)) { 
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/styleDetail.css" media="all">
	<script language="javascript">
		function b(id) {
			id.style.backgroundColor = "#FFFFCC";
		}
		function n(id) {
			id.style.backgroundColor = "white";
		}
		function inquiry(id) {
			parent.location = "jobCostInquiry.jsp?ccid=<%= cost_code_id %>&id=" + id;
		}
	 	if (navigator.appName == "Microsoft Internet Explorer") parent.document.getElementById("fs").rows = "36,*";
	</script>
</head>
<body>
<table cellspacing="0" cellpadding="0">
<%
boolean gotOne = false;
Cost cost;
double totalCost = 0, totalHours = 0;
Accounting acc = AccountingUtils.getAccounting(session);
List<Cost> costs = acc.getCosts(code);
for (Iterator<Cost> i = costs.iterator(); i.hasNext(); ) {
	cost = i.next();
	gotOne = true;
	totalCost += cost.getCost();
	totalHours += cost.getHours();
%>
	<tr style="cursor: pointer;" onMouseOver="b(this);" onMouseOut="n(this);" onClick="inquiry(<%= cost.getId() %>);">
          <td class="w130"><%= FormHelper.stringTable(cost.getName()) %></td>
          <td class="g w80"><%= FormHelper.stringTable(cost.getInvoiceNum()) %></td>
          <td class="w72"><%= FormHelper.medDate(cost.getDate()) %></td>
		<td class="r g w50"><%= FormHelper.cur(cost.getCost()) %></td>
		<td class="r w30"><%= cost.getHours() %></td>
          <td class="g w190"><%= FormHelper.stringTable(cost.getDescription()) %></td>
        </tr>
 <%
}
costs.clear();
costs = null;
if (gotOne) {
%>
	<tr class="yellow">
   	<td style="text-align: right;" colspan="3"><b>Totals</b></td>
      <td class="r g w50"><b><%= FormHelper.curNoDec(totalCost) %></b></td>
     	<td class="r w30"><b><%= FormHelper.curNoDec(totalHours) %></b></td>
      <td>&nbsp;</td>
	</tr>
</table>
<%
}
else {
	out.println("&nbsp;<p><center><b><font color=\"red\">No records returned.</font></b><p>");
}
%>
</body>
</html>