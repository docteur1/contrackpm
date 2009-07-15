<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.Type" %>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission,
	com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
Database db = new Database();
String id = request.getParameter("id");
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<script language="javascript" src="../utils/verify.js"></script>
	<script src="../utils/gui.js"></script>
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript">
	function openContact(id){
		msgWindow=open("","manage","toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,width=600,height=500,left=25,top=25");
		msgWindow.location.href = "modifyContact.jsp?contact_id=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function openAccount(id){
		msgWindow=open("","manage","toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,width=500,height=300,left=25,top=25");
		msgWindow.location.href = "viewAccounting.jsp?id=" + id;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function newContact(id) {
		msgWindow = window.open("newContact.jsp?id=" + id, "manage", "location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,left=25,top=25,height=450,width=350");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function del(id){
		if(confirm("Delete contact?")) location = "deleteContact.jsp?company_id=<%= id %>&id=" + id;
	}
	function accountId() {
		window.alert("Account ID Help\n-----------------------------------------------------------------------\n"
			+ "Account ID is the unique identifier that links this company to the\n"
			+ "corresponding record in the accounting database. The currently\n"
			+ "displayed ID corresponds to the currently-selected-project\n"
			+ "contractor. To view/edit the ID for other contractors, the project\n"
			+ "must changed to a project associated with a different contractor.");
	}
	var cls;
	function n(id) {
		id.className = cls;
	}
	function b(id) {
		cls = id.className;
		id.className = "yellow";
	}
	</script>
</head>
<body>
<form name="main" action="processModifyCompany.jsp" method="POST" onSubmit="return checkForm(this);">
<%
String query = "select * from company where company_id = " + id;
ResultSet rs = db.dbQuery(query);
%>
<div class="title">Modify Company</div>
<hr>
<a href="reviewCompanies.jsp">Companies</a> &gt; Modify Company
&nbsp;&nbsp;<a href="modifyCompanyComments.jsp?id=<%= id %>" >Comments/Strikes</a>
&nbsp;&nbsp;<a href="reviewCompanyContracts.jsp?id=<%= id %>" >Contract History</a>
&nbsp;&nbsp;<a href="../servlets/vCard/vCard.vcf?company_id=<%= id %>">vCard</a>
&nbsp;&nbsp;<a href="javascript: newContact(<%= id %>)">Add New Contact</a>
&nbsp;&nbsp;<a href="merge.jsp?id=<%= id %>">Merge</a>
&nbsp; <%= Widgets.docsLink(id, Type.COMPANY, request) %>
<hr>
<%
if(request.getParameter("save") != null) out.print("<font color=\"red\"><b>Saved</b></font><hr>");
if (rs.next()) {
%>
<table>
<tr>
	<td class="lbl">Name:</td>
	<td colspan="3"><input type="text" size="70" name="company_name" 
		value="<%= FormHelper.string(rs.getString("company_name")) %>">
		<input type="hidden" name="id" value="<%= id %>"></td>
</tr>
<tr>
	<td class="lbl"><%= Widgets.map(rs.getString("address"), rs.getString("city"), rs.getString("state"),
			rs.getString("zip")) %></td>
	<td><input type="text" name="address" 
		value="<%= FormHelper.string(rs.getString("address")) %>" maxlength="100"></td>
	<td class="lbl">Description:</td>
	<td align="left"><input type="text" name="description" 
		value="<%= FormHelper.string(rs.getString("description")) %>"></td>
</tr>
<tr>
	<td class="lbl">City:</td>
	<td><input type="text" name="city" value="<%= FormHelper.string(rs.getString("city")) %>"></td>
	<td class="lbl">
<%
String URL = FormHelper.stringNull(rs.getString("website"));
if (URL != null) out.print("<a href=\"http://" + URL + "\" target=\"_blank\">Website:</a>");
else out.print("Website:");
%>
		</td>
	<td align="left"><input type="text" name="website" 
		value="<%= FormHelper.string(URL) %>"></td>
</tr>
<tr>
	<td class="lbl">State:</td>
	<td><input type="text" name="state" value="<%= FormHelper.string(rs.getString("state")) %>"></td>
	<td class="lbl">Federal ID:</td>
	<td align="left"><input type="text" name="federal_id" 
		value="<%= FormHelper.string(rs.getString("federal_id")) %>"></td>
</tr>
<tr>
	<td class="lbl">Zip Code:</td>
	<td><input type="text" name="zip" value="<%= FormHelper.string(rs.getString("zip")) %>"
		maxlength="10"></td>
	<td class="lbl">License Number:</td>
	<td align="left"><input type="text" name="license_number" 
		value="<%= FormHelper.string(rs.getString("license_number")) %>"></td>
</tr>
<%
String phone = rs.getString("phone");
%>
<tr>
	<td class="lbl"><%= Widgets.phone(phone, "Phone:", rs.getString("company_name"), request) %></td>
	<td><input type="text" name="phone" value="<%= FormHelper.string(rs.getString("phone")) %>"
		maxlength="16"></td>
	<td colspan="2" class="acenter"><b>Safety Manual:</b> <input type="checkbox" name="safety_manual" value="y" <%= FormHelper.chk(rs.getString("safety_manual").equals("y")) %>>
		<b>Website Training:</b> <input type="checkbox" name="ext_trained" value="y" <%= FormHelper.chk(rs.getBoolean("ext_trained")) %>></td>
</tr>
<tr>
	<td class="lbl">Fax:</td>
	<td><input type="text" name="fax" value="<%= FormHelper.string(rs.getString("fax")) %>"
		maxlength="16"></td>
<%
if (attr.hasAccounting()) {
	ResultSet accId = db.dbQuery("select account_id from company_account_ids where "
			+ "company_id = " + id + " and site_id = " + attr.getSiteId()); 
	String accountId = null;
	if (accId.first()) accountId = accId.getString(1);
	if (accId != null) accId.getStatement().close();
	if (accountId != null) out.println("<td class=\"lbl\"><a href=\"javascript: openAccount('"
		+ accountId + "');\">Account ID:</a></td>");
	else out.println("<td class=\"lbl\">Account ID:</a></td>");
	if (!sec.ok(Name.ACCOUNTING, Permission.WRITE)) {
%>
	<td><%= FormHelper.stringTable(accountId) %>
		<input type="hidden" name="account_id" value="<%= FormHelper.string(accountId) %>">
		<a href="javascript: accountId();" class="bold">?</a></td>
<%
	} else {
%>
	<td><input type="text" name="account_id" value="<%= FormHelper.string(accountId) %>">
		<a href="javascript: accountId();" class="bold">?</a></td>
<%
	}
} else out.println("<td colspan=\"2\">&nbsp;</td>");
%>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Save"></td>
	<td class="lbl">ID:</td>
	<td><%= Widgets.logLinkWithId(id, Type.COMPANY, "window", 
		"contacts/modifyCompany.jsp?id=" + id, request) %></td>
</tr>
</table>
<table cellspacing="0" cellpadding="3" style="margin-top: 10px; margin-bottom: 10px;">
<tr>
	<td class="left head">Delete</td>
	<td class="head">Edit</td>
	<td class="head">vCard</td>
	<td class="head">Name</td>
	<td class="head">Mobile</td>
	<td class="head">Website</td>
	<td class="head right">ID</td>
</tr>
<%
	query = "select contact_id, name, email, mobile_phone, role_name from contacts left join contact_roles "
		+ "using (email) where company_id = " + id + " order by name";
	ResultSet contact = db.dbQuery(query);
	boolean color = false;
	String email;
	while (contact.next()) {
		email = FormHelper.stringNull(contact.getString("email"));
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left"><a href="javascript: del(<%= contact.getString("contact_id") %>);">Delete</a></td>
	<td class="it"><a href="javascript: openContact(<%= contact.getString("contact_id") %>);">Edit</a></td>
	<td class="right"><a href="../servlets/vCard/vCard.vcf?contact_id=<%= contact.getString("contact_id") %>">vCard</a>
	<td class="it"><% if (email != null) out.println("<a href=\"mailto:" + FormHelper.string(contact.getString("name")) + " <" + email + ">\">"); %><%= FormHelper.stringTable(contact.getString("name")) %><% if (email != null) out.println("</a>"); %></td>
	<td class="it"><%= Widgets.phone(contact.getString("mobile_phone"), contact.getString("name"), request) %></td>
	<td class="input acenter"><% if (contact.getString("role_name") != null) 
		out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
	<td class="right"><%= Widgets.logLinkWithId(contact.getString("contact_id"), Type.CONTACT, 
		"window", request) %></td>
</tr>
<%
		color = !color;
	}
	if (contact != null) contact.getStatement().close();
%>
</table>
<fieldset style="width: 300px;">
<legend>Mailing Label</legend>
<%= FormHelper.string(rs.getString("company_name")) + "<br />" +
	FormHelper.string(rs.getString("address")) + "<br />" +
	FormHelper.string(rs.getString("city")) + ", " + FormHelper.string(rs.getString("state")) + " " +
	FormHelper.string(rs.getString("zip")) %>
</fieldset>
<% 
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</form>
<script language="javascript">
	var d = document.main;
	var f = d.company_name;
	f.focus();
	f.select();
	f.required = true;
	f.eName = "Name";
	
	f = d.zip;
	f.isZip = true;
	f.eName = "Zip Code";
	
	f = d.phone;
	f.isPhone = true;
	f.eName = "Phone";
	
	f = d.fax;
	f.isPhone = true;
	f.eName = "Fax";
</script>
</body>

</html>
