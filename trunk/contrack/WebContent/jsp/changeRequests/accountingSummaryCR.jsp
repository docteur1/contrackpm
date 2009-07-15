<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="accounting.CR, accounting.Accounting"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
Logger log = Logger.getLogger(this.getClass());
if (!sec.ok(Security.SUBCONTRACT, Security.READ) && !attr.hasAccounting()) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
ResultSet rs;
String sql;
String title = null;
Database db = new Database();
if (id != null) {
	sql = "select * from change_orders where co_id = " + id;
	rs = db.dbQuery(sql);
	if (rs.next()) title = "CO# " + rs.getString("co_num") + ": " + rs.getString("co_description");
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
	function edit(id) {
		var msgWindow = open("crFrameset.jsp?id=" + id, "cr", "toolbar=no,location=no,directories=no,"
			+ "status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=600,left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
</script>
</head>
<body>
<div class="title">Accounting Comparison<%= title != null ? " of " + title : "" %></div><hr>
<div class="link" onclick="window.location='index.jsp<%= id != null ? "?id=" + id : "" 
	%>'">Change Requests</div>
 &gt; Accounting Comparison &nbsp; 
<div class="link" onclick="printWin('printAccountingSummaryCR.jsp<%= id != null ? "?id=" + id : "" 
	%>');">Print</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<td class="head">CR #</td>
	<td class="head">Title</td>
	<td class="head">Amount</td>
	<td class="head">Exists</td>
	<td class="head">Acc Title</td>
	<td class="head">Acc Amt</td>
	<td class="head">Match</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
sql = "select cr.cr_id, num, title, sum(amount + fee + bonds) as amount from change_requests as cr "
	+ "join change_request_detail using(cr_id) where cr.job_id = " + attr.getJobId() 
	+ (id != null ? " and co_id = " + id : "") + " group by cr.cr_id order by num desc";
rs = db.dbQuery(sql);
boolean color = true;
Accounting acc = AccountingUtils.getAccounting(session);
double amount, accCr;
CR cr;
while (rs.next()) {
	color = !color;
	amount = rs.getDouble("amount");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<td class="left right"><div class="link" onclick="edit(<%= rs.getString("cr_id") %>)">Edit</div></td>
<td class="it aright"><%= rs.getString("num") %></td>
<td class="it"><%= rs.getString("title") %></td>
<td class="it"><%= FormHelper.cur(amount) %></td>
<%
	cr = acc.getCR(attr.getJobNum(), rs.getString("num"));
	if (cr != null) {
		log.debug("cr returned");
		accCr = acc.getCROwner(cr);
		log.debug("change amount: " + accCr);
%>
<td class="input acenter"><%= Widgets.checkmark(true, request) %></td>
<td class="it"><%= cr.getTitle() %></td>
<td class="it aright"><%= FormHelper.cur(accCr) %></td>
<td class="input acenter"><%= Widgets.checkmark(accCr == amount, request) %></td>
<%
	} else {
		log.debug("no cr found");
%>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<td class="it">&nbsp;</td>
<%
	}
%>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(rs.getString("cr_id"), com.sinkluge.Type.CR, 
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