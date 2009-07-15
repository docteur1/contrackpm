<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.util.FormHelper" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="true" />
	<jsp:param name="printDisable" value="true" />
	</jsp:include>
<font size="+1">Submittals</font><hr>
<a href="../manage/">Home</a> &gt; Submittals<hr>
<%
db.connect();
String query = "select * from submittals where contract_id = " + db.contract_id 
	+ " order by costorder(submittal_num) desc";
ResultSet rs = db.dbQuery(query);
boolean hasSubmittals = false;
boolean bold, color = true;
if (db.contract_id != 0 && rs.isBeforeFirst()) {
	hasSubmittals = true;
%>
<table cellspacing="0" cellpadding="3">
<tr>
<td class="head left">Open</td>
<td class="head">Number</td>
<td class="head">Type</td>
<td class="head">From Architect</td>
<td class="head">Attempt</td>
<td class="head">Status</td>
<td class="head right">Description</td>
</tr>
<%! 
	String bold(boolean b) {
		return b?"bold":"";
	}
%>
<%
while (db.contract_id != 0 && rs.next()) {
	color = !color;
	bold = rs.getBoolean("e_submit") && (rs.getDate("date_received") == null || rs.getDate("date_from_architect") != null);
%>
<tr <% if(color) out.print("class=\"gray\""); else out.print ("class=\"white\""); %> onMouseOver="rC(this)"; onMouseOut="rCl(this)";>
	<td class="left right <%= bold(bold) %>"><a href="viewSubmittal.jsp?id=<%= rs.getString("submittal_id") %>">Open</a></td>
	<td class="it aright <%= bold(bold) %>"><%= FormHelper.stringTable(rs.getString("submittal_num")) %></td>
	<td class="it <%= bold(bold) %>"><%= rs.getString("submittal_type") %></td>
	<td class="it aright <%= bold(bold) %>"><%= FormHelper.medDate(rs.getDate("date_from_architect")) %></td>
	<td class="it aright <%= bold(bold) %>"><%= rs.getInt("attempt") %></td>
	<td class="it <%= bold(bold) %>"><%= rs.getString("submittal_status") %></td>
	<td class="right <%= bold(bold) %>"><div class="clip"><%= FormHelper.stringTable(rs.getString("description")) %></div></td>
</tr>
<%
}
%>
</table>
<%
}
rs.getStatement().close();
query = "select submittals.submittal_id, submittal_type, submittal_num, company_name, submittals.description from submittals left join contracts on "
	+ "submittals.contract_id = contracts.contract_id left join company using(company_id) join submittal_links using(submittal_id) "
	+ "where submittal_links.contract_id = " + db.contract_id + " order by company_name, costorder(submittal_num) desc";
rs = db.dbQuery(query);
if (rs.isBeforeFirst()) {
	hasSubmittals = true;
%>
<div class="bold" style="margin-top: 10px; margin-bottom: 10px;">Other submittals with relevant information for this contract:</div>
<table cellspacing="0" cellpadding="3">
<tr>
<td class="head left">Open</td>
<td class="head">Number</td>
<td class="head">Type</td>
<td class="head">Contractor</td>
<td class="head right">Description</td>
</tr>
<%
color = true;
while (rs.next()) {
	color = !color;
%>
<tr <% if(color) out.print("class=\"gray\""); else out.print ("class=\"white\""); %> onMouseOver="rC(this)"; onMouseOut="rCl(this)";>
	<td class="left right"><a href="viewSubmittal.jsp?id=<%= rs.getString("submittal_id") %>">Open</a></td>
	<td class="it aright"><%= FormHelper.stringTable(rs.getString("submittal_num")) %></td>
	<td class="it"><%= rs.getString("submittal_type") %></td>
	<td class="it"><%= (rs.getString("company_name") == null ? db.get("short_name") : rs.getString("company_name")) %></td>
	<td class="right"><div class="clip"><%= FormHelper.stringTable(rs.getString("description")) %></div></td>
</tr>
<%
}
%>
</table>
<%
}
rs.getStatement().close();
query = "select submittals.submittal_id, submittals.date_received, comment_from_architect, comment_to_sub, "
	+ "date_from_architect, e_submit, submittal_type, submittal_num, company_name, submittals.description, "
	+ "alt_cost_code, cost_code from submittals join job_contacts on architect_id = job_contact_id left join "
	+ "contracts using(contract_id) left join company on contracts.company_id = company.company_id left join "
	+ "job_cost_detail on submittals.cost_code_id = job_cost_detail.cost_code_id "
	+ "where job_contacts.company_id = " + db.company_id + " and job_contacts.job_id = " + db.job_id 
	+ " order by company_name, costorder(submittal_num) desc";
rs = db.dbQuery(query);
if (rs.isBeforeFirst()) {
	hasSubmittals = true;
%>
<div class="bold" style="margin-top: 10px; margin-bottom: 10px;">Project submittals that specify this company as the architect:</div>
<table cellspacing="0" cellpadding="3">
<tr>
<td class="head left">Open</td>
<td class="head">Number</td>
<td class="head">Type</td>
<td class="head aright">Spec</td>
<td class="head">Contractor</td>
<td class="head right">Description</td>
</tr>
<%
color = true;
String spec, comment;
while (rs.next()) {
	comment = rs.getString("comment_from_architect");
	color = !color;
	spec = FormHelper.stringNull(rs.getString("alt_cost_code"));
	if (spec == null) spec = rs.getString("cost_code");
	bold = rs.getBoolean("e_submit") && rs.getDate("date_received") != null && rs.getDate("date_from_architect") == null;
%>
<tr <% if(color) out.print("class=\"gray\""); else out.print ("class=\"white\""); %> onMouseOver="rC(this)"; onMouseOut="rCl(this)";>
	<td class="left right <%= bold(bold) %>"><a href="modifySubmittal.jsp?id=<%= rs.getString("submittal_id") %>">Open</a></td>
	<td class="it aright <%= bold(bold) %>"><%= FormHelper.stringTable(rs.getString("submittal_num")) %></td>
	<td class="it <%= bold(bold) %>"><%= rs.getString("submittal_type") %></td>
	<td class="it aright <%= bold(bold) %>"><%= spec %></td>
	<td class="it <%= bold(bold) %>"><%= (rs.getString("company_name") == null ? db.get("short_name") : rs.getString("company_name")) %></td>
	<td class="right <%= bold(bold) %>"><div class="clip"><%= FormHelper.stringTable(rs.getString("description")) %></div></td>
</tr>
<%
}
%>
</table>
<%
}
rs.getStatement().close();
rs = null;
db.disconnect();
if (!hasSubmittals) {
%>
<div class="bold" style="margin-top: 10px;">No submittals found!</div>
<%
}
%>
</body>
</html>


