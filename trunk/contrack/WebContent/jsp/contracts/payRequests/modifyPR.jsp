<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security, java.sql.ResultSet, com.sinkluge.utilities.FormHelper, java.text.SimpleDateFormat, java.text.DecimalFormat, java.util.Date" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String pr_id = request.getParameter("pr_id");
String query = "update pay_requests set e_update = 0 where pr_id = " + pr_id;
Database db = new Database();
db.dbInsert(query);
query = "select retention_rate as rate, paid_by_owner, period, division, cost_code, phase_code, code_description, "
	+ "company_name, pr.*, amount from pay_requests as pr, owner_pay_requests as opr, contracts, job_cost_detail as jcd, "
	+ "company where contracts.company_id = company.company_id and jcd.cost_code_id = "
	+ "contracts.cost_code_id and pr.contract_id = contracts.contract_id and "
	+ "opr.opr_id = pr.opr_id and pr.pr_id = " + pr_id;
ResultSet rs = db.dbQuery(query);
DecimalFormat percent = new DecimalFormat("0.0#");
DecimalFormat df = new DecimalFormat("#,##0.00");
String contract_string = "ERROR";
String cost_code = null;
String phase_code = null;
String contract_id = null;
String period = "ERROR";
String lw = "ERROR";
String paid_by_owner = "ERROR";
boolean owner_payment = false;
Date approved = null;
int request_num = 1;
String date_approved = "ERROR", date_approved_form = "";
String date_paid = "ERROR", date_paid_form = "";
String ref_num = "ERROR";
int voucher_num = 0;
String internal_comments = "";
String external_comments = "";
boolean ext_created = false;
boolean fp = false;
boolean retPeriod = false;
double retention = 0, contract = 0;
SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy");
SimpleDateFormat sdf_form = new SimpleDateFormat("MM/dd/yyyy");
if (rs.next()) {
	retention = rs.getDouble("rate");
	cost_code = rs.getString("cost_code");
	phase_code = rs.getString("phase_code");
	contract_string = cost_code + "-" + phase_code + " " + rs.getString("company_name") + ": "
		+ rs.getString("code_description");
	request_num = rs.getInt("request_num");
	contract_id = rs.getString("contract_id");
	period = rs.getString("period");
	lw = rs.getString("lien_waiver");
	fp = rs.getBoolean("final");
	retPeriod = "Retention".equals(period);
	ref_num = rs.getString("ref_num");
	voucher_num = rs.getInt("account_id");
	internal_comments = rs.getString("internal_comments");
	external_comments = rs.getString("external_comments");
	if (ref_num == null) ref_num = "";
	try {
		paid_by_owner = sdf.format(rs.getDate("paid_by_owner"));
		owner_payment = true;
	} catch (NullPointerException e) {
		paid_by_owner = "No payment recorded";
		owner_payment = false;
	}
	try {
		approved = rs.getDate("date_approved");
		date_approved_form = sdf_form.format(approved);
		date_approved = sdf.format(approved);
	} catch (NullPointerException e) { 
		date_approved = "Not Approved";
		date_approved_form = "";
	}
	sdf.applyPattern("d MMM yyyy");
	try {
		date_paid_form = sdf_form.format(rs.getDate("date_paid"));
		date_paid = sdf.format(rs.getDate("date_paid"));
	} catch (NullPointerException e) { 
		date_paid = "Not Paid";
		date_paid_form = "";
	}
	ext_created = rs.getBoolean("ext_created");
%>
<html>
<head>
	<link href="../../stylesheets/v2.css" rel="stylesheet" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../../utils/jsonrpc.js"></script>
	<script>
		function save() {
<%
	if (attr.hasAccounting()) {
		JSONRPCBridge.registerClass("accounting", com.sinkluge.JSON.AccountingJSON.class);
		out.println("if (checkVoucher(" + pr_id + ") && checkForm(f)) {");
	} else out.println("if (checkForm(f)) {");
%>
				f.submit();
				return true;
			} else return false;
		}
		var cFormName = "document.pr";
		var owner_payment = <%= owner_payment %>;
		var approved = <%= approved != null %>; 
		var fp = <%= fp %>;
		function openWin(loc) {
			win = window.open(loc,"docs","directories=no,height=300,width=500,left=25,location=no,menubar=no,top=25,resizable=yes,status=no,scrollbars=yes");
			if (win.opener == null) opener = self;
			win.focus();
		}
		function ptdHelp() {
			window.alert("Paid to Date\n------------------------\n"
				+ "This is the amount that actually has been paid to date.\n"
				+ "It is here for reference only and is not used in calculations.\n"
				+ "The retention is unaffected by this amount.");
		}
	</script>
	<script language="javascript" src="scripts/modify_pr.js"></script>
	<script language="javascript" src="../../utils/verify.js"></script>
	<script language="javascript" src="../../utils/calendar.js"></script>
	<style>
		.money {
			text-align: right;
			width: 90px;
		}
	</style>
