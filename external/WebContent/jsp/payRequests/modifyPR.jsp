<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.Widgets, java.sql.ResultSet, java.sql.Statement, java.text.SimpleDateFormat, java.text.DecimalFormat, java.util.Date" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="contractDisable" value="true" />
	<jsp:param name="saveDisable" value="true" />
	</jsp:include>
<%
db.connect();
String pr_id = request.getParameter("pr_id");
String query = "select opr.*, pr.*, amount, retention_rate from pay_requests as pr join owner_pay_requests as "
	+ "opr using(opr_id) join contracts using(contract_id) where pr.pr_id = " + pr_id;
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
String period = "ERROR";
String paid_by_owner = "ERROR";
String lien_waiver = "ERROR";
Date approved = null;
int request_num = 1;
String date_approved = "ERROR";
String date_paid = "ERROR";
String external_comments = "";
String invoice_num = "ERROR";
boolean fp = false;
boolean locked = true;
SimpleDateFormat sdf = new SimpleDateFormat("MMM yyyy");
float retention = 0;
double contract = 0, subtotal = 0, adj_subtotal = 0;
float co = 0, vow = 0, adj_vow = 0, ptd = 0, adj_ptd = 0, ret = 0, adj_ret = 0, paid = 0;
if (rs.next()) {
	locked = rs.getBoolean("locked");
	co = rs.getFloat("co");
	vow = rs.getFloat("value_of_work");
	adj_vow = rs.getFloat("adj_value_of_work");
	ptd = rs.getFloat("previous_billings");
	adj_ptd = rs.getFloat("adj_previous_billings");
	ret = rs.getFloat("retention");
	adj_ret = rs.getFloat("adj_retention");
	paid = rs.getFloat("paid");
	retention = rs.getFloat("retention_rate");
	invoice_num = rs.getString("invoice_num");
	period = rs.getString("period");
	fp = rs.getBoolean("final");
	request_num = rs.getInt("request_num");
	external_comments = rs.getString("external_comments");
	lien_waiver = rs.getString("lien_waiver");
	sdf.applyPattern("d MMM yyyy");
	try {
		paid_by_owner = sdf.format(rs.getDate("paid_by_owner"));
	} catch (NullPointerException e) {
		paid_by_owner = "No Payment Recorded";
	}
	try {
		approved = rs.getDate("date_approved");
		date_approved = sdf.format(approved);
	} catch (NullPointerException e) { 
		date_approved = "Not Accepted";
	}
	sdf.applyPattern("d MMM yyyy");
	try {
		date_paid = sdf.format(rs.getDate("date_paid"));
	} catch (NullPointerException e) { 
		date_paid = "Not Paid";
	}
}
if (rs != null) rs.close();
rs = null;
%>
<script language="javascript">
	var fp = <%= fp %>;
<%
if (fp) out.print("var printName = \"prFinal.pdf?id=" + pr_id + "\";");
else out.print("var printName = \"prMonth.pdf?id=" + pr_id + "\";");
%>
</script>
<script language="javascript" src="../scripts/pr.js"></script>
<style>
	.money {
		text-align: right;
		width: 90px;
	}
</style>
	<input type="hidden" name="pr_id" value="<%= pr_id %>">
<font size="+1">Pay Request</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">Pay Requests</a> &gt; Pay Request
 &nbsp; <%= Widgets.attachments(pr_id, "PR", db) %>
<hr>
&nbsp;<br>
<table>
<tr>
<td rowspan="2">
<fieldset>
	<legend><b>Pay Request Information</b></legend>
	<table width="100%">
		<tr>
			<td class="lbl">Period:</td>
			<td><%= period %></td>
			<td class="lbl">Paid by Owner:</td>
			<td><%= paid_by_owner %></td>
		</tr>
		<tr>
			<td class="lbl" nowrap>Request #:</td>
			<td><input type="hidden" name="request_num" value="<%= request_num %>"><%= request_num %></td>
			<td class="lbl">Date Accepted:</td>
			<td style="padding: 0px;"><%= date_approved %></td>
		</tr>
		<tr>
			<td class="lbl">Lien Waiver:</td>
			<td><%= lien_waiver %></td>
			<td class="lbl">Date Paid:</td>
			<td><%= date_paid %></td>
		</tr>
	</table>
