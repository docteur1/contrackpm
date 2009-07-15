<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.DecimalFormat" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="true" />
	</jsp:include>
<font size="+1">Changes</font><hr>
<a href="../manage/">Home</a> &gt; Changes<hr>
<%
db.connect();
String query1 = "select amount from contracts where contract_id = " + db.contract_id;
ResultSet contract = db.getStatement().executeQuery(query1);
query1 = "select num, title, work_description, amount, change_auth_num, sub_ca_num from change_request_detail as crd "
	+ "left join change_requests as cr using (cr_id) where authorization = 1 and contract_id = " + db.contract_id;
ResultSet item = db.getStatement().executeQuery(query1);
DecimalFormat df = new DecimalFormat("$#,##0.00");

if (contract.next()) {
%>
<script>
	var printName = "changes.pdf";
</script>
<div><b>NOTE:</b> Information displayed here is for reference only. Only the signed 
	change authorization document is contractually binding.</div>
<table style="margin-top: 10px;" cellspacing="0" cellpadding="3">
<tr>
	<td class="head left aright">Ref #</td>
	<td class="head aright">CA #</td>
	<td class="head">Description</td>
	<td class="head right aright">Amount</td>
</tr>
<%
double total = 0;
double amount = contract.getDouble("amount");
double co_amount = 0;
boolean color = true;
if (!item.isBeforeFirst()) {
%>
	<tr>
		<td class="left right bold acenter" colspan="4">No Changes Found!</td>
	</tr>
<%
}
while (item.next()) {
	color = !color;
	co_amount = item.getDouble("amount");
	total += co_amount;
%>
<tr <% if(color) out.print("class=\"gray\""); %> onMouseOver="rC(this);" onMouseOut="rCl(this);">
	<td class="left aright"><%= item.getString("sub_ca_num") %></td>
	<td class="it aright"><%= item.getString("change_auth_num") %></td>
	<td class="it"><%= item.getString("work_description") %></td>
	<td class="right aright"><%= df.format(co_amount) %></td>
</tr>
<%
}
%>
</table>
<table style="margin-top: 8px;">
<tr>
	<td align="right">Total Change Authorizations:</td>
	<td align="right"><%= df.format(total) %></td>
</tr>
<tr>
	<td align="right">Orignal Contract:</td>
	<td align="right"><%= df.format(amount) %></td>
</tr>
<tr>
	<td align="right">Current Contract:</td>
	<td align="right"><b><%= df.format(total + amount) %></b></td>
</tr>
</table>

<% 
}
if (contract != null) contract.getStatement().close();
contract = null;
if (item != null) item.getStatement().close();
item = null;
db.disconnect();
%>
</body>
</html>


