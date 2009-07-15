<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="accounting.CRD, accounting.Company, accounting.Accounting"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
Logger log = Logger.getLogger(this.getClass());
if (!sec.ok(Security.SUBCONTRACT, Security.READ) && !attr.hasAccounting()) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String contractId = request.getParameter("id");
ResultSet rs;
String sql;
String companyName = "";
Database db = new Database();
if (contractId != null) {
	sql = "select company_name from contracts join company "
		+ "using(company_id) where contract_id = " + contractId;
	rs = db.dbQuery(sql);
	if (rs.first()) companyName = rs.getString("company_name");
	rs.getStatement().close();
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="../utils/table.js"></script>
<script>
	function printWin(loc) {
		var msgWin = window.open(loc, "print");
		msgWin.focus();
	}
	function reloadc() {
		window.location.reload();
	}
	function edit(id) {
		var msgWindow = open("crdFrameset.jsp?id=" + id, "crd", "toolbar=no,location=no,directories=no,"
			+ "status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=600,left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
</script>
</head>
<body>
<div class="title">Accounting Comparison<%= contractId != null ? " - " 
		+ companyName : "" %></div><hr>
<div class="link" onclick="window.location='cas.jsp<%= contractId != null ? "?id=" + contractId : 
	"" %>';">Change Authorizations</div>
 &gt; Accounting Comparison &nbsp; 
<div class="link" onclick="printWin('printAccountingSummaryCA.jsp<%= contractId != null ?
	"?id=" + contractId : "" %>');">Print</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<td class="head">CA #</td>
	<td class="head">CR #</td>
	<td class="head">Company</td>
	<td class="head">Amount</td>
	<td class="head">Exists</td>
	<td class="head">Account Cmp</td>
	<td class="head">Account Amt</td>
	<td class="head">Match</td>
	<td class="head">Acc ID</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
sql = "select change_auth_num, crd_id, company_name, crd.amount, num from change_request_detail as crd "
	+ "join contracts using(contract_id) join company using(company_id) left join change_requests as cr "
	+ "using(cr_id) where crd.job_id = " + attr.getJobId() + (contractId != null ? " and contract_id = " 
	+ contractId : "") +" and authorization = 1 order by change_auth_num desc";
rs = db.dbQuery(sql);
boolean color = true;
Accounting acc = AccountingUtils.getAccounting(session);
double ca, accCa;
CRD crd;
Company company;
while (rs.next()) {
	color = !color;
	ca = rs.getDouble("amount");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<td class="left right"><div class="link" onclick="edit(<%= rs.getString("crd_id") %>);">Edit</div></td>
<td class="it aright"><%= rs.getString("change_auth_num") %></td>
<td class="it aright"><%= FormHelper.stringTable(rs.getString("num")) %></td>
<td class="it"><%= rs.getString("company_name") %></td>
<td class="it"><%= FormHelper.cur(ca) %></td>
<%
	crd = AccountingUtils.getCRD(rs.getString("crd_id"), acc);
	if (crd != null) {
		crd = acc.getCRD(crd);
		if (crd != null) {
			log.debug("ca returned");
			accCa = crd.getContract();
			log.debug("change auth amount: " + accCa);
			if (crd.getSub() != null) company = acc.getCompany(crd.getSub().getAltCompanyId());
			else company = null;
%>
<td class="input acenter"><%= Widgets.checkmark(true, request) %></td>
<td class="it"><%= company != null ? company.getName() + " (" + company.getAccountId() + ")": "&nbsp;" %></td>
<td class="it aright"><%= FormHelper.cur(accCa) %></td>
<td class="input acenter"><%= Widgets.checkmark(accCa == ca, request) %></td>
<td class="it aright"><%= crd.getCaAltId() %></td>
<%
		} else {
			log.debug("no subcontract found");
%>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<%
		}
	}
%>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(rs.getString("crd_id"), com.sinkluge.Type.CRD, 
	"window", request) %></td>
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