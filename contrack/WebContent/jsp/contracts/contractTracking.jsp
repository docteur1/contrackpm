<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.util.Date, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.Widgets" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
boolean sw = sec.ok(Security.SUBCONTRACT, Security.READ);
%>

<html>
<head>
	<title>Contracts</title>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<script language="javascript">
		function editContract(id) {
			msgWindow=open('','newJob','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=500,left=25,top=25');
			msgWindow.location.href = "modifyContractFrameset.jsp?id=" + id;
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function changeButton() {
			parent.manage_top.document.manage.section.value = "ba";
			parent.manage_top.document.manage.submit();
		}
	</script>
</head>
<body>
<%
boolean color = true;
String descQuery, desc="";
String order = request.getParameter("sort");
if (order == null) order = "";
String query = "select contracts.contract_id, division, cost_code, phase_code, company.safety_manual, contracts.company_id, contracts.date_sent, "
	+ "contracts.date_received, contracts.completed, contracts.gen_insurance_expire, contracts.workers_comp_expire, contracts.insurance_proof, "
	+ "contracts.workers_comp_proof, company.company_name, company.federal_id, company.company_id from contracts, company, "
	+ "job_cost_detail as jcd where jcd.cost_code_id = contracts.cost_code_id and "
	+ "contracts.job_id =" + attr.getJobId() + " and contracts.company_id=company.company_id";
if (order.equals("")) query += " order by costorder(division), costorder(cost_code), phase_code";
else query += " order by company_name, costorder(division), costorder(cost_code), phase_code";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
int contractID, len;
%>
<font size="+1">Subcontract Tracking</font><hr>
<a href="reviewContracts.jsp">Subcontracts</a> &gt; Tracking<hr>
<font color="red">Red</font> = No proof in hand &nbsp;&nbsp;&nbsp;&nbsp; <s>1 Feb 50</s> = expired
<table cellspacing="0" cellpadding="3" style="margin-top: 8px;" id="tableHead">
	<tr>
<%
if (sw) {
	out.print("<td class=\"head left nosort\">Edit</td>");
	out.print("<td class=\"head\">");
}
else out.print("<td class=\"left head\">");
%>
	Cost/Phase</td>
	<td class="head">Company</td>
	<td class="head">Sent</td>
	<td class="head">Received</td>
	<td class="head">Complete</td>
	<td class="head">Fed ID</td>
	<td class="head">Safety</td>
	<td class="head">Gen. Liability</td>
	<td class="head">Work Comp</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
Date today = new Date();
Date ins, work;
String i,w,dr,ds;
boolean good_dr=true, good_ds=true;
while (rs.next()){
color = !color;
good_dr = true;
good_ds = true;
dr = rs.getString("date_received");
ds = rs.getString("date_sent");
contractID = rs.getInt("contract_id");

ins = rs.getDate("gen_insurance_expire");
	if (ins == null) {i="&nbsp;";ins=today;}
	else i=FormHelper.medDate(ins);
work = rs.getDate("workers_comp_expire");
	if(work == null) {w = "&nbsp;";work=today;}
	else w = FormHelper.medDate(work);
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
if (sw) {
%>
		<td class="left right"><a href="javascript: editContract('<%=contractID%>');">Edit</a></td>
<%
}
%>
		<td class="it"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
		<td class="it"><a href="../contacts/modifyCompany.jsp?id=<%=rs.getString("company_id")%>" onClick="changeButton()"><%= rs.getString("company_name") %></a></td>
		<td class="it"><%= FormHelper.medDate(rs.getDate("date_sent")) %></td>
		<td class="it"><%= FormHelper.medDate(rs.getDate("date_received")) %></td>
		<td class="input"><%= Widgets.checkmark(FormHelper.oldBoolean(rs.getString("completed")), request) %></td>
		<td class="it"><%= FormHelper.stringTable(rs.getString("federal_id")) %></td>
		<td class="input"><%= Widgets.checkmark(FormHelper.oldBoolean(rs.getString("safety_manual")), request) %></td>
		<td class="it <%= !FormHelper.oldBoolean(rs.getString("insurance_proof"))?"red":"" %> <%= ins.compareTo(today)<0?"strike":"" %>"><%= i %></td>
		<td class="it <%= !FormHelper.oldBoolean(rs.getString("workers_comp_proof"))?"red":"" %> <%= work.compareTo(today)<0?"strike":"" %>"><%= w %></td>
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
</body>
</html>