</head>
<body>
<form name="pr" action="processModifyPR.jsp" method="POST" onsubmit="return save();">
	<input type="hidden" name="pr_id" value="<%= pr_id %>">
<font size="+1">Modify Pay Request</font><hr>
<%
if (request.getParameter("saved") != null) out.print("<font color=\"red\"><b>Saved</b></font><hr>");
%>
<fieldset>
	<legend><b>Pay Request Information</b></legend>
	<table>
		<tr>
			<td class="lbl">Contract:</td>
			<td colspan="3"><%= contract_string %></td>
		</tr>
		<tr>
			<td class="lbl">Period:</td>
			<td><%= period + (fp ? " - FINAL" : "") %></td>
			<td class="lbl">Paid by Owner:</td>
			<td><%= paid_by_owner %></td>
		</tr>
		<tr>
			<td class="lbl" nowrap>Request #:</td>
			<td><input type="hidden" name="request_num" value="<%= request_num %>"><%= request_num %></td>
			<td class="lbl">
<%
if (sec.ok(sec.APPROVE_PAYMENT, sec.WRITE)) out.print("<a href=\"javascript: insertDate('date_approved');\">Date Accepted:</a></td>");
else out.print("Date Accepted:");
%>
				</td>
			<td style="padding: 0px;">
<%
if (sec.ok(sec.APPROVE_PAYMENT, sec.WRITE)) {
%>
				<input type="text" id="date_approved" name="date_approved" value="<%= date_approved_form %>" maxlength="10" size="8">
				<img id="caldate_approved" src="../../images/calendar.gif" border="0"> - mm/dd/yyyy
<%
} else out.print(date_approved);
%>
			</td>
		</tr>
		<tr>
			<td class="lbl">External:</td>
			<td style="padding: 0px;">
<%
if (ext_created) out.print(" &nbsp; &nbsp; <img src=\"../../images/checkmark.gif\">");
else out.print("&nbsp;");
%>
				</td>
<%
if (sec.ok(sec.PENDING_CO, sec.WRITE)) {
%>
			<td class="lbl"><a href="javascript: insertDate('date_paid');">Date Paid:</a></td>
			<td style="padding: 0px;"><input type="text" id="date_paid" name="date_paid" value="<%= date_paid_form %>" maxlength="10" size="8">
				<img id="caldate_paid" src="../../images/calendar.gif" border="0"> - mm/dd/yyyy
<%
} else {
%>
			<td class="lbl">Date Paid:</td>
			<td><%= date_paid %></td>
<%
}
%>
		</tr>
		<tr>
		<td class="lbl">
<%
String vNum = "";
if (voucher_num != 0 && attr.hasAccounting()) {
	vNum = Integer.toString(voucher_num);
	out.println("<a href=\"javascript: openWin('voucherInfo.jsp?id=" + vNum + "');\">Voucher:</a>");
} else out.println("Voucher:");
out.print("</td>");
if (sec.ok(sec.PENDING_CO, sec.WRITE)) {
%>
		<td style="padding: 0px;"><input type="text" name="account_id" value="<%= vNum %>" size="6" onchange="voucherChange=true;"></td>
		<td class="lbl">Ref #:</td>
		<td style="padding: 0px;"><input type="text" name="ref_num" value="<%= ref_num %>"></td>
<%
} else {
%>
		<td><%= vNum %><input type="hidden" name="account_id" value="<%= vNum %>"></td>
		<td class="lbl">Ref #:</td>
		<td><%= ref_num %></td>
<%
}
%>
		</tr>		
		<tr>
			<td class="lbl">Lien Waiver:</td>
			<td><select name="lien_waiver">
					<option <%= lw.equals("Not Required")?"selected":"" %>>Not Required</option>
					<option <%= lw.equals("Requested")?"selected":"" %>>Requested</option>
					<option <%= lw.equals("Filed")?"selected":"" %>>Filed</option>
				</select></td>
			<td class="lbl">ID:</td>
			<td><%= com.sinkluge.utilities.Widgets.logLinkWithId(pr_id, com.sinkluge.Type.PR, 
				"parent", request) %></td>
		</tr>
	</table>
