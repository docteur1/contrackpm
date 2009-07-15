<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet, com.sinkluge.util.Widgets" %>
<%@page import="com.sinkluge.util.FormHelper, java.sql.Statement" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="true"/>
	<jsp:param name="contractDisable" value="true" />
	</jsp:include>
<font size="+1">View Submittal</font><hr>
<%
String id = request.getParameter("id");
String query = "select company_name, company.company_id from submittals join job_contacts on architect_id = job_contact_id "
	+ "join company using(company_id) where submittal_id = " + id;
ResultSet rs = db.dbQuery(query);
String archName = "ERROR";
boolean isArchitect = false;
if (rs.first()) {
	archName = rs.getString(1);
	isArchitect = rs.getInt(2) == db.company_id;
}
if (!isArchitect) response.sendRedirect("index.jsp");
rs.getStatement().close();
query = "select cost_code, submittals.*, company_name from submittals left join contracts using(contract_id) join "
	+ "job_cost_detail on submittals.cost_code_id = job_cost_detail.cost_code_id left join company using(company_id) where submittal_id = " + id;
rs = db.dbQuery(query);
rs.first();
%>
<script>
	var printName = "sl<%= (isArchitect?"Architect":"") %>.pdf?id=<%= id %>";
</script>
<a href="../manage/">Home</a> &gt; <a href="index.jsp">Submittals</a> &gt; View Submittal &nbsp; 
	<%= Widgets.attachments(id, "SL", db) %><hr>
<input type="hidden" name="id" value="<%= id %>">
<table>
<tr>
	<td class="lbl">Number:</td>
	<td><%= FormHelper.stringTable(rs.getString("submittal_num")) %></td>
</tr>
<tr>
	<td class="lbl">Type:</td>
	<td><%= rs.getString("submittal_type") %></td>
</tr>
<tr>
	<td class="lbl">Spec. No.</td>
	<td><%= (FormHelper.stringNull(rs.getString("alt_cost_code"))!=null?rs.getString("alt_cost_code"):rs.getString("cost_code")) %></td>
</tr>
<tr>
	<td class="lbl">Architect:</td>
	<td><%= archName %></td>
</tr>
<tr>
	<td class="lbl">Contractor:</td>
	<td><%= (rs.getString("company_name") == null ? db.get("short_name") : rs.getString("company_name")) %></td>
</tr>
<tr>
	<td class="lbl">Details:</td>
	<td><%= FormHelper.stringTable(rs.getString("description")) %></td>
</tr>
<tr>
	<td class="lbl">Remarks:</td>
	<td><%= FormHelper.stringTable(rs.getString("comment_to_architect")) %></td>
</tr>
<tr>
	<td class="lbl">eStamp:</td>
	<td><input type="checkbox" name="stamp" value="y" 
		<%= FormHelper.chk(rs.getBoolean("architect_stamp")) %>>
		 - <i>Describe approval/revision/rejection below or attach documentation.</i></td>
</tr>
<%
boolean editable = !rs.getBoolean("architect_stamp") && rs.getString("contractor_stamp") == null;
if (editable) {
%>
<tr>
	<td class="lbl">Comments:</td>
	<td><textarea name="comments" cols="60" rows="4"><%= FormHelper.string(rs.getString("comment_from_architect")) %></textarea></td>
</tr>
<%
} else {
%>
<tr>
	<td class="lbl">Comments:</td>
	<td><%= FormHelper.stringTable(rs.getString("comment_from_architect")) %></td>
</tr>
<%
	if (FormHelper.stringNull(rs.getString("contractor_stamp")) != null) {
%>
<tr>
	<td class="lbl">Stamp:</td>
	<td class="red bold"><%= FormHelper.stringTable(rs.getString("contractor_stamp")) %></td>
</tr>
<tr>
	<td>&nbsp;</td>
<%
ResultSet temp = db.dbQuery("select txt from reports where id = 'submittalStamp'");
String stamp = null;
if (temp.first()) stamp = temp.getString(1);
temp.getStatement().close();
temp = null;
%>
	<td><i><%= (stamp!=null?stamp:"&nbsp;") %></i></td>
</tr>
<%
	}
}
%>
</table>
<%
	Statement stmt = db.getStatement();
	stmt.executeUpdate("update submittals set e_submit = 0 where submittal_id = " + id);
	stmt.close();
	stmt = null;
rs.getStatement().close();
rs = null;
db.disconnect();
if (editable) {
%>
<script language="javascript">
	var m = document.main;
	m.action = "processSubmittal.jsp";
	document.getElementById("sBt").disabled = false;
	var d = m.comments;
	d.required = true;
	d.eName = "Remarks";
	d.focus();
</script>
<%
}
%>
</body>
</html>


