<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String company_id = request.getParameter("company_id");
String contact_id = request.getParameter("contact_id");
String query = "select company_name, safety_manual from company where company_id = " + company_id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String company_name = "ERROR", name = "ERROR";
boolean safety = false;
int strikes = 0;
if (rs.first()) {
	company_name = rs.getString("company_name");
	safety = rs.getString("safety_manual") != null && rs.getString("safety_manual").equals("y");
}
if (rs != null) rs.getStatement().close();
if (contact_id != null) {
	query = "select name from contacts where contact_id = " + contact_id;
	rs = db.dbQuery(query);
	if (rs.first()) name = rs.getString("name");
	if (rs != null) rs.getStatement().close();
}
double ret = 0.05;
query = "select retention_rate from job where job_id = " + attr.getJobId();
rs = db.dbQuery(query);
if (rs.first()) ret = rs.getDouble(1);
if (rs != null) rs.getStatement().close();

query = "select count(*) from company_comments where strike = 1 and company_id = " + company_id;
rs = db.dbQuery(query);
if (rs.first()) strikes = rs.getInt(1);
if (rs != null) rs.getStatement().close();

query = "select letter from cost_types where contractable = 1";
rs = db.dbQuery(query);
query = "select cost_code_id, division, cost_code, phase_code, code_description from job_cost_detail "
	+ "where job_id = " + attr.getJobId();
if (rs.isBeforeFirst()) {
	query += " and (";
	while (rs.next()) {
		if (rs.isFirst()) query += "phase_code	= '" + rs.getString("letter") + "' ";
		else query += "or phase_code	= '" + rs.getString("letter") + "' ";
	}
	query += ")";
}
if (rs != null) rs.getStatement().close();
query += " order by costorder(division), costorder(cost_code), phase_code";
rs = db.dbQuery(query);
%>

