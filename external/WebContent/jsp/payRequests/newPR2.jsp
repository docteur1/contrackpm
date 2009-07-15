<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.Statement, java.text.SimpleDateFormat, java.text.DecimalFormat" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="contractDisable" value="true" />
	<jsp:param name="action" value="../payRequests/processPR.jsp"/>
	</jsp:include>
<%
db.connect();
Statement stmt = db.getStatement();
String opr_id = request.getParameter("opr_id");
SimpleDateFormat sdf = new SimpleDateFormat("MMM yyyy");
String query = "select period, paid_by_owner from owner_pay_requests where opr_id = " + opr_id;
ResultSet rs = stmt.executeQuery(query);
String period = "ERROR";
String paid_by_owner = "ERROR";
double co = 0, ptd = 0, retention = 0, final_ret = 0;
if (rs.next()) {
	period = rs.getString("period");
	sdf.applyPattern("d MMM yyyy");
	try {
		paid_by_owner = sdf.format(rs.getDate("paid_by_owner"));
	} catch (NullPointerException e) {
		paid_by_owner = "No payment recorded";
	}
}
boolean fp = request.getParameter("final") != null;
if (rs != null) rs.close();
rs = null;
query = "select max(request_num) as new_request_num from pay_requests where contract_id = " + db.contract_id;
int request_num = 1;
rs = stmt.executeQuery(query);
if (rs.next()) request_num = rs.getInt(1) + 1;
if (rs != null) rs.close();
rs = null;
if (fp) out.println("<input type=\"hidden\" name=\"final\" value=\"y\">");
%>
	<script language="javascript">
		var fp = <%= fp %>;
	</script>
	<script language="javascript" src="../scripts/pr.js"></script>
	<style>
		.money {
			text-align: right;
			width: 90px;
		}
	</style>
	<input type="hidden" name="opr_id" value="<%= opr_id %>">
	<input type="hidden" name="period" value="<%= period %>">
<font size="+1">New Pay Request</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">Pay Requests</a> &gt; New Pay Request<hr>
&nbsp;<br>
<table>
<tr>
<td valign="top">
<fieldset style="width: 350px;">
	<legend><b>Pay Request Information</b></legend>
	<table>
		<tr>
			<td class="lbl">Period:</td>
			<td><%= period %></td>
		</tr>
		<tr>
			<td class="lbl">Paid by Owner:</td>
			<td><%= paid_by_owner %></td>
		</tr>
		<tr>
			<td class="lbl" nowrap>Request #:</td>
			<td><input type="hidden" name="request_num" value="<%= request_num %>"><%= request_num %>
				<%= fp ? " - FINAL" : "" %></td>
		</tr>
	</table>
</fieldset>
<%
Statement stmt2 = db.getStatement();
ResultSet rs2 = null;
DecimalFormat df = new DecimalFormat("0000");
DecimalFormat percent = new DecimalFormat("0.0#");
df.applyPattern("#,##0.00");
double contract = 0, subtotal = 0;
%>
<p>
<fieldset style="width: 350px;">
	<legend>Invoice Details</legend>
<%
	contract = 0;
	query = "select amount, retention_rate from contracts where contract_id = " + db.contract_id;
	rs2 = stmt2.executeQuery(query);
	if (rs2.next()) {
		contract = rs2.getDouble(1);
		retention = rs2.getDouble(2);
	}
	if (rs2 != null) rs2.close();
	rs2 = null;
%>
	<table width="100%">
		<tr>
			<td class="lbl">Invoice #:</td>
			<td style="padding: 0px;" colspan="2"><input type="text" name="inv_num" value="" maxlength="20"></td>
		</tr>
		<tr>
			<td class="lbl">Original Contract Amount:</td>
			<td align="right">$</td>
			<td align="right"><%= df.format(contract) %></td>
		</tr>
<%
	query = "select amount from change_request_detail where authorization = 1 and contract_id = " + db.contract_id;
	rs2 = stmt2.executeQuery(query);
	co = 0;
	if (rs2.next()) co = rs2.getFloat(1);
	if (rs2 != null) rs2.close();
	rs2 = null;
