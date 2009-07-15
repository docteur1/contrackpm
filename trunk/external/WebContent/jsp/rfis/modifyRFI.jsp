<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet, com.sinkluge.util.Widgets" %>
<%@page import="com.sinkluge.util.FormHelper" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="contractDisable" value="true" />
	<jsp:param name="saveDisable" value="true" />
	</jsp:include>
<font size="+1">RFI</font><hr>
<%
String id = request.getParameter("id");
%>
<a href="../manage/">Home</a> &gt; <a href="index.jsp">RFIs</a> &gt; RFI &nbsp; <%= Widgets.attachments(id, "RF", db) %><hr>
<%
String query = "select * from rfi where rfi_id = " + id;
ResultSet rs = db.dbQuery(query, true);
if (rs.first()) {
	rs.updateBoolean("e_submit", false);
	rs.updateRow();
%>
<script>
	var printName = "rfi.pdf?id=<%= id %>";
</script>
<table>
<tr>
	<td class="lbl">Complete:</td>
	<%if (rs.getDate("date_received") != null){ %>
	<td>Yes</td><%} 
	else {%>
	<td>No</td><%} %>
</tr>
<tr>
	<td class="lbl">Number:</td>
	<td><%= FormHelper.stringTable(rs.getString("rfi_num")) %></td>
</tr>
<tr>
	<td class="lbl">Date Sent:</td>
	<td><%= FormHelper.medDate(rs.getDate("date_created")) %></td>
</tr>
<tr>
	<td class="lbl">Respond By:</td>
	<td><%= FormHelper.medDate(rs.getDate("respond_by")) %></td>
</tr>
<tr>
	<td class="lbl">From:</td>
	<td><%= FormHelper.stringTable(rs.getString("user")) %></td>
</tr>
<tr>
	<td class="lbl">Request:</td>
	<td><%= FormHelper.stringTable(rs.getString("request")) %></td>
</tr>
<tr>
	<td class="lbl">Urgency:</td>
	<td><%= rs.getString("urgency") %></td>
</tr>
<tr>
	<td class="lbl">Reply:</td>
<%
boolean editable = rs.getDate("date_received") == null && FormHelper.stringNull(rs.getString("reply")) == null;
if (!editable) {
%>
	<td><%= FormHelper.stringTable(rs.getString("reply")) %></td>
<%
} else {
%>
	<td><input type="hidden" name="id" value="<%= id %>"><textarea name="reply" cols="80" rows="6"><%= FormHelper.string(rs.getString("reply")) %></textarea>
<%
}
%>
</tr>
</table>
<%
	if (editable) {
%>
<script>
	document.getElementById("sBt").disabled = false;
	var m = document.main;
	m.action = "processRFI.jsp";
	var d = m.reply;
	d.required = true;
	d.eName ="Reply";
	d.focus();
	d.select();
</script>
<%
	}
} else {
%>
<div class="bold">RFI not found!</div>
<%	
}
rs.getStatement().close();
rs = null;
db.disconnect();
%>
</body>
</html>


