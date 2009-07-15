<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(sec.SUBCONTRACT,4)) response.sendRedirect("../accessDenied.html");
boolean sw = sec.ok(sec.SUBCONTRACT,sec.WRITE);
%>
<html>
<head>
		<link rel="stylesheet" href="../../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<script src="../../utils/table.js"></script>
		<script language="javascript">
			function del(id) {
				if(confirm("Delete this pay request period?")) location = "deleteOPR.jsp?id=" + id;
			}
			function openWin(loc, h, w) {
				var msgWindow=window.open('','pr','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=' + w + ',height=' + h + ',left=25,top=100');
				msgWindow.location.href = loc;
				if (msgWindow.opener == null) msgWindow.opener = self;
				msgWindow.focus();		
			}
		</script>
</head>
<body>
<div class="title">Pay Request Periods</div><hr>
<%
if (sw) out.print("<a href=\"newOPR.jsp\">New</a><hr>");
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
<%
String query = "select opr_id, period, paid_by_owner, locked from owner_pay_requests where job_id = " + attr.getJobId()
	+ " order by period desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (sw) out.print("<td class=\"left head nosort\">Delete</td><td class=\"nosort head\">Print</td><td class=\"nosort head\">Edit</td><td class=\"head\">Period</td>");
else out.print("<td class=\"left head\">Period</td>");
%>
		<td class="head">Accepted</td>
		<td class="head">Owner's Payment</td>
		<td class="head">Closed</td>
		<td class="right head">ID</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
int opr_id = 0;
boolean color = false;
String period;
ResultSet prs;
int numPrs, numAppPrs;
boolean ret;
while (rs.next()) {
	opr_id = rs.getInt("opr_id");
	query = "select count(*) from pay_requests where opr_id = " + opr_id;
	prs = db.dbQuery(query);
	prs.next();
	numPrs = prs.getInt(1);
	if (prs != null) prs.close();
	query = "select count(*) from pay_requests where date_approved is not null and opr_id = " + opr_id;
	prs = db.dbQuery(query);
	prs.next();
	numAppPrs = prs.getInt(1);
	if (prs != null) prs.close();
	prs = null;
	period = rs.getString("period");
	ret = period.equals("Retention");
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
	if (sw) {
		if (!ret) {
			out.print("<td class=\"left\"><a href=\"javascript: del(" + opr_id + ");\">Delete</a></td>");
			out.print("<td class=\"it\"><a href=\"../../utils/print.jsp?doc=pr" + (!ret?"":"Retention") + "Report.pdf?id=" + opr_id + "\" target=\"print\">Print</a></td>");
		} else {
			out.print("<td class=\"left\">&nbsp;</td>");
			out.print("<td class=\"it\"><a href=\"../../utils/print.jsp?doc=pr" + (!ret?"":"Retention") + "Report.pdf?id=" + opr_id + "\" target=\"print\">Print</a></td>");
		}
		out.print("<td class=\"it\"><a href=\"javascript: openWin('modifyOPR.jsp?id=" + opr_id + "',300,300)\">Edit</a></td>");
		out.print("<td class=\"it\"><a href=\"reviewPayRequests.jsp?id=" + opr_id + "\">" + period + "</a></td>");
	} else out.print("<td class=\"left\"><a href=\"reviewPayRequests.jsp?id=" + opr_id + "\">" + period + "</a></td>");
%>
		<td class="left acenter"><%= numAppPrs + " of " + numPrs %></td>
		<td class="input acenter">
<%
	if (rs.getDate("paid_by_owner") != null) out.print("<img src=\"../../images/checkmark.gif\">");
	else out.print("&nbsp;");
%>
		</td>
		<td class="input acenter">
<%
	if (rs.getBoolean("locked")) out.print("<img src=\"../../images/checkmark.gif\">");
	else out.print("&nbsp;");
%>
		</td>
<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(rs.getString("opr_id"), com.sinkluge.Type.OPR, 
		"window", request) %></td>
	</tr>
<%
	color = !color;
}
if (rs != null) rs.close();
rs = null;
db.disconnect();
%>
</table>
</div>
</body>
</html>
