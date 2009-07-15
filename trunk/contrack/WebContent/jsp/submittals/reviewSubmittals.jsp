<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBMITTALS, Security.READ)) response.sendRedirect("../accessDenied.html");
boolean sp = sec.ok(Security.SUBMITTALS,Security.PRINT);
boolean sw = sec.ok(Security.SUBMITTALS,Security.WRITE);
boolean sd = sec.ok(Security.SUBMITTALS,Security.DELETE);
String query;
ResultSet rs = null;
String contract_id = request.getParameter("contract_id");
String comp_name = null;
Database db = new Database();
if (contract_id != null) {
	query = "select company_name from company, contracts where contract_id = " + contract_id + " and contracts.company_id = company.company_id";
	rs = db.dbQuery(query);
	if (rs.next()) comp_name = rs.getString(1);
	if (rs != null) rs.close();
	rs = null;
}
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<SCRIPT LANGUAGE="JavaScript">
	function newWindow(subID) {
		msgWindow=open('','submittal','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=200,height=100,left=25,top=25');
		msgWindow.location.href = "submittalPrintOptions.jsp?submittal_id=" +subID;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function newSubmittal(id) {
		msgWindow=open('','submittal','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=800,height=500,left=25,top=25');
		if (id == null || id == "null") msgWindow.location.href = "newSubmittalFrameset.jsp";
		else msgWindow.location.href = "newSubmittalFrameset.jsp?contract_id=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function modifySubmittal(id) {
		msgWindow=open('','submittal','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=800,height=500,left=25,top=25');
		msgWindow.location.href = "modifySubmittalFrameset.jsp?subID=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function del (id) {
		if(confirm("Delete this submittal?")) window.location = "deleteSubmittal.jsp?subID=" + id;
	}
	</script>
	<script lanaguage="javascript" src="../utils/print.js"></script>
</head>
<body>
		<font size="+1">Submittals<% if (comp_name != null) out.print(": " + comp_name); %></font><hr>
<%
if (sw) {
%>
<a href="javascript: newSubmittal(<%= contract_id %>)">New</a>&nbsp;&nbsp;
<%
}
String description="";
if (contract_id==null){
	query = "select submittals.submittal_id, e_update, e_submit, submittals.submittal_num, submittals.date_received, submittals.date_from_architect, "
		+ "submittals.date_created, substring(submittals.description,1,70), submittals.submittal_status, division, cost_code, phase_code, "
		+ "substring(company.company_name,1,20) as name from submittals left join job_cost_detail as jcd on "
		+ "submittals.cost_code_id = jcd.cost_code_id left join contracts using(contract_id) left join company "
		+ "using(company_id)where submittals.job_id = " + attr.getJobId()
		+ " order by submittal_status desc";
}
else {
	query = "select submittals.submittal_id, e_update, e_submit, submittals.submittal_num, submittals.date_received, submittals.date_from_architect, "
		+ "submittals.date_created, substring(submittals.description,1,70), submittals.submittal_status, division, cost_code, phase_code, "
		+ "substring(company.company_name,1,20) as name from submittals join job_cost_detail as jcd on "
		+ "submittals.cost_code_id = jcd.cost_code_id join contracts using(contract_id) join company "
		+ "using(company_id)where submittals.contract_id = " + contract_id
		+ " order by submittal_status desc";
}
rs = db.dbQuery(query);
String subID;
if (sp) {
%>
<select onChange="printSel(this);">
	<option>--Reports--</option>
	<option disabled>Summaries</option>
	<option value="sbmtSummary.pdf"> &nbsp; By Number</option>
	<option value="sbmtSummary.pdf?id=phase"> &nbsp; By Phase</option>
</select>
<%
}
%>
<hr>
<div style="margin-bottom: 8px;"><span class="red">Red</span> company name = not received. <span class="bold">Bold</span> = eSubmitted and not read.</div>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
<%
if (sd) {
	out.println("<td class=\"head left nosort\">Delete</td>");
	out.println("<td class=\"head nosort\">Edit</td>");
} else out.println("<td class=\"left head nosort\">Edit</td>");
%>
	
	<td class="head">Num</td>
	<td class="head">Cost Code</td>
	<td class="head">Company</td>
	<td class="head">From Sub</td>
	<td class="head">From Arch</td>
	<td class="head">Status</td>
	<td class="head">eUpdate</td>
	<td class="head">Description</td>
	<td class="head right">ID</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
String num = "";
String cc="", company;
boolean color = true;
boolean eSubmit = false;
while (rs.next()){
	color = !color;
	company = rs.getString("name");
	eSubmit = rs.getBoolean("e_submit");
	cc = rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code");
	num = rs.getString("submittal_num");
	description = rs.getString("substring(submittals.description,1,70)");
	if (description != null && description.length()>40) description = description.substring(0,40) + "...";
	subID=rs.getString("submittal_id");
%>
<%! 
String bold(boolean b) {
	return (b?"bold":"");
}
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
	if (sd) out.print("<td class=\"left " + bold(eSubmit) + "\"><a href=\"javascript: del(" + subID + ")\">Delete</a></td>");
%>
	<td class="right <%= bold(eSubmit) %>"><a href="javascript:modifySubmittal('<%= subID%>')">Edit</a></td>
	<td class="it aright <%= bold(eSubmit) %>"><%= FormHelper.stringTable(num) %></td>
	<td class="it acenter <%= bold(eSubmit) %>"><%= cc %></td>
	<td class="it <%= bold(eSubmit) %> <%= (rs.getDate("date_received")==null||rs.getDate("date_from_architect")==null)
		?"red":"" %>"><%= (company == null ? attr.get("short_name") : company) %></td>
	<td class="it aright <%= bold(eSubmit) %>"><%= FormHelper.medDate(rs.getDate("date_received")) %></td>
		<td class="it aright <%= bold(eSubmit) %>"><%= FormHelper.medDate(rs.getDate("date_from_architect")) %></td>
	<td class="it <%= bold(eSubmit) %>"><%= rs.getString("submittal_status") %></td>
		<td class="input"><%= Widgets.checkmark(rs.getBoolean("e_update"), request) %></td>
		<td class="it <%= bold(eSubmit) %>"><%= FormHelper.stringTable(description) %></td>
		<td class="right <%= bold(eSubmit) %>"><%= com.sinkluge.utilities.Widgets.logLinkWithId(subID, 
					com.sinkluge.Type.SUBMITTAL, "window", request) %></td>
	</tr>
<%
}
rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>

</body>
</html>
