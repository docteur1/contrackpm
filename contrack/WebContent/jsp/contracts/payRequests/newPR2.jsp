<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper, java.text.DecimalFormat" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String opr_id = request.getParameter("opr_id");
String contract_id = request.getParameter("contract_id");
String query = "select amount, retention_rate, division, cost_code, phase_code, code_description, company_name from contracts, job_cost_detail as jcd, company "
	+ " where contracts.company_id = company.company_id and jcd.cost_code_id = contracts.cost_code_id and "
	+ "contract_id = " + contract_id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String contract_string = "ERROR";
String cost_code = null;
String phase_code = null;
String division = null;
DecimalFormat df = new DecimalFormat("0.0");
double retention = 0.05;
double contract = 0;
if (rs.next()) {
	cost_code = rs.getString("cost_code");
	phase_code = rs.getString("phase_code");
	division = rs.getString("division");
	retention = rs.getDouble("retention_rate");
	contract = rs.getDouble("amount");
	contract_string = division + " " + cost_code + "-" + phase_code + " " + rs.getString("company_name") + ": "
		+ rs.getString("code_description");
}
if (rs != null) rs.close();
rs = null;
query = "select period, paid_by_owner from owner_pay_requests where opr_id = " + opr_id;
rs = db.dbQuery(query);
String period = "ERROR";
String paid_by_owner = "ERROR";
boolean fp = request.getParameter("final") != null;
if (rs.next()) {
	period = rs.getString("period");
	if (fp) period += " FINAL";
	try {
		paid_by_owner = FormHelper.medDate(rs.getDate("paid_by_owner"));
	} catch (NullPointerException e) {
		paid_by_owner = "No payment recorded";
	}
}
if (rs != null) rs.close();
rs = null;
query = "select max(request_num) as new_request_num from pay_requests where contract_id = " + contract_id;
int request_num = 1;
rs = db.dbQuery(query);
if (rs.next()) request_num = rs.getInt(1) + 1;
if (rs != null) rs.close();
rs = null;
%>
<html>
<head>
	<link href="../../stylesheets/v2.css" rel="stylesheet" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript">
		parent.left.location="newPRLeft2.jsp?opr_id=<%= opr_id %>";
		var fp = <%= fp %>;
		function save() {
			if (checkForm(f)) f.submit();
		}
	</script>
	<script language="javascript" src="scripts/pr.js"></script>
	<script language="javascript" src="../../utils/verify.js"></script>
	<style>
		.money {
			text-align: right;
			width: 90px;
		}
	</style>
</head>
<body>
<form name="pr" action="processPR.jsp" method="POST">
	<input type="hidden" name="opr_id" value="<%= opr_id %>">
	<input type="hidden" name="contract_id" value="<%= contract_id %>">
<%
if (fp) out.print("<input type=\"hidden\" name=\"final\" value=\"true\">");
%>
<font size="+1">New Pay Request</font><hr>
<fieldset style="width: 400px;">
	<legend><b>Pay Request Information</b></legend>
	<table>
		<tr>
			<td class="lbl">Contract:</td>
			<td><%= contract_string %></td>
		</tr>
		<tr>
			<td class="lbl">Period:</td>
			<td><%= period %><input type="hidden" name="period" value="<%= period %>"></td>
		</tr>
		<tr>
			<td class="lbl">Paid by Owner:</td>
			<td><%= paid_by_owner %></td>
		</tr>
		<tr>
			<td class="lbl" nowrap>Request #:</td>
			<td><input type="hidden" name="request_num" value="<%= request_num %>"><%= request_num %></td>
		</tr>
		<tr>
			<td class="lbl">Lien Waiver:</td>
			<td><select name="lien_waiver">
				<option <%= FormHelper.sel(request_num, 1) %>>Not Required</option>
				<option <%= FormHelper.sel(request_num != 1) %>>Requested</option>
				<option>Not Filed</option>
				</select></td>
		</tr>
	</table>
