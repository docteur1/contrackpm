<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="accounting.Subcontract, accounting.Accounting, accounting.Company" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
Logger log = Logger.getLogger(this.getClass());
if (!sec.ok(Name.SUBCONTRACTS, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean cas = sec.ok(Name.CHANGES, Permission.READ);
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
	function openCompany(id) {
		window.location = "../contacts/modifyCompany.jsp?id=" + id;
		parent.manage_top.document.manage.section.value = "ba";
		parent.manage_top.document.manage.submit();
	}
	function edit(id) {
		var msgWindow = open("modifyContractFrameset.jsp?id=" + id, "cr", "toolbar=no,location=no,directories=no,"
			+ "status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=600,left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
</script>
</head>
<body>
<div class="title">Accounting Comparison</div><hr>
<div class="link" onclick="window.location='reviewContracts.jsp'">Subcontracts</div>
 &gt; Accounting Comparison &nbsp; 
<div class="link" onclick="openWin('printAccountingSummary.jsp');">Print</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<%=cas ? "<td class=\"head nosort\">CAs</td>" : ""%>
	<td class="head">Code</td>
	<td class="head">Company</td>
	<td class="head">Current</td>
	<td class="head">Account Cmp</td>
	<td class="head">Exists</td>
	<td class="head">Account Amt</td>
	<td class="head">Match</td>
	<td class="head">Acc ID</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
	String sql = "select cost_code, phase_code, division, company_name, name, account_id, "
	+ "cp.company_id, cn.contract_id, cn.altContractId, cn.amount, cn.contract_id from contracts as cn "
	+ "join company as cp on cn.company_id = cp.company_id left join "
	+ "contacts as ct on cn.contact_id = ct.contact_id left join job_cost_detail as jcd on "
	+ "jcd.cost_code_id = cn.cost_code_id left join company_account_ids as cai "
	+ "on (cn.company_id = cai.company_id and cai.site_id = " + attr.getSiteId() 
	+ ") where cn.job_id = " + attr.getJobId() + " order by costorder(division), "
	+ "costorder(cost_code), costorder(phase_code)";
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
ResultSet rs2;
boolean color = true;
Subcontract sub;
String altContractId;
Company c;
Accounting acc = AccountingUtils.getAccounting(session);
double accChangeAuths = 0;
while (rs.next()) {
	sql = "select sum(amount) as sum from change_request_detail "
		+ "where authorization = 1 and contract_id = " + rs.getString("contract_id");
	rs2 = db.dbQuery(sql);
	color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<td class="left <%= !cas ? "right" : "" %>"><div class="link" 
	onclick="edit(<%= rs.getString("contract_id") %>);">
	Edit</div>
</td>
<%= cas ? "<td class=\"right\"><div class=\"link\""
		+ "onclick=\"window.location='../changeRequests/cas.jsp?id="
		+ rs.getString("contract_id") + "';\">CAs</div></td>" : "" %>
<td class="it aright"><%= rs.getString("division") + " " 
	+ rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
<td class="it"><div class="link" onclick="openCompany(<%= rs.getString("company_id") %>);">
	<%= rs.getString("company_name") %></div><%= rs.getString("name") != null ?
		" - " + FormHelper.stringTable(rs.getString("name")) : "" %></td>
<%
	if (rs2.first()) {
%>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount") 
	+ rs2.getDouble("sum")) %>
<%
	} else {
%>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<%
	}
	c = acc.getCompany(rs.getString("account_id"));
%>
<td class="it"><%= c != null ? c.getName() + " (" + c.getAccountId() + ")" : "&nbsp;" %></td>
<%
	altContractId = rs.getString("altContractId");
	if (altContractId != null) {
		log.debug("Looking for contract by altId: " + altContractId);
		sub = acc.getSubcontract(altContractId, rs.getString("phase_code"));
	} else {
		sub = AccountingUtils.getSubcontract(rs.getInt("contract_id"));
		log.debug("Looking for contract by data");
		if (sub != null) sub = acc.getSubcontract(sub);
	}
	if (sub != null) {
		accChangeAuths = acc.getCATotal(sub.getAltContractId());
		if (sub.getAltContractId() != null && !sub.getAltContractId().equals(altContractId))
		{
			db.dbInsert("update contracts set altContractId = '" + sub.getAltContractId()
				+ "' where contract_id = " + rs.getString("contract_id"));
		}
%>
<td class="input acenter"><%= Widgets.checkmark(true, request) %></td>
<td class="it aright"><%= FormHelper.cur(sub.getAmount() + accChangeAuths) %></td>
<td class="input acenter"><%= Widgets.checkmark(sub.getAmount() + accChangeAuths
		== rs.getDouble("amount") + rs2.getDouble("sum"), request) %></td>
<td class="it aright"><%= sub.getAltContractId() %></td>
<%
	} else {
%>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<%
	}
	rs2.getStatement().close();
%>
<td class="right"><%= Widgets.logLinkWithId(rs.getString("contract_id"), com.sinkluge.Type.SUBCONTRACT, 
	request) %></td>
</tr>
<%
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>