<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="../utils/spell.js"></script>
	<script language = "javascript">
		function spell() {
			spellCheck(document.contract);
		}
		var strikes = <%= strikes %>;
		function aEdit() {
			msgWindow=window.open('','aEdit','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=500,left=25,top=25');
			msgWindow.location.href = "textarea.jsp?id=contract";
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function checkStrikes() {
			if(strikes > 0) {
				if(confirm("The selected subcontractor has <%= strikes %> strike(s).\n\nContinue?")) {
					strikes = 0;
					save();
				}
			} else save();
		}
		function save() {
			if(checkForm(document.contract)) document.contract.submit();
		}
		parent.left.location="newContractLeft2.jsp";
	</script>
	<script language="javascript" src="../utils/calendar.js"></script>
</head>
<body>
<form name="contract" action="processContract.jsp" method="POST" onSubmit="return checkForm(this)">
<font size="+1">New Contract</font><hr>
<%
if (request.getParameter("msg") != null) out.print("<div class=\"red bold\">Accounting: " + request.getParameter("msg") + ". This contract will not be created in accounting. "
	+ "<div class=\"link\" onclick=\"window.alert('HELP\\n--------------\\nThe accounting database does not contain the selected company.\\nTherefore the contract will not be created in the accounting\\n"
	+ "database. Please consulting check with the accounting department \\nfor more information.');\">More Info</div></div><hr>");
%>
<table>

	<tr>
		<td align="right"><b>Company: </b></td>
		<td colspan="3"><%= company_name %>
<%
if (contact_id != null) out.print(" - " + name + "<input type=\"hidden\" name=\"contact_id\" value=\"" + contact_id + "\">");
if (strikes > 0) out.print(" - <font color=\"red\"><b>" + strikes + " strikes</b>");
%>
			<input type="hidden" name="company_id" value="<%= company_id %>"></td>
	</tr>
	<tr><td align="right"><b>Phase: </b></td>
    <td align="left" colspan="3">
			<select name="cost_code_id">
<%
while (rs.next()){
%>
		<option value="<%= rs.getString("cost_code_id") %>">
			<%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") + ": " + rs.getString("code_description") %></option>
<%
} 
if (rs != null) rs.close(); 
rs = null;
db.disconnect();
%>
		</select></td></tr>

<tr><td align="right"><b><a href="javascript:insertDate('agreementDate')">Agreement Date:</a></b></td>
    <td colspan="3">
		<input type="text" id="agreementDate" name="agreementDate" maxlength=10 size=8 value="">
						<img id="calagreementDate" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		</tr>

<tr>
	<td align="right"><b><a href="javascript:insertDate('dateSent')">Date Sent:</a></b></td>
    <td colspan="3"><input type="text" id="dateSent" name="dateSent" maxlength=10 size=8 value="">
		<img id="caldateSent" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
</tr>
<tr>
	<td align="right"><b><a href="javascript:insertDate('dateReceived')">Date Received:</a></b></td>
    <td colspan="3"><input type="text" id="dateReceived" name="dateReceived" maxlength=10 size=8 value="">
		<img id="caldateReceived" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
</tr>

		<tr><td align="right"><b>Contract Amount:</b></td>
	<td align="left"><input size=8 type="text" name="amount" value="0.00"></td>
	<td align="right"><b>Retention Rate:</b></td>
	<td><input type="text" size="8" name="retention_rate" value="<%= FormHelper.per(ret*100) %>"></td>

		<tr><td align="right"><b><a href="javascript: aEdit()">Description:</a></b></td>

    <td align="left" colspan="3"><textarea name="description" rows=4 cols=55></textarea></td></tr>
  </table>
<fieldset>
<legend>Requirements</legend>
 <table>
<tr>
	<td align="right"><b>Submittal Required: </b></td><td><input type="checkbox" name="submittal_required" value="y"></td>
	<td colspan="2"><b>Have Safety Manual: </b><input type="checkbox" value="y" name="safety_manual" <% if (safety) out.print("checked"); %>></td>
	</tr>
<tr><td align="right"><b>Proof of Insurance: </b></td><td><input type="checkbox" name="insurance_proof" value="y"></td>
<td align="right"><b>Expiration: </b></td><td><input type="text" size="8" maxlength="10" name="insExpire" id="insExpire">
		<img id="calinsExpire" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
		</td></tr>

<tr><td align="right"><b>Proof of Workers Comp: </b></td><td align="left"><input type="checkbox" name="workers_comp_proof" value="y"></td>
<td align="right"><b>Expiration: </b></td><td><input type="text" size="8" maxlength="10" name="wkComp" id="wkComp">
						<img id="calinsExpire" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
		</td></tr>
</table>
</fieldset>
<fieldset>
<legend>Tracking Information</legend>
<table>
		<tr><td align="right"><b>O & M Submittals: </b></td><td align="left">
		Need:<input type="checkbox" name="req_tech_submittals" value="y">Have:<input type="checkbox" name="have_tech_submittals" value="y"></td></tr>
		<tr><td align="right"><b>Warranty:</b></td><td align="left">
		Need:<input type="checkbox" name="req_warranty" value="y">Have:<input type="checkbox" name="have_warranty" value="y"></td></tr>
		<tr><td align="right"><b>Owner Training:</b></td><td align="left">
		Need:<input type="checkbox" name="req_owner_training" value="y">Have:<input type="checkbox" name="have_owner_training" value="y"></td></tr>
		<tr><td align="right"><b>Lien Release:</b></td><td align="left">
		Have:<input type="checkbox" name="have_lien_release" value="y"></td></tr>
		<tr><td align="right"><b>Specialty Items:</b></td><td align="left"><textarea name="req_specialty" rows=3 cols=55></textarea></td><td align="left" valign="middle"> Have:<input type="checkbox" name="have_specialty" value="y"></td></tr>
		<tr><td align="right"><b>Tracking Notes:</b></td><td align="left"><textarea name="tracking_notes" rows=3 cols=55></textarea></td></tr>

</table>
</fieldset>
<script language="javascript">
	var f = document.contract;
	f.description.spell = true;
	f.cost_code_id.focus();
	
	var d = f.agreementDate;
	d.required = true;
	d.isDate = true;
	d.eName = "Agreement Date";
	
	d = f.dateSent;
	d.isDate = true;
	d.eName = "Date Sent";
	
	d = f.dateReceived;
	d.isDate = true;
	d.eName = "Date Received";
	
	d = f.amount;
	d.isFloat = true;
	d.required = true;
	d.eName = "Contract Amount";
	
	d = f.insExpire;
	d.isDate = true;
	d.eName = "Insurance Expiration";
	
	d = f.wkComp;
	d.isDate = true;
	d.eName = "Worker's Comp Expiration";
	
	d = f.retention_rate;
	d.isFloat = true;
	d.eName = "Retention Rate";
	
</script>
</form>
</body></html>

