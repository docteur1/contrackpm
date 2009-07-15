 <%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<%
int contract_id=Integer.parseInt(request.getParameter("id"));
String agreement_date="", date_sent="", date_received="", gen_insurance_expire="", workers_comp_expire="", insurance_proof, submittal_required, workers_comp_proof;
String safety_manual, req_tech_submittals, have_tech_submittals, req_specialty, have_specialty, req_owner_training, have_owner_training, req_warranty, have_warranty, have_lien_release, tracking_notes;
String query="select contracts.*, company.company_name, contacts.contact_id, contacts.name, company.safety_manual "
	+ "from contracts join company on contracts.company_id = company.company_id left join contacts "
	+ "using(contact_id) where contract_id= " + contract_id;
long cost_code_id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (rs.next()) {
agreement_date = FormHelper.date(rs.getDate("agreement_date"));
cost_code_id = rs.getLong("cost_code_id");
insurance_proof=rs.getString("insurance_proof");
if(insurance_proof==null) insurance_proof="n";
submittal_required=rs.getString("submittal_required");
if(submittal_required==null) submittal_required="n";
workers_comp_proof=rs.getString("workers_comp_proof");
if(workers_comp_proof==null) workers_comp_proof="n";

req_tech_submittals=rs.getString("req_tech_submittals");
if(req_tech_submittals==null) req_tech_submittals="n";
have_tech_submittals=rs.getString("have_tech_submittals");
if(have_tech_submittals==null) have_tech_submittals="n";
req_specialty=rs.getString("req_specialty");
if(req_specialty == null) req_specialty = "";
have_specialty=rs.getString("have_specialty");
if(have_specialty==null) have_specialty="n";
req_owner_training=rs.getString("req_owner_training");
if(req_owner_training==null) req_owner_training="n";
have_owner_training=rs.getString("have_owner_training");
if(have_owner_training==null) have_owner_training="n";
req_warranty=rs.getString("req_warranty");
if(req_warranty==null) req_warranty="n";
have_warranty=rs.getString("have_warranty");
if(have_warranty==null) have_warranty="n";
have_lien_release=rs.getString("have_lien_release");
if(have_lien_release==null) have_lien_release="n";
tracking_notes=rs.getString("tracking_notes");
String completed = rs.getString("completed");
float amount = rs.getFloat("amount");
date_sent = FormHelper.date(rs.getDate("date_sent"));
safety_manual = rs.getString("company.safety_manual");
float ret = rs.getFloat("retention_rate");
// Compute company strikes
int strikes = 0;

date_received = FormHelper.date(rs.getDate("date_received"));
gen_insurance_expire = FormHelper.date(rs.getDate("gen_insurance_expire"));
workers_comp_expire = FormHelper.date(rs.getDate("workers_comp_expire"));

query = "select letter from cost_types where contractable = 1";
ResultSet rs2 = db.dbQuery(query);
query = "select cost_code_id, division, cost_code, phase_code, code_description "
	+ "from job_cost_detail where job_id = " + attr.getJobId();
if (rs2.isBeforeFirst()) {
	query += " and (";
	while (rs2.next()) {
		if (rs2.isFirst()) query += "phase_code	= '" + rs2.getString("letter") + "' ";
		else query += "or phase_code	= '" + rs2.getString("letter") + "' ";
	}
	query += ")";
}
if (rs2 != null) rs2.getStatement().close();
query += " order by costorder(division), costorder(cost_code), phase_code";
rs2 = db.dbQuery(query);

String name = rs.getString("name");

%>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="../utils/spell.js"></script>
	<script language = "javascript">
		function spell() {
			spellCheck(document.contract);
		}
		function save() {
			var cof = document.contract;
			if(checkForm(cof)) cof.submit();
		}
		function aEdit() {
			msgWindow=open('','aEdit','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=500,left=25,top=25');
			msgWindow.location.href = "textarea.jsp?id=contract";
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		parent.left.location="modifyContractLeft.jsp?id=<%= contract_id%>";
	</script>
	<script language="javascript" src="../utils/calendar.js"></script>
</head>
<body>
<form name="contract" <% if(sec.ok(Security.SUBCONTRACT,2)) 
	out.print("action=\"processModifyContract.jsp\" method=\"POST\""); %>>
<input type="hidden" name="contract_id" value="<%=contract_id%>">
<div class="title">Modify Contract</div><hr>
<%
if (request.getParameter("msg") != null) out.print("<font color=\"red\"><b>Saved - Accounting: " + request.getParameter("msg") + "</b></font><hr>");
%>
<table>
	<tr>
		<td align="right"><b>ID:</b></td>
		<td colspan="3"><%= com.sinkluge.utilities.Widgets.logLinkWithId(request.getParameter("id"),
			com.sinkluge.Type.SUBCONTRACT, "parent", request) %></td>
	</tr>
	<tr>
		<td align="right"><b><a href="changeCompanyOnContract.jsp?id=<%= contract_id %>">Company:</a></b> </td>
		<td colspan="3"><%= rs.getString("company_name") + (name!=null?"- "+name:"") %>
<%
if (strikes > 0) out.print(" - <font color=\"red\"><b>" + strikes + " strikes</b>");
%>
	</tr>

	<% long costCodeId; %>
	<tr><td align="right"><b>Phase:</b></td>
    <td align="left" colspan="3"><select name="cost_code_id">
		<% while(rs2.next()) {
				costCodeId = rs2.getLong("cost_code_id");
				%>
			<option value="<%=costCodeId%>" <%= FormHelper.sel(cost_code_id, costCodeId) %>><%= rs2.getString("division") + " " + rs2.getString("cost_code") + "-" + rs2.getString("phase_code") + " " + rs2.getString("code_description") %></option>
			<% } rs2.close();
			%>
			</select>
				</td></tr>

		<tr><td align="right"><b><a href="javascript:insertDate('agreementDate')">Agreement Date:</a></b></td>
    <td colspan="3">
		<input type="text" name="agreementDate" id="agreementDate" maxlength=10 size=8 value="<%= agreement_date %>">
								<img id="calagreementDate" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		</tr>

				<tr><td align="right"><b><a href="javascript:insertDate('dateSent')">Date Sent:</a></b></td>
    <td colspan="3">
		<input type="text" name="dateSent" id="dateSent" maxlength=10 size=8 value="<%= date_sent %>">
						<img id="caldateSent" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td></tr>

				<tr><td align="right"><b><a href="javascript:insertDate('dateReceived')">Date Received:</a></b></td>
    <td colspan="3">
		<input type="text" name="dateReceived" id="dateReceived" maxlength=10 size=8 value="<%= date_received %>">
						<img id="caldateReceived" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td></tr>
		<% int companyId; %>
		<tr><td align="right"><b>Contract Amount:</b></td>
	<td align="left"><input type="text" size = "8" name="amount" value="<%= FormHelper.cur(amount) %>"></td>
	<td align="right"><b>Retention Rate:</b></td>
	<td><input type="text" size="8" name="retention_rate" value="<%= FormHelper.per(ret*100) %>"></td></tr>

		<tr><td align="right"><b><a href="javascript: aEdit()">Description:</a></b></td>
    <td align="left" colspan="3"><textarea name="description" rows=4 cols=55><%=rs.getString("description")%></textarea></td></tr>
</table>
<fieldset>
<legend>Requirements</legend>
<table>
		<tr><td align="right"><b>Submittal Required: </b></td>
		<td align="left"><input type="checkbox" name="submittal_required" value="y" <% if (submittal_required.equals("y")) out.println("checked");%>></td>
			<td colspan="2"><b>Have Safety Manual: </b><input type="checkbox" value="y" name="safety_manual" <% if (safety_manual.equals("y")) out.print("checked");%>></td>
		</tr>

<tr><td align="right"><b>Proof of Insurance: </b></td>
<td align="left"><input type="checkbox" name="insurance_proof" value="y" <% if (insurance_proof.equals("y")) out.println("checked");%>></td>
<td align="right"><b>Expiration: </b></td><td><input type="text" size="8" maxlength="10" id="insExpire" name="insExpire" value="<%= gen_insurance_expire%>">
						<img id="calinsExpire" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
		</td></tr>

<tr><td align="right"><b>Proof of Workers Comp: </b></td>
<td align="left"><input type="checkbox" name="workers_comp_proof" value="y" <% if (workers_comp_proof.equals("y")) out.println("checked");%>>

<td align="right"><b>Expiration: </b></td><td><input type="text" size="8" maxlength="10" id="wkComp" name="wkComp" value="<%= workers_comp_expire %>">
						<img id="calwkComp" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
		</td></tr>
</table>
</fieldset>
<fieldset>
<legend>Tracking Information</legend>
<table>
		<tr><td align="right"><b>O & M Submittals:</b></td><td align="left">
		Need:<input type="checkbox" name="req_tech_submittals" value="y" <% if (req_tech_submittals.equals("y")) out.println("checked");%>>
		Have:<input type="checkbox" name="have_tech_submittals" value="y" <% if (have_tech_submittals.equals("y")) out.println("checked");%>></td></tr>
		<tr><td align="right"><b>Warranty:</b></td><td align="left">
		Need:<input type="checkbox" name="req_warranty" value="y" <% if (req_warranty.equals("y")) out.println("checked");%>>
		Have:<input type="checkbox" name="have_warranty" value="y" <% if (have_warranty.equals("y")) out.println("checked");%>></td></tr>
		<tr><td align="right"><b>Owner Training:</b></td><td align="left">
		Need:<input type="checkbox" name="req_owner_training" value="y" <% if (req_owner_training.equals("y")) out.println("checked");%>>
		Have:<input type="checkbox" name="have_owner_training" value="y" <% if (have_owner_training.equals("y")) out.println("checked");%>></td></tr>
		<tr><td align="right"><b>Lien Release:</b></td><td align="left">
		Have:<input type="checkbox" name="have_lien_release" value="y" <% if (have_lien_release.equals("y")) out.println("checked");%>></td></tr>
		<tr><td align="right"><b>Specialty Items:</b></td><td align="left"><textarea name="req_specialty" rows=3 cols=55><%= FormHelper.string(req_specialty) %></textarea></td><td align="left" valign="middle">
		Have:<input type="checkbox" name="have_specialty" value="y" <% if (have_specialty.equals("y")) out.println("checked");%>></td></tr>
		<tr><td align="right"><b>Tracking Notes:</b><td align="left"><textarea name="tracking_notes" rows=3 cols=55><%= FormHelper.string(tracking_notes) %></textarea></td></tr>
		<tr><td align="right"><b>Contract Complete:</b></td><td align="left">
		<input type="checkbox" name="completed" value="y" <% if (completed.equals("y")) out.println("checked");%>></td></tr>



</table>
</fieldset>
</form>
<script language="javascript">	
	var f = document.contract;
	f.description.spell = true;
	f.cost_code_id.focus();
	
	var d = f.agreementDate;
	d.required = true;
	d.isDate = true;
	d.eName = "Agreement Date";
	d.select();
	d.focus();
	
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

<%
// I didn't get anything (no contracts)
} else {
	out.print("<font size=\"+1\">Contract Not Found</font>");
}
db.disconnect();
%>
</body></html>

