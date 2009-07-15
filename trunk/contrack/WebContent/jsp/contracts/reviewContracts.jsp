<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.security.Security" %>
<%@page import="java.text.DecimalFormat" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sp = sec.ok(Security.SUBCONTRACT, Security.PRINT);
boolean sw = sec.ok(Security.SUBCONTRACT, Security.WRITE);
boolean sd = sec.ok(Security.SUBCONTRACT, Security.DELETE);
boolean sco = sec.ok(Security.CO, Security.READ);
boolean sbmt = sec.ok(Security.SUBMITTALS, Security.READ);
%>

<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<SCRIPT LANGUAGE="JavaScript">
	function newWindow(contractID) {
		msgWindow=open('','newJob','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=400,height=200,left=25,top=200');
		msgWindow.location.href = "contractPrintingOptions.jsp?contractID=" +contractID;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function newContract() {
		msgWindow=open('','newJob','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=650,height=500,left=25,top=25');
		msgWindow.location.href = "newContractFrameset.jsp"
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function editContract(id) {
		msgWindow=open('','newJob','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=650,height=500,left=25,top=25');
		msgWindow.location.href = "modifyContractFrameset.jsp?id=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function changeButton() {
		parent.manage_top.document.manage.section.value = "ba";
		parent.manage_top.document.manage.submit();
	}
	function editCode(txt) {
			msgWindow=open('','newJob','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=500,height=450,left=25,top=25');
     		msgWindow.location.href = "../costCodes/editCodeContractWindow.jsp?cc=" + txt;
     		if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
	}
	function del(id) {
		if(confirm("Delete this subcontract?")) location = "deleteContract.jsp?id=" + id;
	}
	</script>
</head>

<body>
<div class="title">Subcontracts</div><hr>
<%
if (sw) out.print("<a href=\"javascript: newContract()\">New</a>&nbsp;&nbsp;");
%>
<a href="contractTracking.jsp">Tracking</a>&nbsp;&nbsp;
<%
if (sp) {
%>
<a href="summary.jsp">Current Summary</a> &nbsp;
<%
}
%>
<a href="accountingSummary.jsp">Accounting Comparison</a>
<hr>
<%
DecimalFormat df = new DecimalFormat("#,##0");
String desc="", company_name;
String query = "select contracts.contract_id, name, division, contracts.cost_code_id, contracts.company_id, job_cost_detail.code_description, job_cost_detail.cost_code, job_cost_detail.phase_code, "
	+ "date_format(contracts.date_sent,'%d %b %y') as ds, date_format(contracts.date_received,'%d %b %y') as dr, company.company_name, company.company_id, contracts.amount from contracts join company join job_cost_detail left join contacts using (contact_id) "
	+ "where contracts.company_id=company.company_id and contracts.cost_code_id = job_cost_detail.cost_code_id and contracts.job_id = "
	+ attr.getJobId();
String sort = request.getParameter("sort");
if (sort == null) sort = "";
if (sort.equals("name")) query += " order by company_name, name";
else if (sort.equals("amount")) query += " order by amount desc";
else query += " order by costorder(division),costorder(cost_code), phase_code";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String costCode, phaseCode, name;
int contractID;
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
<%
if (sd) out.print("<td class=\"left head nosort\">Delete</td>");
if (!sd) out.print("<td class=\"left head nosort\">Edit</td>");
else out.print("<td class=\"head nosort\">Edit</td>");
if (sbmt) out.print("<td class=\"head nosort\">Sbmtls</td>");
if (sco) out.print("<td class=\"head nosort\">CAs</td>");
%>
		<td class="head nosort">PR</td>
		<td class="head">Phase</td>
		<td class="head">Description</td>
		<td class="head">Company</td>
		<td class="head">Amount</td>
		<td class="head">Sent</td>
		<td class="head">Received</td>
		<td class="right head">ID</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean c = true;
while (rs.next()){
company_name=rs.getString("company_name");
	c = !c;
	if (company_name == null) company_name = "";
	if (company_name.length()>40) company_name=company_name.substring(0,40);
	costCode = rs.getString("division") + " " + rs.getString("cost_code");
	phaseCode= rs.getString("phase_code");
	desc = rs.getString("code_description");
	if (desc == null) desc = "----";
	contractID = rs.getInt("contract_id");
	String d_string = rs.getString("ds");
	String r_string = rs.getString("dr");
	name = rs.getString("name");
	if (d_string == null) d_string="&nbsp;";
	if (r_string == null) r_string="&nbsp;";
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (c) out.print("class=\"gray\""); %>>
<%
	if (sd) {
%>
		<td class="left"><a href="javascript: del('<%= contractID%>');">Delete</a></td>
<%
	}
	if (!sd) {
%>
		<td class="left"><a href="javascript:editContract('<%= contractID%>')" >Edit</a></td>
<%
	} else {
%>
		<td class="it"><a href="javascript:editContract('<%= contractID%>')" >Edit</a></td>
<%
	}
	if (sbmt) {
%>
		<td class="it"><a href="../submittals/reviewSubmittals.jsp?contract_id=<%= contractID %>">Sbmtls</a></td>
<%		
	}
	if (sco) {
%>
		<td class="it"><a href="../changeRequests/cas.jsp?id=<%= contractID%>">CAs</a></td>
<%
	}
%>
		<td class="right"><a href="payRequests/subPayRequests.jsp?contract_id=<%= contractID %>">PR</a></td>
		<td class="it acenter"><%= costCode %>-<%= phaseCode %></td>
		<td class="it"><%= desc %></td>
		<td class="it"><a href="../contacts/modifyCompany.jsp?id=<%=rs.getString("company_id")%>" onClick="changeButton()"><%=company_name %></a><%= name!=null?" - " + name:"" %></td>
		<td class="it aright"><%= df.format(rs.getFloat("amount")) %></td>
		<td class="it aright"><%= d_string %></td>
		<td class="it aright"><%= r_string %></td>
		<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(
			rs.getString("contract_id"), com.sinkluge.Type.SUBCONTRACT, "window",
			request) %></td>
	</tr>
<%
}
rs.close();
db.disconnect();
%>
</table>
</div>
</body>
</html>
