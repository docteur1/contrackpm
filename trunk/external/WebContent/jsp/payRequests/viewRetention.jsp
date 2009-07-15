<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.FormHelper" %>
<%@page import="java.sql.ResultSet, java.sql.Statement, java.text.SimpleDateFormat, java.text.DecimalFormat, java.util.Date" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="contractDisable" value="true" />
	<jsp:param name="printDisable" value="true" />
	<jsp:param name="action" value="../payRequests/processViewRetention.jsp"/>
	</jsp:include>
<%
db.connect();
String pr_id = request.getParameter("pr_id");
String query = "select opr.opr_id, period, request_num, date_approved, date_paid, "
	+ "pr.contract_id, pr.lien_waiver, paid_by_owner, external_comments  from pay_requests as pr, owner_pay_requests as opr, contracts, "
	+ "company where contracts.company_id = company.company_id and "
	+ "pr.contract_id = contracts.contract_id and opr.opr_id = pr.opr_id and pr.pr_id = " + pr_id;
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
String contract_id = null;
String period = "ERROR";
String paid_by_owner = "ERROR";
String lien_waiver = "ERROR";
Date approved = null;
int request_num = 1;
String date_approved = "ERROR";
String date_paid = "ERROR";
String external_comments = "";
SimpleDateFormat sdf = new SimpleDateFormat("MMM yyyy");
ResultSet attach = db.getStatement().executeQuery("select count(*) from files where type='PR' and id = '" 
		+ pr_id + "'");
int attachments = 0;
if (attach.next()) attachments = attach.getInt(1);
if (attach != null) attach.getStatement().close();
double contract = 0;
float co, ptd, ret;
if (rs.next()) {
	period = rs.getString("period");
	request_num = rs.getInt("request_num");
	contract_id = rs.getString("contract_id");
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
		date_approved = "Not Approved";
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
<style>
	.money {
		text-align: right;
		width: 90px;
	}
</style>
	<input type="hidden" name="pr_id" value="<%= pr_id %>">
<font size="+1">Pay Request</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">Pay Requests</a> &gt; Pay Request
 &nbsp; <a href="javascript: openWin('../utils/upload.jsp?type=PR&id=<%= pr_id %>');">
 	<% if (attachments > 0) out.print("<b>Attachments(" + attachments + ")</b>"); else out.print("Attachments"); %></a>
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
			<td><%= request_num %></td>
			<td class="lbl">Date Approved:</td>
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
DecimalFormat df = new DecimalFormat("#,##0.00");
%>
<p>
<fieldset>
	<legend><b>Contract Retention</b></legend>
<%
	ResultSet rs2;
	Statement stmt2 = db.getStatement();
	query = "select amount from contracts where contract_id = " + contract_id;
	rs2 = stmt2.executeQuery(query);
	if (rs2.next()) contract = rs2.getDouble(1);
	if (rs2 != null) rs2.close();
	rs2 = null;
%>
	<table width="100%">
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
			<td class="lbl">Approved Change Orders:</td>
			<td align="right">+$</td>
			<td align="right"><%= df.format(co) %></td>
		</tr>
		<tr>
			<td class="lbl">Final Contract Amount:</td>
			<td align="right">=$</td>
			<td align="right"><%= df.format(contract + (double) co) %></td>
		</tr>
<%
	query = "select sum(paid) as ptd from pay_requests as pr, owner_pay_requests as opr where "
		+ "pr.opr_id = opr.opr_id and period != '" + period + "' and contract_id = " + db.contract_id;
	rs2 = stmt2.executeQuery(query);
	ptd = 0;
	if (rs2.next()) ptd = rs2.getFloat(1);
	if (rs2 != null) rs2.close();
	rs2 = null;
	// If we didn't get anything try the accounting database information
%>
		<tr>
			<td class="lbl">Paid to Date:</td>
			<td align="right">$</td>
			<td align="right"><%= df.format(ptd) %></td>
		</tr>
<%
query = "select sum(adj_retention) as ptd from pay_requests as pr, owner_pay_requests as opr where "
	+ "pr.opr_id = opr.opr_id and contract_id = " + db.contract_id;
rs2 = stmt2.executeQuery(query);
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
	</table>
</fieldset>
</td>
<td style="width: 350px;" valign="top">
<b><u>Notes</u></b>
<p style="margin-left: 15px; margin-top: 2pt;">On projects with mutilple subprojects (i.e. tenant improvements) costs are broken out by
	every subproject listed.</p>
<p style="margin-left: 15px; margin-top: 2pt;">"Paid To Date" is the amount paid to you to date. If final payment has not been made 
	"Final Contract Amount" - "Paid To Date" will not equal "Retention."</p>
<p style="margin-left: 15px; margin-top: 2pt;">Please upload any supporting documentation by clicking <i>Attachments</i> link above.
	If you do not have digital copies of these documents please mail or fax them to our offices.
	</p>
</td>
</tr>
<tr>
<td height="100%" valign="bottom">
<fieldset>
	<legend><b>Comments</b></legend>
	<textarea style="width: 100%;" rows="4" name="external_comments"><%= FormHelper.string(external_comments) %></textarea>
</fieldset>
</td>
</tr>
</table>
</form>
<script language="javascript">
	var m = document.main;
</script>
</body>
</html>
<%
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
if (stmt2 != null) stmt2.close();
stmt2 = null;
db.disconnect();
%>

