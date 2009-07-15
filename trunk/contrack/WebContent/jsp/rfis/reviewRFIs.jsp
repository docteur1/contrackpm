<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="java.util.Date" %>
<%@page import="com.sinkluge.security.Security"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.RFI, Security.READ)) response.sendRedirect("../accessDenied.html");
boolean sp = sec.ok(Security.RFI, Security.PRINT);
boolean sw = sec.ok(Security.RFI, Security.WRITE);
boolean sd = sec.ok(Security.RFI, Security.DELETE);
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<script src="../utils/table.js"></script>
	<script type="text/javascript">
		function newRFI() {
			msgWindow=open('newRFIFrameset.jsp','rfi','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=450,left=25,top=50');
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function modifyRFI(id) {
			msgWindow=open('','rfi','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=550,left=25,top=50');
			msgWindow.location.href = "modifyRFIFrameset.jsp?id=" + id;
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function del(id) {
			if(confirm("Delete this RFI?")) location="deleteRFI.jsp?id=" + id;
		}
	</script>
	</head>
	<body>
		<div class="title">Requests for Information</div><hr/>
		<a href="javascript: newRFI()">New</a>
<%
if(sp) {
%>
	&nbsp;&nbsp;<a href="rfiSummary.jsp" target="print">Summary</a>
		<%
}
String query = "select rfi.*, substring(rfi.request,1,50) as req, company_name "
	+ "from rfi join company using(company_id) where job_id = " + attr.getJobId()
	+ " order by company_name, costorder(rfi_num) desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String id;
		%>
		<hr>
<div style="margin-bottom: 8px;"><span class="bold">Bold</span> = eSubmitted and not read.</div>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
<%
if (sd) out.print("<td class=\"left head nosort\">Delete</td>");
if (!sd && sp) out.print("<td class=\"left head nosort\">Print</td>");
else if (sd && sp) out.print("<td class=\"head nosort\">Print</td>");
if (sw && !(sp || sp)) out.print("<td class=\"left head nosort\">Edit</td>");
if (sw && (sp || sp)) out.print("<td class=\"head nosort\">Edit</td>");
%>
		<td class="head">Num</td>
		<td class="head">Company</td>
		<td class="head">Date Sent</td>
		<td class="head">Date Rec'd</td>
		<td class="head">eUpdate</td>
		<td class="head">Request</td>
		<td class="head right">ID</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%! 
String bold(boolean b) {
	return (b?"bold":"");
}
%>
<%
boolean cThis = true;
Date date_received;
boolean eSubmit = false;
while (rs.next()){
	cThis = !cThis;
	date_received = rs.getDate("date_received");
	id = rs.getString("rfi_id");
	eSubmit = rs.getBoolean("e_submit");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (cThis) out.print("class=\"gray\""); %>>
<%
if (sd) {
%>
	<td class="left <%= !sp&&!sw?"right":"" %> <%= bold(eSubmit) %>"><a href="javascript: del('<%= id %>');">Delete</a></td>
<%
}
if (sp) {
%>
	<td class="it <%= !sd?"left":"" %> <%= !sw?"right":"" %> <%= bold(eSubmit) %>"><a href="../utils/print.jsp?doc=rfi.pdf?id=<%= id %>" target="print">Print</a></td>
<%
}
if (sw) {
%>
	<td class="right <%= bold(eSubmit) %>"><div class="link" onclick="modifyRFI(<%= id %>);">Edit</div></td>
<%
}
%>
				<td class="it aright <%= bold(eSubmit) %>"><%= rs.getString("rfi_num") %></td>
				<td class="it <%= bold(eSubmit) %>"><%= rs.getString("company_name") %></td>
				<td class="it aright <%= bold(eSubmit) %>"><%= FormHelper.medDate(rs.getDate("date_created")) %></td>
				<td class="it aright <%= bold(eSubmit) %>"><%= FormHelper.medDate(date_received) %></td>
				<td class="input"><%= Widgets.checkmark(rs.getBoolean("e_update"), request) %></td>
				<td class="it <%= bold(eSubmit) %>"><%= rs.getString("req") %></td>
				<td class="right <%= bold(eSubmit) %>"><%= com.sinkluge.utilities.Widgets.logLinkWithId(id, 
					com.sinkluge.Type.RFI, "window", request) %></td>
			</tr>
			<%
			}
			rs.getStatement().close();
			rs = null;
			%>
		</table>
		</div>
<%
db.disconnect();
%>
	</body>

</html>
