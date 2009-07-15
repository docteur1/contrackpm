<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Permission, org.apache.log4j.Logger" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.CR, accounting.Accounting, accounting.CRD" %>
<%@page import="com.sinkluge.utilities.ItemLogger" %>
<%@page import="com.sinkluge.security.Name, accounting.Result, accounting.Action" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Name.CHANGES, Permission.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
Logger log = Logger.getLogger(this.getClass());
String id = request.getParameter("id");
ResultSet rs;
String sql;
String title = null;
Database db = new Database();
if (id != null) {
	sql = "select * from change_orders where co_id = " + id;
	rs = db.dbQuery(sql);
	int jobId = 0;
	if (rs.next()) {
		title = "CO# " + rs.getString("co_num") + ": " + rs.getString("co_description");
		jobId = rs.getInt("job_id");
	}
	rs.getStatement().close();
	// We've switched to a different job
	if (jobId != attr.getJobId()) {
		db.disconnect();
		response.sendRedirect("index.jsp");
		return;
	}
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
		openWin("crFrameset.jsp?id=" + id, 700, 600);
	}
	function del(id) {
		if (window.confirm("Delete this change request\n(and associated detail / change authorizations)?"))
			window.location = "index.jsp?del=" + id;
	}
	function printSum() {
		var msgWindow = open("../utils/print.jsp?doc=changeRequestSummary.pdf<%= id != null 
			? "?id=" + id : "" %>", "print");
		msgWindow.focus();
	}
	function printCR(id) {
		var msgWindow = open("../utils/print.jsp?doc=changeCR.pdf?id=" + id, "print");
		msgWindow.focus();
	}
</script>
</head>
<body>
<div class="title">Change Requests<%= title != null ? " of " + title : "" %></div><hr>
<div class="link" onclick="openWin('crFrameset.jsp', 700, 600);">New</div> &nbsp;
<%= sec.ok(Name.CHANGES, Permission.PRINT) ? 
	" <div class=\"link\" onclick=\"printSum();\">Print Summary</div> &nbsp;" : ""  %>
<%= attr.hasAccounting() ? "<div class=\"link\" onclick=\"window.location="
	+ "'accountingSummaryCR.jsp" + (id != null ? "?id=" + id : "") + 
	"';\">Accounting Comparison</div>" : "" %>
<hr>
<%
boolean sd = sec.ok(Name.CHANGES, Permission.DELETE);
boolean sw = sec.ok(Name.CHANGES, Permission.WRITE);
boolean sp = sec.ok(Name.CHANGES, Permission.PRINT);
String del = request.getParameter("del");
rs = null;
if (del != null && sd) {
	boolean delete = true;
	String msg = "";
	if (attr.hasAccounting()) {
		CR cr = AccountingUtils.getCr(del);
		if (cr != null) {
			CRD crd;
			Accounting acc = AccountingUtils.getAccounting(session);
			rs = db.dbQuery("select crd_id from change_request_detail where cr_id = " + del);
			Result result;
			boolean error;
			while (rs.next()) {
				crd = AccountingUtils.getCRD(rs.getString("crd_id"), cr, acc);
				if (crd != null) {
					result = acc.deleteCRD(crd);
					error = !java.util.EnumSet.of(Action.DELETED, Action.NOT_FOUND, Action.NO_ACTION).contains(result.getAction());
					if (error) {
						delete = false;
						msg += "Accounting (Detail): " + result.getMessage() + "<br>";
						break;
					}
				}
			}
			if (delete) {
				result = acc.deleteCR(cr);
				if (!java.util.EnumSet.of(Action.DELETED, Action.NO_ACTION).contains(result.getAction())) {
					delete = false;
					msg += "Accounting (CR) " + result.getMessage() + "<br>";
				}
			}
		}
	}
	if (delete) {
		sql = "delete from files where type = 'CR' and id = '" + del + "'";
		db.dbInsert(sql);
		sql = "select * from change_request_detail where cr_id = " + del;
		rs = db.dbQuery(sql, true);
		sql = "delete from files where type = 'CD' and id = '";
		while (rs.next()) {
			db.dbInsert(sql + rs.getString("crd_id") + "'");
			ItemLogger.Deleted.update(com.sinkluge.Type.CRD, rs.getString("crd_id"), session);
			rs.deleteRow();
		}
		if (rs != null) rs.getStatement().close();
		sql = "delete from change_requests where cr_id = " + del;
		ItemLogger.Deleted.update(com.sinkluge.Type.CR, del, session);
		db.dbInsert(sql);
	}
	if (!"".equals(msg)) out.print("<div class=\"red bold\">Unable to delete: " + msg + "</div><hr>");
}
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<%= sd ? "<td class=\"head left nosort\">Delete</td>" : "" %>
	<%= sw ? "<td class=\"head nosort " + (!sd ? "left" : "") + "\">Edit</td>" : "" %>
	<%= sp ? "<td class=\"head nosort " + (!sd && !sw ? "left" : "") 
			+ "\">Print</td>" : "" %>
	<td class="head">CR #</td>
	<td class="head">CO #</td>
	<td class="head">Title</td>
	<td class="head">Status</td>
	<td class="head">Date</td>
	<td class="head">Details</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
sql = "select cr.*, count(crd_id) as num_of_details, co_num from change_requests as cr left join "
	+ "change_request_detail using(cr_id) left join change_orders as co using(co_id) "
	+ "where cr.job_id = " + attr.getJobId() + (id != null ? " and co_id = " + id : "")
	+ " group by cr_id order by num desc";
rs = db.dbQuery(sql);
boolean color = true;
while (rs.next()) {
	color = !color;
	id = rs.getString("cr_id");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%= sd ? "<td class=\"left\"><div class=\"link\" onclick=\"del(" + id + ");\">Delete</div></td>" : "" %>
<%= sw ? "<td class=\"it " + (!sd ? "left" : "") + (!sp ? "right" : "") + "\"><div class=\"link\" onclick=\"edit(" + id 
		+ ");\">Edit</div></td>" : "" %>
<%= sp ? "<td class=\"right " + (!sd && !sw ? "left" : "") + "\"><div class=\"link\" onclick=\"printCR("
		+ id + ");\">Print</div></td>" : "" %>
<td class="it aright"><%= rs.getInt("num") %></td>
<td class="it aright"><%= FormHelper.stringTable(rs.getString("co_num")) %></td>
<td class="it"><%= FormHelper.stringTable(rs.getString("title")) %></td>
<td class="it"><%= FormHelper.stringTable(rs.getString("status")) %></td>
<td class="it"><%= FormHelper.medDate(rs.getDate("date")) %></td>
<td class="it aright"><%= FormHelper.stringTable(rs.getString("num_of_details")) %></td>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(id, com.sinkluge.Type.CR, "window", request) %></td>
</tr>
<%	
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>