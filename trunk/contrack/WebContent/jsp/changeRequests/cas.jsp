<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security, java.util.EnumSet" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.CRD, accounting.Accounting, accounting.Result, accounting.Action" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.CO, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String contractId = request.getParameter("id");
int CAflag = 1;  //1 = all CAs, 2 = specific CAs associated with contract, 3 = no CAs associated with contract
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
	sql = "select job_id from change_request_detail where job_id = " + attr.getJobId() 
		+ " and contract_id = " + contractId;
	rs = db.dbQuery(sql);
	if (!rs.first()) {
		CAflag = 3;
	}
	else {
		CAflag = 2;
	}
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
	function openWin(loc, x, y) {
		var msgWindow = open(loc, "cr", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function edit(id) {
		openWin("crdFrameset.jsp?id=" + id, 700, 600);
	}
	function reloadc() {
		window.location = "cas.jsp<%= contractId != null ? "?id=" + contractId : "" %>";
	}
	function cr(id) {
		openWin("crFrameset.jsp?id=" + id, 700, 600);
	}
	function del(id) {
		if (window.confirm("Delete this change authorization?"))
			window.location = "cas.jsp?del=" + id;
	}
	function printSum() {
		var msgWindow = window.open("../utils/print.jsp?doc=changeAuthorizationSummary.pdf<%= 
			contractId != null ? "?id=" + contractId : "" %>", "print");
		msgWindow.focus();
	}
	function printCA(id) {
		var msgWindow = open("../utils/print.jsp?doc=changeCA.pdf?id=" + id, "print");
		msgWindow.focus();
	}
<%
String del = request.getParameter("del");
if (del != null && sec.ok(Security.CO, Security.DELETE)) {
	if (attr.hasAccounting()) {
		Accounting acc = AccountingUtils.getAccounting(session);
		CRD crd = AccountingUtils.getCRD(del, acc);
		Result result = acc.deleteCRD(crd);
		EnumSet<Action> es = EnumSet.of(Action.DELETED, Action.NOT_FOUND, Action.NO_ACTION);
		if (es.contains(result.getAction())) {
			sql = "delete from files where type = 'CD' and id = '" + del + "'";
			db.dbInsert(sql);
			sql = "delete from change_request_detail where crd_id = " + del;
			db.dbInsert(sql);
		} else {
			String msg = "Unable to delete change authorization\\n----------------------\\n" 
				+ result.getMessage().replaceAll("\n", "\\n");
			out.print("window.alert(\"" + msg + "\")");
		}
	} else {
		sql = "delete from files where type = 'CD' and id = '" + del + "'";
		db.dbInsert(sql);
		sql = "delete from change_request_detail where crd_id = " + del;
		db.dbInsert(sql);
	}
}
%>
</script>
</head>
<body>
<div class="title">Change Authorizations<%= contractId != null ? " - " 
		+ companyName : "" %></div><hr>
<div class="link" onclick="openWin('crdFrameset.jsp<%= contractId != null ? "?contract_id=" 
		+ contractId : "" %>', 700, 600);">New</div>
<%= sec.ok(Security.CO, Security.PRINT) ? 
	"  &nbsp; <div class=\"link\" onclick=\"printSum();\">Print Summary</div>" : "" %>
<%= attr.hasAccounting() ? "&nbsp; <div class=\"link\" onclick=\"window.location="
	+ "'accountingSummaryCA.jsp" + (contractId != null ? "?id=" + contractId : "") 
	+ "';\">Accounting Comparison</div>" : "" %>
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<%
boolean sd = sec.ok(Security.CO, Security.DELETE);
boolean sw = sec.ok(Security.CO, Security.WRITE);
boolean sp = sec.ok(Security.CO, Security.PRINT);
%>
<tr>
	<%= sd ? "<td class=\"head left nosort\">Delete</td>" : "" %>
	<%= sw ? "<td class=\"head nosort " + (!sd ? "left" : "") + "\">Edit</td>" : "" %>
	<%= sec.ok(Security.CO, Security.PRINT) ? "<td class=\"head nosort " + (!sd && !sw ? "left" : "") 
			+ "\">Print</td>" : "" %>
	<td class="head">CA #</td>
	<td class="head">CR #</td>
	<td class="head">Code</td>
	<td class="head">Subcontractor</td>
	<td class="head">Description</td>
	<td class="head">Amount</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
sql = "select crd.*, cost_code, phase_code, division, company_name, cr.num, cr.status from "
	+ "change_request_detail as crd join contracts as con using "
	+ "(contract_id) left join job_cost_detail as jcd on crd.cost_code_id = "
	+ "jcd.cost_code_id left join company using(company_id) left join change_requests as cr using(cr_id) "
	+ "where con.job_id = "	+ attr.getJobId() + (contractId != null ? " and contract_id = " + contractId : "")
	+ " and authorization = 1 order by change_auth_num desc";
rs = db.dbQuery(sql);
boolean color = true;
String id, cr, desc;
if (CAflag != 3) {
while (rs.next()) {
	color = !color;
	id = rs.getString("crd_id");
	cr = rs.getString("num");
	desc = rs.getString("work_description");
	if (desc != null && desc.length() > 60) desc = desc.substring(0, 60) + "...";
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%= sd ? "<td class=\"left\">" + (!"Approved".equals(rs.getString("status")) ? 
		"<div class=\"link\" onclick=\"del(" + id + ");\">Delete</div>" : "&nbsp;") + "</td>" : "" %>
<%= sw ? "<td class=\"it " + (!sd ? "left" : "") + (!sp ? "right" : "") + "\"><div class=\"link\" onclick=\"edit(" + id 
		+ ");\">Edit</div></td>" : "" %>
<%= sp ? "<td class=\"right " + (!sd && !sw ? "left" : "") + "\"><div class=\"link\" onclick=\"printCA("
		+ id + ");\">Print</div></td>" : "" %>
<td class="it aright"><%= rs.getInt("change_auth_num") %></td>
<td class="it aright"><%= cr == null ? "&nbsp;" : "<div class=\"link\" onclick=\"cr(" 
	+ rs.getString("cr_id") + ");\">" + cr + "</div>" %></td>
<td class="it"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-"
	+rs.getString("phase_code") %></td>
<td class="it"><%= FormHelper.stringTable(rs.getString("company_name")) %></td>
<td class="it"><%= FormHelper.stringTable(desc) %></td>
<td class="it aright"><%= FormHelper.cur(rs.getDouble("amount")) %></td>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(id, com.sinkluge.Type.CRD, 
	"window", request) %></td>
</tr>
<%	
}
if (rs != null) rs.getStatement().close();
}
db.disconnect();
%>
</table>
</div>
</body>
</html>