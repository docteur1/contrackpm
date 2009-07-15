<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.utilities.FormHelper, java.sql.SQLException" %>
<%@page import="com.sinkluge.utilities.Widgets, com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<script src="../utils/gui.js"></script>
	<script language="javascript">
		function del(id){
			if(confirm("Delete this company?")) location = "deleteCompany.jsp?id=" + id;
		}
		function jobContacts() {
			msgWindow=open('../projects/jobContacts.jsp','Twindow','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=490,left=25,top=25');
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
	</script>
</head>
<body>
<%
String search = request.getParameter("search");
if (search == null) out.print("<font size=\"+1\">Project Contacts</font>");
else out.print("<font size=\"+1\">Search Results</font>");
%><hr>
<a href="newCompany.html">New Company</a>&nbsp;&nbsp;
<%
if (search == null) {
%>
<a href="../utils/print.jsp?doc=jobContacts.pdf" target="print">Print</a>&nbsp;&nbsp;
<a href="../servlets/CSV/project.csv">Export CSV</a>&nbsp;&nbsp;
<%
}
%>
<a href="email.jsp">Email</a>&nbsp;&nbsp;
<span class="red bold">Red</span> indicates one or more strikes.
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
	<td class="left head nosort">Delete</td>
	<td class="head nosort">Edit</td>
	<td class="head nosort">Contracts</td>
	<td class="head asort">Company Name</td>
	<td class="head">&nbsp;</td>
	<td class="head">Phone</td>
	<td class="head">Fax</td>
	<td class="head">Mobile</td>
	<td class="head">Website</td>
	<td class="head">Type</td>
	<td class="right head">ID</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean gray = true;
int companyID;
Database db = new Database();
String email;
String query = null;
ResultSet rs = null;
if (search == null) {
	query = "(select c.company_name, c.company_id, c.phone as cp, c.fax as cf, n.phone as np, n.fax as nf, n.name, n.email, n.mobile_phone, type, isDefault, role_name "
		+ "from (((job_contacts left join contacts as n using(contact_id)) left join company as c on "
		+ "c.company_id = job_contacts.company_id) left join contact_roles using (email)) where job_id = " + attr.getJobId() + ")";
	query += "union (select distinct c.company_name, c.company_id, c.phone as cp, c.fax as cf, n.phone as np, n.fax as nf, n.name, n.email, n.mobile_phone, null as type, "
		+ "0 as isDefault, role_name from (((contracts left join contacts as n using(contact_id)) left join company as c on "
		+ "contracts.company_id = c.company_id) left join contact_roles using (email)) where contracts.job_id = " + attr.getJobId() + ") order by company_name, type desc";
	rs = db.dbQuery(query);
} else {
	String type = request.getParameter("type");
	if (type.equals("company_name") || type.equals("name") || type.equals("email")) query = "select distinct "
		+ "c.company_name, c.company_id, null as cp, null as cf, n.phone as np, n.fax as nf, n.name, "
		+ "n.email, n.mobile_phone, 0 as isDefault, null as type, role_name from company as c "
		+ "left join contacts as n using (company_id) left join contact_roles using(email) where " 
		+ type + " like ? order by company_name, name limit 50";
	else query = "select distinct c.company_name, c.company_id, fax as cp, phone as cf, null as np, "
		+ "null as nf, null as name, null as email, null as mobile_phone, null as role_name, 0 as isDefault, null as type, " + type
		+ " from company as c join contracts using(company_id) join job_cost_detail using(cost_code_id) "
		+ "where " + type + " like ? order by company_name, name limit 50";
	PreparedStatement ps = db.preStmt(query);
	ps.setString(1, search + "%");
	rs = ps.executeQuery();
}
int strikes = 0;
ResultSet strike;
email = null;
String name, phone, fax;
String type = null;
boolean isDefault;
while (rs.next()){
	strikes = 0;
	isDefault = rs.getBoolean("isDefault");
	name = rs.getString("name");
	if (name != null) {
		phone = rs.getString("np");
		fax = rs.getString("nf");
	} else {
		phone = rs.getString("cp");
		fax = rs.getString("cf");
	}
	try {
		name = rs.getString("code_description");
	} catch (SQLException e) {}
	try {
		name = rs.getString("cost_code");
	} catch (SQLException e) {}
	companyID = rs.getInt("company_id");
	query = "select count(*) from company_comments where strike = 1 and company_id = " + companyID;
	strike = db.dbQuery(query);
	if (strike.next()) strikes = strike.getInt(1);
	if (strike != null) strike.getStatement().close();
	email = FormHelper.stringNull(rs.getString("email"));
	type = rs.getString("type");
	if (type == null) type = "Contract";
	if (search != null) type = "&nbsp;";
	gray = !gray;

%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" class="<%= isDefault?"bold":"" %> <%= gray?"gray":"" %>" >
	<td class="left"><a href="javascript: del('<%=companyID%>')">Delete</a></td>
	<td class="it"><a href="modifyCompany.jsp?id=<%= companyID%>">Edit</a></td>
	<td class="right"><a href="reviewCompanyContracts.jsp?id=<%= companyID%>" >Contracts</a></td>
	<td class="it">
<%
	if (strikes > 0) out.print("<span class=\"red\">" + rs.getString("company_name") + "</span>");
	else out.print(rs.getString("company_name"));
%>
		</td>
	<td class="it"><% if (email != null) out.println("<a href=\"mailto:" + FormHelper.string(name) + " <" + email + ">\">"); %><%= FormHelper.stringTable(name) %><% if (email != null) out.println("</a>"); %></td>
	<td class="it"><%= Widgets.phone(phone, name, request) %></td>
	<td class="it"><%= FormHelper.stringTable(fax) %></td>
	<td class="it"><%= Widgets.phone(rs.getString("mobile_phone"), name, request) %></td>
	<td class="it acenter"><%= Widgets.checkmark(rs.getString("role_name") != null, request) %></td>
	<td class="it"><%= type %></td>
	<td class="right"><%= Widgets.logLinkWithId(rs.getString("company_id"), com.sinkluge.Type.COMPANY, 
		"window", request) %></td>
	</tr>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</div>
</body>
</html>