</fieldset>
<p>
<fieldset style="width: 400px;">
	<legend>Pay Request Costs</legend>
	<table width="100%">
		<tr>
			<td class="lbl">Invoice #:</td>
			<td colspan="2"><input type="text" name="invoice_num" maxlength="70"></td>
		</tr>
		<tr>
			<td class="lbl">Original Contract Amount:</td>
			<td align="right">$</td>
			<td align="right"><%= FormHelper.cur(contract) %></td>
		</tr>
<%
query = "select sum(amount) as ca from change_request_detail where "
	+ "contract_id = " + contract_id + " and authorization = 1";
rs = db.dbQuery(query);
double co = 0;
if (rs.next()) co = rs.getDouble(1);
if (rs != null) rs.getStatement().close();
rs = null;
%>
		<tr>
			<td class="lbl">Change Authorizations:</td>
			<td align="right">+$</td>
			<td align="right"><%= FormHelper.cur(co) %><input type="hidden" name="co" value="<%= co %>"></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final"); else out.print("Adjusted"); %> Contract Amount:</td>
			<td align="right">=$</td>
			<td align="right"><%= FormHelper.cur(contract + (double) co) %><input type="hidden" name="con" value="<%= contract + (double) co %>"></td>
		</tr>
<%
	if (!fp) {
%>
		<tr>
			<td class="lbl">Value of Work Completed to Date:</td>
			<td align="right">$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="vwctd" value="0.00" onChange="subtotal();"></td>
		</tr>
<%
}
// Let's look at previous pay requests first
query = "select sum(adj_value_of_work - adj_previous_billings) as ptd from pay_requests as pr, owner_pay_requests as opr where "
	+ "pr.opr_id = opr.opr_id and period != '" + period + "' and contract_id = " + contract_id
	+ " order by request_num desc limit 1";
rs = db.dbQuery(query);
double ptd = 0;
if (rs.next()) ptd = rs.getDouble(1);
if (rs != null) rs.close();
rs = null;
	// If we didn't get anything try the accounting database information
double subtotal = 0;
if (fp) subtotal = contract + co - ptd;
%>
		<tr>
			<td class="lbl">Less Previous Gross Billings:</td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="ptd" value="<%= FormHelper.cur(ptd) %>" onChange="subtotal();"></td>
		</tr>
		<tr>
			<td class="lbl">SUBTOTAL (<% if (fp) out.print("Final Billing"); else out.print("This Month's Billing"); %>):</td>
			<td align="right">=$</td>
			<td align="right"><div id="subtotal"><%= FormHelper.cur(subtotal) %></div></td>
		</tr>
<%
double final_ret = 0;
if (fp) final_ret = retention * subtotal;
db.disconnect();
%>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Retention (" + df.format(retention * 100) + "%)"); else out.print("Less this Month's Retention (" + df.format(retention * 100) + "%)"); %>:
				<input type="hidden" name="rate" value="<%= retention %>"></td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="ret" value="<%= FormHelper.cur(final_ret) %>" onChange="retention(false);"></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Amount Due"); else out.print("Amount Due This Pay Period"); %>:</td>
			<td align="right">=$</td>
			<td align="right"><div id="due"><%= FormHelper.cur(subtotal - final_ret) %></div></td>
		</tr>
	</table>
</fieldset>
<fieldset>
	<legend><b>Internal Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="internal_comments"></textarea>
</fieldset>
<fieldset>
	<legend><b>External Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="external_comments"></textarea>
</fieldset>
</form>
<script language="javascript">
	var f = document.pr;
	
	var d;
	
<%
if (!fp) {
%>
	d = f.vwctd;
	d.isFloat = true;
	d.eName ="Value ofWork Completed to Date";
<%
}
%>
	d = f.invoice_num;
	d.required = true;
	d.eName = "Invoice #";
	
	d = f.ptd;
	d.isFloat = true;
	d.eName ="Less Previous Gross Billings";
	
	d = f.ret;
	d.isFloat = true;
	d.eName ="Less this Month's Retention";
</script>
</body>
</html>