</fieldset>
<%
double subtotal = 0, adj_subtotal = 0;
float co, vow, adj_vow, ptd, adj_ptd, ret, adj_ret, paid;
String inv_num = rs.getString("invoice_num");
contract = rs.getDouble("amount");
%>
<fieldset>
	<legend><b>Pay Request Costs</b></legend>

	<table width="100%">
<%
if (!retPeriod) {
%>
		<tr>
			<td class="lbl">Invoice #:</td>
			<td colspan="4"><input type="text" name="invoice_num" value="<%= inv_num %>" maxlength="70"></td>
		</tr>
<%
}
%>
		<tr>
			<td colspan="3" class="lbl">Orignal</td>
			<td colspan="2" class="lbl">Revised</td>
		</tr>
		<tr>
			<td class="lbl">Original Contract Amount:</td>
			<td align="right">$</td>
			<td align="right"><%= df.format(contract) %></td>
			<td colspan="2" rowspan="3">&nbsp;</td>
		</tr>
<%
	co = rs.getFloat("co");
	vow = rs.getFloat("value_of_work");
	adj_vow = rs.getFloat("adj_value_of_work");
	ptd = rs.getFloat("previous_billings");
	adj_ptd = rs.getFloat("adj_previous_billings");
	ret = rs.getFloat("retention");
	adj_ret = rs.getFloat("adj_retention");
	paid = rs.getFloat("paid");
	if (fp) {
		subtotal = contract + (double) (co - ptd);
		adj_subtotal = contract + (double) (co - adj_ptd);
	}
	else {
		subtotal = vow - ptd;
		adj_subtotal = adj_vow - adj_ptd;
	}
%>
		<tr>
			<td class="lbl">Change Authorizations:</td>
			<td align="right">+$</td>
			<td align="right"><%= df.format(co) %></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp || retPeriod) out.print("Final"); 
				else out.print("Adjusted"); %> Contract Amount:</td>
			<td align="right">=$</td>
			<td align="right"><%= df.format(contract + (double) co) %></td>
		</tr>
