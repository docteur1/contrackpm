<%@page contentType="text/html"%>
<%@page import="com.sinkluge.accounting.AccountingUtils, java.util.Iterator" %>
<%@page import="accounting.Cost, accounting.Code" %>
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
	<link rel="stylesheet" type="text/css" href="stylesheets/printStyleDetail.css" media="all">
	<title>Job Cost Detail</title>
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
				<td class="head">Name</td>
				<td class="head">Invoice</td>
				<td class="head">Date</td>
				<td align="right" class="head">Cost</td>
				<td align="right" class="head">Hrs</td>
				<td class="head">Description</td>
			</tr>
	</thead>
	<tbody>
<%
Cost data;
int count = 0;
double cost = 0, hours = 0;
Accounting acc = AccountingUtils.getAccounting(session);
List<Cost> costs = acc.getCosts(code);
for (Iterator<Cost> i = costs.iterator(); i.hasNext(); ) {
	data = i.next();
	cost += data.getCost();
	hours += data.getHours();
	count++;
%>
        <tr>
          <td><%= FormHelper.stringTable(data.getName()) %></td>
          <td><%= FormHelper.stringTable(data.getInvoiceNum()) %></td>
          <td><%= FormHelper.medDate(data.getDate()) %></td>
          <td align="right"><%= FormHelper.cur(data.getCost()) %></td>
          <td align="right"><%= data.getHours() %></td>
          <td><%= FormHelper.stringTable(data.getDescription()) %></td>
        </tr>
<%
}
costs.clear();
costs = null;
acc.close();
%>
</tbody>
<tfoot>
	<tr>
		<td class="foot">Items: <%= count %></td>
   	<td class="foot" colspan="2" align="right">Totals</td>
      <td class="foot" align="right"><%= FormHelper.cur(cost) %></td>
      <td class="foot" align="right"><%= hours %></td>
      <td class="foot">&nbsp;</td>
	</tr>
</tfoot>
</table>
</body>
</html>