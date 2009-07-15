<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.JOB, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sw = sec.ok(Security.JOB, Security.WRITE);
boolean sd = sec.ok(Security.JOB, Security.DELETE);
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<title>Projects Contacts</title>
		<script>
			function del(id){
				if(confirm("Remove contact from project?")) window.location = "jobContacts.jsp?action=del&id=" + id;
			}
			var cls;
			function n(id) {
				id.className = cls;
			}
			function b(id) {
				cls = id.className;
				id.className = "yellow";
			}
			function def(obj) {
				window.location = "jobContacts.jsp?action=default&id=" + obj.value;
			}
			function add(contactId, companyId, type) {
				if (contactId == null) window.location = "jobContacts.jsp?action=add&contact_id=0&company_id=" + companyId + "&type=" + type;
				else window.location = "jobContacts.jsp?action=add&company_id=" + companyId + "&contact_id=" + contactId + "&type=" + type;
			}
		</script>
	<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
	</head>
<body>
<font size="+1">Project Contacts</font><hr>

<%
String action = request.getParameter("action");
String query;
ResultSet rs = null;
Database db = new Database();
if (action != null) {
	if (action.equals("del")) {
		String msg = "";
		int count = 0;
		query = "select count(*) from change_requests where to_id = " + request.getParameter("id");
		rs = db.dbQuery(query);
		if (rs.next()) count = rs.getInt(1);
		if (rs != null) rs.getStatement().close();
		if (count != 0) msg += "-Has " + count + " change requests\\n";
		query = "select count(*) from submittals where architect_id = " + request.getParameter("id");
		rs = db.dbQuery(query);
		if (rs.next() && rs.getInt(1) != 0) msg += "-Has " + rs.getInt(1) + " submittals\\n";
		if (rs != null) rs.getStatement().close();
		if (!"".equals(msg)) {
%>
<script>
		window.alert("Unable to remove contact\n---------------------------\n<%= msg %>");
</script>
<%
		} else {
			query = "delete from job_contacts where job_contact_id = " + request.getParameter("id");
			db.dbInsert(query);
		}
	} else if (action.equals("default")) {
		query = "select type from job_contacts where job_contact_id = " + request.getParameter("id");
		rs = db.dbQuery(query);
		if (rs.next()) {
			query = "update job_contacts set isDefault = 0 where type = '" + rs.getString("type") 
				+ "' and job_id = " + attr.getJobId();
			db.dbInsert(query);
			query = "update job_contacts set isDefault = 1 where job_contact_id = " + request.getParameter("id");
			db.dbInsert(query);
		}
		if (rs != null) rs.getStatement().close();
		rs = null;
	} else if (action.equals("add")) {
		query = "insert ignore into job_contacts (job_id, contact_id, company_id, type) values (" + attr.getJobId() + ", " + 
			request.getParameter("contact_id") + ", " + request.getParameter("company_id") + ", '" 
			+ request.getParameter("type") + "')";
		db.dbInsert(query);
	}
}
query = "select job_contact_id, name, company_name, type, isDefault from ((job_contacts " +
	"left join contacts using(contact_id)) left join company on company.company_id = job_contacts.company_id) " +
	"where job_id = " + attr.getJobId() + " order by type desc, company_name, name";
rs = db.dbQuery(query);
boolean color = true;
%>
<table cellspacing="0" cellpadding="3" style="margin-bottom: 6px;">
<tr>
	<td class="head left">Remove</td>
	<td class="head">Name</td>
	<td class="head">Company</td>
	<td class="head">Type</td>
	<td class="head right">Default</td>
</tr>
<%
while (rs.next()) {
	color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left right">
<%
	if (!rs.getBoolean("isDefault")) out.print("<a href=\"javascript: del(" + rs.getString("job_contact_id") +");\">Remove</a>");
	else out.print("&nbsp;");
%>	
	</td>
	<td class="it <%= rs.getBoolean("isDefault")?"bold":"" %>"><%= FormHelper.stringTable(rs.getString("name")) %></td>
	<td class="it <%= rs.getBoolean("isDefault")?"bold":"" %>"><%= FormHelper.stringTable(rs.getString("company_name")) %></td>
	<td class="it <%= rs.getBoolean("isDefault")?"bold":"" %>"><%= rs.getString("type") %></td>
	<td class="input right acenter">
<%
	if (!rs.getString("type").equals("Contact")) out.print("<input type=\"radio\" " + 
			"name=\"" + rs.getString("type") + "\" value=\"" + rs.getString("job_contact_id") + "\" " +
			FormHelper.chk(rs.getBoolean("isDefault")) + " onClick=\"def(this);\">");
	else out.print("&nbsp;");
%>
		</td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
%>
</table>
<input type="button" value="Close" onClick="window.close();"><hr>
<form id="main" action="jobContacts.jsp" method="GET" style="display: inline;">
<%
String search = request.getParameter("search");
%>
<table style="margin-bottom: 6px;">
<tr>
	<td class="lbl">Search company name:</td>
	<td><input type="text" name="search" value="<%= FormHelper.string(search) %>"></td>
	<td><input type="submit" value="Search"></td>
</tr>
</table>
<%
if (search != null) {
%>
<table cellspacing="0" cellpadding="3">
<tr>
	<td class="left head">Architect</td>
	<td class="head">Contact</td>
	<td class="head">Owner</td>
	<td class="right head">&nbsp;</td>
</tr>
<%
	query = "select c.company_id, c.company_name, c.city, c.state, n.contact_id, n.name, n.city, n.state " +
		"from company as c left join contacts as n using (company_id) where company_name like ? order by " +
		"company_name, name limit 25";
	PreparedStatement ps = db.preStmt(query);
	ps.setString(1, search + "%");
	rs = ps.executeQuery();
	String contactId = null, companyId = null;
	color = true;
	while (rs.next()) {
		color = !color;
		contactId = rs.getString("contact_id");
		companyId = rs.getString("company_id");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left"><a href="javascript: add(<%= contactId %>, <%= companyId %>, 'Architect');">Architect</a></td>
	<td class="it"><a href="javascript: add(<%= contactId %>, <%= companyId %>, 'Contact');">Contact</a></td>
	<td class="right"><a href="javascript: add(<%= contactId %>, <%= companyId %>, 'Owner');">Owner</a></td>
<%
		if (contactId != null) {
%>
	<td class="right"><%= rs.getString("company_name") + ": " + FormHelper.string(rs.getString("name")) %> 
		(<%= FormHelper.string(rs.getString("n.city")) + ", " + FormHelper.string(rs.getString("n.state")) %>)</td>
<%
		} else {
%>
	<td class="right"><%= rs.getString("company_name") %>
		(<%= FormHelper.string(rs.getString("c.city")) + ", " + FormHelper.string(rs.getString("c.state")) %>)</td>
<%	
		}
	}
	if (rs != null) rs.close();
	rs = null;
	if (ps != null) ps.close();
	ps = null;
}
db.disconnect();
%>
</form>
<script>
	document.getElementById("main").search.focus();
	document.getElementById("main").search.select();
</script>
</body>
</html>