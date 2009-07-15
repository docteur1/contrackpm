<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="true"/>
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="action" value="../payRequests/payRequest.jsp"/>
	</jsp:include>
<font size="+1">Pay Requests</font><hr>
<a href="../manage/">Home</a> &gt; Pay Requests &nbsp; <a href="newPR.jsp">New Pay Request</a><hr>
<%
String query = "select pr_id, locked, period, paid_by_owner, date_approved, final, date_paid, request_num, lien_waiver from owner_pay_requests as opr, "
	+ "pay_requests as pr where opr.opr_id = pr.opr_id and contract_id = " + db.contract_id + " order by request_num desc";
db.connect();
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
%>
&nbsp;<br>
<table cellspacing="0" cellpadding="3">
	<tr>
		<td class="left head">&nbsp;</td>
		<td class="head" align="right">Period</td>
		<td class="head" align="right">Request</td>
		<td class="head">Final</td>
		<td class="head">Owner</td>
		<td class="head">Accepted</td>
		<td class="head">Paid</td>
		<td class="head">Closed</td>
		<td class="right head">Lien Waiver</td>
	</tr>
<%
boolean color = false;
if (!rs.isBeforeFirst()) {
%>
	<tr>
		<td class="left right" colspan="9" align="center"><b>No pay requests found!</b></td>
	</tr>
<%
}
String period;
while (rs.next()) {
	period = rs.getString("period");
%>
	<tr <% if(color) out.print("class=\"gray\""); else out.print ("class=\"white\""); %> onMouseOver="rC(this)"; onMouseOut="rCl(this)";>
<%
	if (!period.equals("Retention")) {
%>
		<td class="left right"><a href="modifyPR.jsp?pr_id=<%= rs.getString("pr_id") %>">Open</a></td>
<%
	} else {
%>
		<td class="left right"><a href="viewRetention.jsp?pr_id=<%= rs.getString("pr_id") %>">Open</a></td>
<%
	}
%>
		<td class="it" align="right"><%= rs.getString("period") %></td>
		<td class="it" align="right"><%= rs.getString("request_num") %></td>
		<td class="it" style="padding: 0px; text-align: center;"><% if (rs.getBoolean("final")) out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
		<td class="it" style="padding: 0px; text-align: center;"><% if (rs.getDate("paid_by_owner") != null) out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
		<td class="it" style="padding: 0px; text-align: center;"><% if (rs.getDate("date_approved") != null) out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
		<td class="it" style="padding: 0px; text-align: center;"><% if (rs.getDate("date_paid") != null) out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
		<td class="it" style="padding: 0px; text-align: center;"><% if (rs.getBoolean("locked")) out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
		<td class="right"><%= rs.getString("lien_waiver") %></td>
	</tr>
<%
	color = !color;
}
%>
</table>
<%
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.disconnect();
%>
</td>
</tr>
</table>
</body>
</html>