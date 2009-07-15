<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.ACCOUNT, Security.READ)) response.sendRedirect("../accessDenied.html");
boolean w = sec.ok(Security.ACCOUNT, Security.WRITE);
boolean p = sec.ok(Security.LABOR_COSTS, Security.PRINT) || sec.ok(Security.COST_DATA, Security.PRINT);

String query = "select date_costs_updated from "
	+ "job where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String date = "";
if (rs.first()) date = FormHelper.timestamp(rs.getTimestamp("date_costs_updated"));
if (date.equals("")) date = "Not Updated";
rs.getStatement().close();
rs = null;
String div = request.getParameter("div");
%>
<html>
<head>
	<script language="javascript">
		function addCode() {
			parent.edit.document.location = "addCode.jsp";
			if (navigator.appName == "Microsoft Internet Explorer") parent.document.getElementById("fs").rows = "41,47,*,16";
			else parent.document.getElementById("fs").rows = "41,40,*,16";
		}
		function openWin(address) {
			msgWin = window.open(address,'print');
			msgWin.focus();
		}
		function exportData() {
			msgWindow = open('exportData.jsp','reports','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=300,height=200,left=25,top=25');
			msgWindow.focus();
		}
		function updateCosts() {
			if(confirm("Update Costs to Date?")) {
				parent.parent.showMessage("Updating Costs to Date", "Please Wait", true);
				parent.location = "updateCosts.jsp";
			}
		}
		function menuChange(opt) {
			if (opt.value == "bc") openWin("budgetComparison.jsp");
			else if (opt.value == "bs") openWin("budgetSummary.jsp");
			else if (opt.value == "cs") openWin("../utils/print.jsp?doc=completeSummary.pdf");
			else if (opt.value == "jbs") openWin("jobsiteSummary.jsp");
			else if (opt.value == "add") addCode();
			else if (opt.value == "many") parent.location = "addManyCodes.jsp";
			else if (opt.value == "lock" && 
				confirm("Lock Budget/Estimate\n---------------------\nPrevent further editing of budget\nand estimate fields?")) 
					parent.location = "lock.jsp";
			else if (opt.value == "unlock" && 
				confirm("Unlock Budget/Estimate\n---------------------\nAllow editing of all budget\nand estimate fields?")) 
					parent.location = "lock.jsp?unlock=t";
			opt.selectedIndex = 0;
		}
		function divChange(opt) {
			parent.document.getElementById("fs").rows = "41,0,*,16";
			if (opt.value != "all") parent.main.location = "codesMain.jsp?div=" + opt.value;
			else parent.main.location = "codesMain.jsp";
		}
		function updateDate() {
			if (confirm("Project costs updated?")) {
				parent.parent.showMessage("Updating cost to complete", "Please Wait", true);
				location = "setUpdateDate.jsp";
			}
		}
	</script>
	<link rel="stylesheet" type="text/css" href="stylesheets/style.css">
</head>
<body>
<form name="updateCosts">
<table cellspacing="0">
<tr>
	<td colspan="3" align="center">
		<select name="division"  onChange="divChange(this);" style="font-weight: bold;">
<%
query = "select division, description from job_divisions where job_id = " + attr.getJobId() + " order by costorder(division)";
rs = db.dbQuery(query);
String division;
while (rs.next()) {
	division = rs.getString("division");
%>
			<option value="<%= division %>" <%= FormHelper.sel(division,div) %>>
				<%= division + " " + rs.getString("description")%></option>
<%
}
rs.getStatement().close();
rs = null;
db.disconnect();
%>
			<option value="all" <% if (div == null) out.print("selected"); %>>--All--</option>
		</select></td>
	<td align="center" class="font" colspan="3">
		<select name="menu" onChange="menuChange(this);" style="font-weight: bold;">
			<option value="MENU">--MENU--</option>
<%
if (sec.ok(Security.ACCOUNT, Security.PRINT)){
%>
			<option value="reports" disabled>Reports</option>
<%
	if (attr.hasAccounting()) 
		out.print("<option value=\"bc\"> &nbsp; Accounting Comparison</option>");
	out.print("<option value=\"bs\"> &nbsp; Budget Summary</option>");
	out.print("<option value=\"cs\"> &nbsp; Complete Summary</option>");
	out.print("<option value=\"jbs\"> &nbsp; Jobsite Summary</option>");
}
if (w) {
%>
	<option disabled>New Phases</option>
			<option value="add"> &nbsp; Add Phase</option>
			<option value="many"> &nbsp; Select Phases</option>
	<option disabled>Lock</option>
		<option value="lock"> &nbsp; Lock</option>
<%
}
if (sec.ok(Security.UNLOCK_BUDGET, Security.PRINT)) out.println("<option value=\"unlock\"> &nbsp; Unlock</option>");
%>
		</select></td>

	<td align="center" colspan="2">
<%

	if (w && attr.hasAccounting()) {
		out.print("<b><a href=\"javascript: updateCosts();\">Import</a></b>");
		if (p) out.println(" / ");
	}
	if (p) out.println("<b><a href=\"../servlets/CSV/costs.csv\">Export</a></b>");
if(w) {
%>
		</td>
	<td align="center" colspan="3"><b>Last Updated: <a href="javascript: updateDate();"><%= date %></a></b></td>
<%
} else { %>
		&nbsp;</td>
		<td colspan="3" align="center" style="border-left: 0"><b>Last Updated: <%= date %></b>
<%
}
%>
</td>
</tr>
</form>
<tr class="yellow">
	<td class="r35"><b>Phase</b></td>
	<td style="width: 107px;"><b>Description</b></td>
	<td align="right" style="width: 3px;"><b>Type</b></td>
	<td class="rg60"><b>Estimate</b></td>
	<td class="r60"><b>Contract</b></td>
	<td class="rg60"><b>Budget</b></td>
	<td class="r60"><b>Changes</b></td>
	<td class="rg60"><b>$ To Date</b></td>
 	<td class="r60"><b>Complete</b></td>
	<td class="rg60"><b>To Finish</b></td>
   <td class="r60"><b>Perform</b></td>
</tr>
</table>
<%
if (request.getParameter("add") != null) {
%>
<script language="javascript">
	addCode();
</script>
<%
}
%>
</body>
</html>
