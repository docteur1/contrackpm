<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Name.SUBMITTALS, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean ca = sec.ok(Name.CHANGES, Permission.READ);
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="../utils/table.js"></script>
<script>
	function openWin(loc) {
		var msgWin = window.open(loc, "print");
		msgWin.focus();
	}
	function editContract(id) {
		msgWindow=open('','newJob','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=650,height=500,left=25,top=25');
		msgWindow.location.href = "modifyContractFrameset.jsp?id=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function openCompany(id) {
		window.location = "../contacts/modifyCompany.jsp?id=" + id;
	}
</script>
<title>Contract Summary</title>
</head>
<body>
<div class="title">Current Summary</div><hr>
<div class="link" onclick="window.location='reviewContracts.jsp'">Subcontracts</div>
 &gt; Current Summary &nbsp; 
<div class="link" onclick="openWin('printSummary.jsp');">Print</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<%= ca ? "<td class=\"head nosort\">CAs</td>" : ""  %>
	<td class="head">Code</td>
	<td class="head">Company</td>
	<td class="head">Amount</td>
	<td class="head"># CAs</td>
	<td class="head">CAs</td>
	<td class="head">Revised</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
String sql = "select cost_code, phase_code, division, company_name, name, "
	+ "cp.company_id, cn.contract_id, cn.amount from contracts as cn join company as cp "
	+ "on cn.company_id = cp.company_id left join "
	+ "contacts as ct on cn.contact_id = ct.contact_id join job_cost_detail as jcd on "
	+ "jcd.cost_code_id = cn.cost_code_id where cn.job_id = " + attr.getJobId()
	+ " order by costorder(division), costorder(cost_code), "
	+ "costorder(phase_code)";
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
ResultSet rs2;
boolean color = true;
while (rs.next()) {
	sql = "select count(*) as count, sum(amount) as sum from change_request_detail "
		+ "where authorization = 1 and contract_id = " + rs.getString("contract_id");
	rs2 = db.dbQuery(sql);
	color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<td class="left <%= ca ? "" : "right" %>"><div class="link" 
	onclick="editContract(<%= rs.getString("contract_id") %>);">
	Edit</div>
</td>
<%= ca ? (rs2.first() && rs2.getInt("count") != 0 ? "<td class=\"it\"><div class=\"link\""
	+ " onclick=\"window.location='../changeRequests/cas.jsp?id=" 
	+ rs.getString("contract_id") + "&current_summary=true';\">CAs</div>" 
	: "<td class=\"it\">&nbsp;</td>") : "" %>
<td class="left"><%= rs.getString("division") + " " 
	+ rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
<td class="it"><div class="link" onclick="openCompany(<%= rs.getString("company_id") %>);">
	<%= rs.getString("company_name") %></div><%= rs.getString("name") != null ?
		" - " + FormHelper.stringTable(rs.getString("name")) : "" %></td>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<%
	if (rs2.first()) {
%>
<td class="it aright"><%= rs2.getString("count") %></td>
<td class="it aright"><%= FormHelper.cur(rs2.getDouble("sum")) %></td>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount") +
	rs2.getDouble("sum")) %></td>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(
	rs.getString("contract_id"), com.sinkluge.Type.SUBCONTRACT, "window",
	request) %></td>
<%
	} else {
%>
<td class="it aright"><%= 0 %></td>
<td class="it aright"><%= FormHelper.cur(0) %></td>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(
	rs.getString("contract_id"), com.sinkluge.Type.SUBCONTRACT, "window",
	request) %></td>
<%
	}
%>
</tr>
<%
	rs2.getStatement().close();
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>