<%
	if (!retPeriod) {
		if (!fp) {
%>
		<tr>
			<td class="lbl">Value of Work Completed to Date:</td>
			<td align="right">$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="vwctd" value="<%= df.format(vow) %>" onChange="subtotal();" <% if (ext_created) out.print("readonly"); %>></td>
			<td align="right">$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="adjvwctd" value="<%= df.format(adj_vow) %>" onChange="subadjtotal();"></td>
		</tr>
<%
		}
%>
		<tr>
			<td class="lbl">Less Previous Gross Billings:</td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="ptd" value="<%= df.format(ptd) %>" onChange="subtotal();" <% if (ext_created) out.print("readonly"); %>><input type="hidden" name="con" value="<%= contract + (double) co %>"></td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="adjptd" value="<%= df.format(adj_ptd) %>" onChange="subadjtotal();"></td>
		</tr>
		<tr>
			<td class="lbl">SUBTOTAL (<% if (fp) out.print("Final Billing"); else out.print("This Month's Billing"); %>):</td>
			<td align="right">=$</td>
			<td align="right"><div id="subtotal"><%= df.format(subtotal) %></div></td>
			<td align="right">=$</td>
			<td align="right"><div id="adjsubtotal"><%= df.format(adj_subtotal) %></div></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Retention (" + percent.format(retention*100) + "%)"); else out.print("Less this Month's Retention (" + percent.format(retention*100) + "%)"); %>:
				<input type="hidden" name="rate" value="<%= retention %>"></td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="ret" value="<%= df.format(ret) %>" onChange="retention(false, false);" <% if (ext_created) out.print("readonly"); %>></td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="adjret" value="<%= df.format(adj_ret) %>" onChange="retention(false, true);"></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Amount Due"); else out.print("Amount Due This Pay Period"); %>:</td>
			<td align="right">=$</td>
			<td align="right"><div id="due"><%= df.format(subtotal - (double) ret) %></div></td>
			<td align="right">=$</td>
			<td align="right"><div id="adjdue"><%= df.format(adj_subtotal - (double) adj_ret) %></div></td>
		</tr>	
<%
	} else {
		query = "select sum(paid) as ptd from pay_requests as pr, owner_pay_requests as opr where "
			+ "pr.opr_id = opr.opr_id and period != '" + period + "' and contract_id = " + contract_id;
		ResultSet rs2 = db.dbQuery(query);
		ptd = 0;
		if (rs2.next()) ptd = rs2.getFloat(1);
		if (rs2 != null) rs2.close();
		rs2 = null;
		// If we didn't get anything try the accounting database information
%>
			<tr>
				<td class="lbl">Paid To Date <div class="bold link" onClick="ptdHelp();">?</div>:</td>
				<td align="right">$</td>
				<td align="right"><%= df.format(ptd) %></td>
			</tr><%
		query = "select sum(adj_retention) as ptd from pay_requests as pr, owner_pay_requests as opr where "
			+ "pr.opr_id = opr.opr_id and contract_id = " + contract_id;
		rs2 = db.dbQuery(query);
		ret = 0;
		if (rs2.next()) ret = rs2.getFloat(1);
		if (rs2 != null) rs2.close();
		rs2 = null;	
%>
		<tr>
			<td class="lbl">Retention Due:</td>
			<td align="right">$</td>
			<td align="right"><%= df.format(ret) %></td>
		</tr>
<%
	}
	if (sec.ok(sec.PENDING_CO, sec.WRITE)) {
%>	
		<tr>
			<td colspan="2">&nbsp;</td>
			<td colspan="2" class="lbl"><a href="javascript: insertDue();">Amount Paid:</a></td>
			<td align="right"><input type="text" class="money" name="paid" value="<%= df.format(paid) %>"></td>
		</tr>
<%
	} else {
%>
		<tr>
			<td class="lbl">Amount Paid:</td>
			<td align="right">$</td>
			<td align="right"><%= df.format(paid) %></td>
			<td colspan="2">&nbsp;</td>
		</tr>
<%
	}
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
	</table>
</fieldset>
<fieldset>
	<legend><b>Internal Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="internal_comments"><%= FormHelper.string(internal_comments) %></textarea>
</fieldset>
<fieldset>
	<legend><b>External Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="external_comments"><%= FormHelper.string(external_comments) %></textarea>
</fieldset>
</form>
<script language="javascript">
	var f = document.pr;
	
	var d;
<%
if (sec.ok(sec.APPROVE_PAYMENT, sec.WRITE)) {
%>
	d = f.date_approved;
	d.isDate = true;
	d.eName = "Date Accepted";
<%
}
if (sec.ok(sec.PENDING_CO, sec.WRITE)) {
%>
	
	d = f.date_paid;
	d.isDate = true;
	d.eName = "Date Paid";
	
	d = f.account_id;
	d.isInt = true;
	d.eName = "Voucher #";
	
<%
}
if (!retPeriod) {
	if (!fp) {
%>
	d = f.vwctd;
	d.isFloat = true;
	d.eName ="Orginal Value of Work Completed to Date";

	d = f.adjvwctd;
	d.isFloat = true;
	d.eName ="Revised Value of Work Completed to Date";

<%
	}
%>
	d = f.invoice_num;
	d.required = true;
	d.eName = "Invoice #";
	
	d = f.ptd;
	d.isFloat = true;
	d.eName ="Orginal Less Previous Gross Billings";

	d = f.ret;
	d.isFloat = true;
	d.eName ="Orginal Less this Month's Retention";
	
	
	d = f.adjptd;
	d.isFloat = true;
	d.eName ="Revised Less Previous Gross Billings";

	d = f.adjret;
	d.isFloat = true;
	d.eName ="Revised Less this Month's Retention";
<%
}
if (sec.ok(sec.PENDING_CO, sec.WRITE)) {
%>	
	d = f.paid;
	d.isFloat = true;
	d.eName = "Amount Paid";
<%
}
%>
</script>
</body>
</html>

