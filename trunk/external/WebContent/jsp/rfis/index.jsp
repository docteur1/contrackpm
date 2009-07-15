<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.util.FormHelper" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="true" />
	<jsp:param name="printDisable" value="true" />
	</jsp:include>
<font size="+1">RFIs</font><hr>
<a href="../manage/">Home</a> &gt; RFIs<hr>
<table style="margin-top: 10px;" cellspacing="0" cellpadding="3">
<tr>
	<td class="left head">Open</td>
	<td class="head">Complete</td>
	<td class="head">Number</td>
	<td class="head aright">Date Sent</td>
	<td class="head">Respond By</td>
	<td class="head">Urgency</td>
	<td class="right head">Request</td>
</tr>
<%! 
	String bold(boolean b) {
		return b?"bold":"";
	}
%>
<%
String query = "select * from rfi where company_id = " + db.company_id 
	+ " and job_id = " + db.job_id + " order " + "by costorder(rfi_num)";
ResultSet rs = db.dbQuery(query);
boolean color = true;
boolean b = false;
if (!rs.isBeforeFirst()) {
%>
<tr>
	<td class="left right acenter" colspan="7">No RFIs found!</td>
</tr>
<%
}
while (rs.next()) {
	color = !color;
	b = rs.getBoolean("e_submit");
%>
<tr <% if(color) out.print("class=\"gray\""); %> onMouseOver="rC(this);" onMouseOut="rCl(this);" onclick="location.href='modifyRFI.jsp?id=<%= rs.getString("rfi_id") %>'">
	<td class="left right <%= bold(b) %>"><a href="modifyRFI.jsp?id=<%= rs.getString("rfi_id") %>">Open</a></td>
		<%if (rs.getDate("date_received") != null){ %>
	<td class="it acenter <%= bold(b) %>"><img src="../images/checkmark.gif"/></td><%} 
	else {%>
	<td class="it acenter <%= bold(b) %>">&nbsp;</td><%} %>
	<td class="it aright <%= bold(b) %>"><%= FormHelper.stringTable(rs.getString("rfi_num")) %></td>
	<td class="it aright <%= bold(b) %>"><%= FormHelper.medDate(rs.getDate("date_created")) %></td>
	<td class="it aright <%= bold(b) %>"><%= FormHelper.medDate(rs.getDate("respond_by")) %></td>
	<td class="it <%= bold(b) %>"><%= rs.getString("urgency") %></td>
	<td class="right <%= bold(b) %>"><div class="clip"><%= FormHelper.stringTable(rs.getString("request")) %></div></td>
</tr>
<%
}
rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</body>
</html>


