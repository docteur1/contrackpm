<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
boolean my = request.getParameter("my") != null;
if (!my && !sec.ok(Security.TRANSMITTALS, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
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
		var msgWindow = open(loc, "tr", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function printSum() {
		var msgWindow = open("printSummary.jsp<%= my ? "?my=t" : "" %>", "print");
		msgWindow.focus();
	}
	function printTrans(id) {
		var msgWindow = open("../utils/print.jsp?doc=Transmittal.pdf?id=" + id, "print");
		msgWindow.focus();
	}
	function del(id) {
		if (window.confirm("Delete this transmittal?")) window.location = "?<%= my ? "my=t&" : "" %>del=" + id;
	}
</script>
</head>
<body>
<div class="title"><%= my ? "My " : ""  %>Transmittals</div><hr>
<%
boolean hasLink = false;
if (my || sec.ok(Security.TRANSMITTALS, Security.WRITE)) {
	out.println("<div class=\"link\" onclick=\"openWin('newTransmittal.jsp" + (my ? "?my=t" : "") + 
		"', 700, 600);\">New</div> &nbsp; ");
	hasLink = true;
}
if (my || sec.ok(Security.CO, Security.PRINT)) {
	out.println("<div class=\"link\" onclick=\"printSum();\">Print Summary</div> &nbsp;");
	hasLink = true;
}
if (hasLink) out.println("<hr>");
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
<%
boolean sd = sec.ok(Security.CO, Security.DELETE);
boolean sp = sec.ok(Security.CO, Security.PRINT);
%>
	<%= sd ? "<td class=\"head left nosort\">Delete</td>" : "" %>
	<td class="head nosort <%= !sd ? "left" : "" %>">Edit</td>
	<%= sp ? "<td class=\"head nosort\">Print</td>" : "" %>
	<td class="head">Company</td>
	<td class="head">Date</td>
	<td class="head">Status</td>
	<td class="head">Description of Attachments</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
Database db = new Database();
if (request.getParameter("del") != null) {
	db.dbInsert("delete from transmittal where id = " + request.getParameter("del"));
	db.dbInsert("delete from files where type = 'TR' and id = " + request.getParameter("del"));
	com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.TRANSMITTAL,
		request.getParameter("del"), session);
}
String sql = "select id, company.company_name, transmittal.company_name, created, transmittal_status, "
	+ "transmittal.description from transmittal left join company using(company_id) ";
if (my) sql += " where my = 1 and user_id = " + attr.getUserId();
else sql += " where job_id = " + attr.getJobId();
sql += " order by created desc";
ResultSet rs = db.dbQuery(sql);
String id;
boolean color = true;
while (rs.next()) {
	color = !color;
	id = rs.getString("id");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<%= sd ? "<td class=\"left\"><div class=\"link\" onclick=\"del(" + id + ");\">Delete</div></td>" : "" %>
	<td class="it <%= !sd ? "left" : "" %> <%= !sp ? "right" : "" %>"><div class="link" 
		onclick="openWin('frameset.jsp?id=<%= id + (my ? "&my=t" : "") %>', 700, 600);">Edit</div></td>
	<%= sp ? "<td class=\"right\"><div class=\"link\" onclick=\"printTrans(" + id + ");\">Print</div></td>" :
		"" %>
	<td class="it"><%= FormHelper.stringTable(rs.getString("transmittal.company_name") == null || 
		"".equals(rs.getString("transmittal.company_name")) ? rs.getString("company.company_name") :
		rs.getString("transmittal.company_name")) %></td>
	<td class="it"><%= FormHelper.medDate(rs.getDate("created")) %></td>
	<td class="it"><%= rs.getString("transmittal_status") %></td>
	<td class="it"><%= FormHelper.stringTable(FormHelper.left(rs.getString("description"), 37)) %></td>
	<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(id, 
			com.sinkluge.Type.TRANSMITTAL, "window", request) %></td>
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