<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.fax.FaxStatus, java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %> 
<%@page import="gnu.hylafax.job.SendEvent, com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
boolean admin = request.getParameter("admin") != null;
if (admin && !sec.ok(com.sinkluge.security.Name.ADMIN, com.sinkluge.security.Permission.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String query = "select fax_log.*" + (admin ? ", users.first_name, users.last_name" : "" ) + " from fax_log " 
	+ (admin ? "join users on fax_log.user_id = users.id " : "where user_id = " + attr.getUserId()) 
	+ " order by fax_log_id desc limit 75";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<script>
		function cancel(id) {
			if (window.confirm("Cancel this fax?")) {
				document.getElementById("main").style.display = "none";
				document.getElementById("hid").style.display = "inline";
				window.location = "cancelFax.jsp?<%= admin ? "admin=t&" : "" %>job=" + id;
				window.setInterval(wait, 1000);
			}
		}
		function wait(wait) {
			w = document.getElementById("wait").innerHTML += " .";
		}
	</script>
</head>
<body>
<div id="hid" style="display: none;"><font size="+1">Cancelling Fax</font><hr>
	<span class="bold" id="wait">Please wait .</span></div>
<div id="main">
<div class="title">Fax Log</div><hr>
<%
if (admin) {
%>
<div class="link" onclick="window.location='../admin/superAdmin.jsp';">Administration</div> &gt; Fax Log<hr>
<%
}
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
	<td class="left head nosort">Cancel</td>
	<td class="head">Job Id</td>
	<%= admin ? "<td class=\"head\">User</td>" : "" %>
	<td class="head">Fax Number</td>
	<td class="head">Document</td>
	<td class="head">Status</td>
	<td class="head">Contact</td>
	<td class="head">Company</td>
	<td class="right head">Description</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean c = true;
String p;
String stat;
boolean cancel;
while(rs.next()) {
	c = !c;
	p = rs.getString("job_id");
	stat = rs.getString("status");
	cancel = stat == null || stat.equals(SendEvent.REASON_BLOCKED) || stat.indexOf("Requeued") != -1;
	if (stat == null) stat = "Sending";
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (c) out.print("class=\"gray\""); %>>
	<td class="left right"><%= cancel ? "<div class=\"link\" onclick=\"cancel(" + p + ");\">Cancel</div>" 
		: "&nbsp;" %></td>
	<td class="it"><%= p %></td>
<%
if (admin) {
%>
	<td class="it"><%= rs.getString("first_name") + " " + rs.getString("last_name") %></td>
<%
}
%>
	<td class="it"><%= FormHelper.stringTable(rs.getString("fax")) %></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("document")) %></td>
	<td class="it <%= stat.indexOf("Fail")== -1 ? "" : "red bold" %>"><%= stat %></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("contact_name")) %></td>
	<td class="it"><%= FormHelper.stringTable(rs.getString("company_name")) %></td>
	<td class="right"><%= FormHelper.stringTable(rs.getString("description")) %></td>
</tr>
<%
}
rs.close();
if (!admin) db.dbInsert("update fax_log set viewed = 1 where status is not null and user_id = " + attr.getUserId());
// Remove the session if the queue is empty and there is an error as we've now viewed it.
FaxStatus fs = (FaxStatus) session.getAttribute("fax_status");
if (fs != null) {
	if (fs.hasError() && fs.getQueue() == 0) session.removeAttribute("fax_status");
}
db.disconnect();
%>
</table>
</div>
</div>
</body></html>