</fieldset>
<%
rs = stmt.executeQuery(query);
ResultSet rs2 = null;
Statement stmt2 = db.getStatement();
DecimalFormat df = new DecimalFormat("0000");
DecimalFormat percent = new DecimalFormat("0.0#");
df.applyPattern("#,##0.00");
%>
<p>
<fieldset>
	<legend><b>Invoice Information</b></legend>
<%
contract = 0;
query = "select amount from contracts where contract_id = " + db.contract_id;
rs2 = stmt2.executeQuery(query);
if (rs2.next()) contract = rs2.getDouble(1);
if (rs2 != null) rs2.close();
rs2 = null;
%>
	<table width="100%">
		<tr>
			<td class="lbl">Invoice Number</td>
			<td colspan="4"><input type="text" name="inv_num" value="<%= invoice_num %>"></td>
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
			<td class="lbl"><% if (fp) out.print("Final"); else out.print("Adjusted"); %> Contract Amount:</td>
			<td align="right">=$</td>
			<td align="right"><%= df.format(contract + (double) co) %></td>
		</tr>
<%
	if (!fp) {
%>
		<tr>
			<td class="lbl">Value of Work Completed to Date:</td>
			<td align="right">$</td>
			<td align="right" style="padding: 0px;"><input type="text" class="money" name="vwctd" value="<%= df.format(vow) %>" onChange="subtotal();"></td>
			<td align="right">$</td>
			<td align="right"><%= df.format(adj_vow) %></td>
		</tr>
<%
	}
%>
		<tr>
			<td class="lbl">Less Previous Gross Billings:</td>
			<td align="right">-$</td>
			<td align="right" style="padding: 0px;"><input type="hidden" name="ptd" value="<%= ptd %>">
				<input type="hidden" name="con" value="<%= contract + (double) co %>"><div id="dptd"><%= df.format(ptd) %>
				</div></td>
			<td align="right">-$</td>
			<td align="right"><%= df.format(adj_ptd) %></td>
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
			<td align="right" style="padding: 0px;"><input type="hidden" name="ret" value="<%= ret %>">
				<div id="dret"><%= df.format(ret) %></div></td>
			<td align="right">-$</td>
			<td align="right"><%= df.format(adj_ret) %></td>
		</tr>
		<tr>
			<td class="lbl"><% if (fp) out.print("Final Amount Due"); else out.print("Amount Due This Pay Period"); %>:</td>
			<td align="right">=$</td>
			<td align="right"><div id="due"><%= df.format(subtotal - (double) ret) %></div></td>
			<td align="right">=$</td>
			<td align="right"><div id="adjdue"><%= df.format(adj_subtotal - (double) adj_ret) %></div></td>
		</tr>
		<tr>
			<td class="lbl">Amount Paid:</td>
			<td align="right">$</td>
			<td align="right"><%= df.format(paid) %></td>
			<td colspan="2">&nbsp;</td>
		</tr>
	</table>
</fieldset>
</td>
<td style="width: 350px;" valign="top">
<b><u>Notes</u></b>
<p style="margin-left: 15px; margin-top: 2pt;">The <i>Revised</i> column contains the adjustments made by <%= db.get("short_name") %> employees.
	Please contact the project manager to discuss any discrepancies. These are the values that appear on the printed report.
	Initially these values are set by the values entered on the "New Pay Request" form.</p>
<p style="margin-left: 15px; margin-top: 2pt;">Payment status in show in <u>Pay Request Information</u> secion. Likewise, the total amount paid
	(the amount of the cut check) is shown in <i>Amount Paid</i>. To be eligible for payment you must have already submitted an official invoice 
	and a signed pay request (available by clicking <i>Print</i>).</p>
<p style="margin-left: 15px; margin-top: 2pt;">Please upload any supporting documentation including the signed Pay Request and an electronic copy of the invoice by clicking the <i>Attachments</i> link above.
	If you do not have digital copies of these documents please mail or fax them to our offices.</p>
</td>
</tr>
<tr>
<td height="100%" valign="bottom">
<fieldset>
	<legend><b>Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="external_comments"><%= external_comments %></textarea>
</fieldset>
</td>
</tr>
</table>
</form>
<script language="javascript">
	var m = document.main;
<%
if (!locked) {
%>
	m.action = "processModifyPR.jsp";
	document.getElementById("sBt").disabled = false;
<%
}
if (!fp) {
%>
	var d = m.vwctd;
	d.isFloat = true;
	d.eName ="Orginal Value of Work Completed to Date";
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
</body>
</html>

