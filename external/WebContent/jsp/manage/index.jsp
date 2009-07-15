<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.Statement, java.sql.ResultSet, com.sinkluge.util.FormHelper, com.sinkluge.util.Widgets" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="true"/>
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="action" value="../payRequests/payRequest.jsp"/>
	</jsp:include>
<font size="+1">Home - Project Information</font><hr>
<%
String query;
ResultSet rs;
if (db.contract_id != 0) {
%>
<a href="../changes/">Change Authorization</a> &nbsp; 
<a href="../payRequests/">Pay Requests</a> &nbsp;
<%
}
if (db.job_id != 0) {
	query = "select count(*) from rfi where e_submit = 1 and company_id = " + db.company_id + 
		" and job_id = " + db.job_id;
	db.connect();
	rs = db.dbQuery(query);
	int count = 0;
	if (rs.first()) count = rs.getInt(1);
	if (rs != null) rs.getStatement().close();
%>
<%= (count != 0?"<b>":"") %>
<a href="../rfis/">RFIs<%= (count != 0?"(" + count + ")":"") %></a> &nbsp; 
<%= (count != 0?"</b>":"") %>
<%
query = "select count(*) from submittals where e_submit = 1 and (date_received is null or date_from_architect is not null) and contract_id = " + db.contract_id;
db.connect();
rs = db.dbQuery(query);
if (rs.first()) count = rs.getInt(1);
if (rs != null) rs.getStatement().close();
query = "select count(*) from submittals join job_contacts on architect_id = job_contact_id where company_id = " 
	+ db.company_id + " and e_submit = 1 and (date_received is not null and date_from_architect "
	+ "is null) and job_contacts.job_id = " + db.job_id;
rs = db.dbQuery(query);
if (rs.first()) count += rs.getInt(1);
if (rs != null) rs.getStatement().close();
%>
<%= (count != 0?"<b>":"") %>
<a href="../submittals/">Submittals<%= (count != 0?"(" + count + ")":"") %></a>
<%= (count != 0?"</b>":"") %>
<hr>
<%
}
query = "select address, city, state, zip, phone_one, phone_two, fax from job where job_id = " + db.job_id;
Statement stmt = db.getStatement();
rs = stmt.executeQuery(query);
if (rs.isBeforeFirst()) {
	String address = "";
	String city = "";
	String state = "";
	String zip = "";
	String phone1 = "";
	String phone2 = "";
	String fax = "";
	if (rs.next()) {
		address = rs.getString("address");
		city = rs.getString("city");
		state = rs.getString("state");
		zip = rs.getString("zip");
		phone1 = rs.getString("phone_one");
		phone2 = rs.getString("phone_two");
		fax = rs.getString("fax");
	}
	if (rs != null) rs.close();
	rs = null;
%>
<table>
	<tr>
		<td class="lbl">Contractor</td>
		<td><%= db.get("full_name") %></td>
<%
if (in.live_support_url != null) {
%>
		<td rowspan="6" style="padding-left: 12px;"><script>showButtonWithoutUI('<%= in.live_support_workgroup %>&username=<%= 
			response.encodeURL(db.contact_name + " (" + db.company_name + ")") %>&email=<%= db.email %>');</script></td>
<%
}
%>
	</tr>
	<tr>
		<td class="lbl"><%= Widgets.map(address, city, state, zip) %></td>
		<td><%= address %></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><%= city + ", " + state + " " + zip %></td>
	</tr>
	<tr>
		<td class="lbl">Phone</td>
		<td><%= phone1 %></td>
	</tr>
<%
if (phone2 != null && !phone2.equals("")) {
%>
	<tr>
		<td class="lbl">&nbsp;</td>
		<td><%= phone2 %></td>
	</tr>
<%
}
%>
	<tr>
		<td class="lbl">Fax</td>
		<td><%= fax %></td>
	</tr>
</table>
<table cellspacing="0" cellpadding="3" style="margin-top: 10px;">
	<tr>
		<td class="left head">&nbsp;</td>
		<td class="head">Name</td>
		<td class="head">Email</td>
		<td class="right head">Mobile</td>
	</tr>
<%
	query = "select * from job_team where job_id = " + db.job_id + " order by role, name";
	rs = stmt.executeQuery(query);
	boolean color = true;
	String email;
	while (rs.next()) {
		color = !color;
		email = FormHelper.stringNull(rs.getString("email"));
		
%>
	<tr <% if(color) out.print("class=\"gray\""); %> onMouseOver="rC(this);" onMouseOut="rCl(this);">
		<td class="left"><%= rs.getString("role") %></td>
		<td class="it"><%= rs.getString("name") %></td>
		<td class="it"><%= (email==null?"&nbsp;":"<a href=\"mailto:" + rs.getString("name") + " <" +email + ">\">" + email + "</a>") %></td>
		<td class="right"><%= FormHelper.stringTable(rs.getString("mobile")) %></td>
	</tr>
<%
	}
	out.println("</table>");
} else out.print("<p><b>It appears your company has no active contracts. Please contact " + db.get("short_name") + " if you have questions.");
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