%>
		<tr>
			<td class="lbl">Change Authorizations:</td>
			<td align="right">+$</td>
			<td align="right"><%= df.format(co) %><input type="hidden" name="co" value="<%= co %>"></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final"); else out.print("Adjusted"); %> Contract Amount:</td>
			<td align="right">=$</td>
			<td align="right"><%= df.format(contract + (double) co) %><input type="hidden" name="con" value="<%= contract + (double) co %>"></td>
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
	sdf.applyPattern("yyyy-MM-dd");
	query = "select sum(adj_value_of_work - adj_previous_billings) as ptd from pay_requests as pr, owner_pay_requests as opr where "
		+ "pr.opr_id = opr.opr_id and period != '" + period + "' and contract_id = " + db.contract_id;
	rs2 = stmt2.executeQuery(query);
	ptd = 0;
	if (rs2.next()) ptd = rs2.getFloat(1);
	if (rs2 != null) rs2.close();
	rs2 = null;
	if (fp) subtotal = contract + (double) (co - ptd);
	else subtotal = 0;
%>
		<tr>
			<td class="lbl">Less Previous Gross Billings:</td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="hidden" name="ptd" value="<%= ptd %>"><div id="dptd"><%= df.format(ptd) %></div></td>
		</tr>
		<tr>
			<td class="lbl">SUBTOTAL (<% if (fp) out.print("Final Billing"); else out.print("This Month's Billing"); %>):</td> <!-- ' -->
			<td align="right">=$</td>
			<td align="right"><div id="subtotal"><%= df.format(subtotal) %></div></td>
		</tr>
<%
	final_ret = 0;
	if (fp) final_ret = subtotal * retention;
%>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Retention (" + percent.format(retention*100) + "%)"); else out.print("Less this Month's Retention (" + percent.format(retention*100) + "%)"); %>:
				<input type="hidden" name="rate" value="<%= retention %>"></td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="hidden" name="ret" value="<%= final_ret %>"><div id="dret"><%= df.format(final_ret) %></div></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Amount Due"); else out.print("Amount Due This Pay Period"); %>:</td>
			<td align="right">=$</td>
			<td align="right"><div id="due"><%= df.format(subtotal - (double) final_ret) %></div></td>
		</tr>
	</table>
</fieldset>
</td>
<td style="width: 350px;" valign="top" rowspan="2">
<b><u>Instructions</u></b>
<ol style="margin-top: 2pt; margin-bottom: 2pt;">
	<li>Failure to correctly complete this form may result in delayed payment.</li>
	<li>You are <u>required</u> to enter the invoice number of the invoice that <u>must</u> be submitted with this pay request.</li>
<%
if (!fp) out.print("<li><i>Approved Change Orders</i> is the <u>current</u> "
	+ "approved change to the orginal contract. <i>Adjusted Contract Amount</i> represents orginal contract plus approved changes.</li>");
else out.print("<li><i>Approved Change Orders</i> is the <u>current</u> "
	+ "approved change to the orginal contract. All "
	+ "negotiated changes to <i>Adjusted Contract Amount</i> need to be finalized before requesting final payment</li>");
if (!fp) out.print("<li>Input <i>Value of Work Completed to Date</i>. This should approximate the amount spent on labor and materials "
	+ "from the beginning of the contract until the end of this billing period.");
%>
	<li>The total amount previously paid, according to our records, is indicated in <i>Less Previous Gross Billings</i>.</li>
<%
if (!fp) out.print("<li>The amount of retention held on the pay request is shown in <i>Less this Month's Retention</i> "
	+ "and is automatically calculated according to the shown percentage as dictacted by our contract documents or applicable law.</li>");
else out.print("<li>The amount of retention held for the final pay period, is indicated in <i>Final Retention</i>.</li>");
%>
	<li>The totals will automatically update as you enter your data. If desired, enter any comments that will be useful when this pay request
		is evaluated for payment (i.e. "This pay request covers change orders only").</li>
	<li>When finished, click the Save button. Print, sign, and send the generated report and supporting documentation to our office or you can upload your documents directly after clicking <i>Save</i> by clicking the <i>Attachments</i> link.</li>
</ol>
</td>

</tr>
<tr>
<td height="100%" valign="bottom">
<fieldset>
	<legend><b>Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="external_comments"></textarea>
</fieldset>
</td>
</tr>
</table>
<form>
<script language="javascript">
	var m = document.main;
	var d;
<%
if (!fp) {
%>
	d = m.vwctd;
	d.isFloat = true;
	d.eName ="Value of Work Completed to Date";
<%
}
%>
	d = m.inv_num;
	d.required = true;
	d.eName = "Invoice Number";
<%
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
if (stmt2 != null) stmt2.close();
stmt2 = null;
db.disconnect();
%>
</script>
</td>
</tr>
</table>
</body>
</html>

