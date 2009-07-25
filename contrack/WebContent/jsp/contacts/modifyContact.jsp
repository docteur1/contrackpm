<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.Widgets" %>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.Verify, com.sinkluge.Type" %>
<%@page import="com.sinkluge.database.Database" %>
<html>
<head>
<title>Modify Contact</title>
<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script language="javascript" src="../utils/verify.js"></script>
<script src="../utils/gui.js"></script>
<script language="javascript">
	function updateExt(id) {
		if (id.checked && !hasPass) alert("WARNING!\n-----------------\nThe current contact doesn't appear to ever been granted online access\nbefore. Clicking \"Update\" will enable this user for online access\nand will automatically generate and email the contact a password\nand some basic instructions.");
	}
	function resetPass() {
		if (confirm("WARNING!\n----------------\nThis will reset this contact's password and email the newly\ngenerated password to the listed address.\n\nProceed?"))
			location = "resetPassword.jsp?id=<%= request.getParameter("contact_id") %>";
	}
	function save(id) {
		if (id.allow_ext != null) {
			id.email.required = id.allow_ext.checked;
		}
		return checkForm (id);
	}
</script>
<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
</head>

<body>
<form name="main" method="post" action="processModifyContact.jsp" onSubmit="return save(this);">
<font size="+1">Modify Contact</font><hr>
<%
Verify v = new Verify();
if (request.getParameter("save") != null) out.print("<span class=\"red bold\">Saved</span><hr>");
if (request.getParameter("reset") != null) out.print("<span class=\"red bold\">Password Reset</span><hr>");
String query="select contacts.*, company.company_name from contacts left join company " +
	"using(company_id) where contact_id = " + request.getParameter("contact_id");
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String email, emailString = null, pass = null;
boolean validEmail = false;
boolean allow_ext = false;
if(rs.next()){
	email = rs.getString("email");
	if (email == null || !v.email(email)){
		emailString = "";
		email ="Email:";
	} else {
		emailString = email;
		email = "<a href=\"mailto: "  + rs.getString("name") + " <" +email + ">\">Email:</a>";
		validEmail = true;
	}
	String radio = FormHelper.string(rs.getString("radio_num"));
	String ext = FormHelper.string(rs.getString("extension"));
	String title = FormHelper.string(rs.getString("title"));
	String phone = FormHelper.string(rs.getString("phone"));
	String fax = FormHelper.string(rs.getString("fax"));
	String address = FormHelper.string(rs.getString("address"));
	String mobile = FormHelper.string(rs.getString("mobile_phone"));
	String city = FormHelper.string(rs.getString("city"));
	String state = FormHelper.string(rs.getString("state"));
	String pager = FormHelper.string(rs.getString("pager"));
	String zip = FormHelper.string(rs.getString("zip"));
%>

<input type="hidden" name="contact_id" value="<%=request.getParameter("contact_id")%>">
<table>
<tr>
	<td class="lbl">Name:</td>
	<td><input type="text" size="20" name="contact_name" value="<%= FormHelper.string(rs.getString("name")) %>"></td>
	<td class="lbl">Radio Number:</td>
	<td><input type="text" size="20" name="radio_num" value="<%=radio%>"></td>
</tr>
<tr>
	<td class="lbl">Title:</td>
	<td><input type="text" size="20" name="title" value="<%=title%>"></td>
	<td class="lbl"><%= Widgets.phone(phone, "Phone:", rs.getString("name"), request) %></td>
	<td><input type="text" size="20" name="phone" value="<%=phone%>" maxlength="16"> <b>Ext:</b> <input type="text" size=4 name="extension" value="<%=ext%>" ></td>
</tr>
<tr>
	<td class="lbl"><%= Widgets.map(address, city, state, zip) %></td>
	<td><input type="text" size="20" name="address" value="<%=address%>" maxlength="100"></td>
	<td class="lbl">Fax:</td>
	<td><input type="text" size="20" name="fax" value="<%=fax%>" maxlength="16"></td>
</tr>
<tr>
	<td class="lbl">City:</td>
	<td><input type="text" size="20" name="city" value="<%=city%>"></td>
	<td class="lbl"><%= Widgets.phone(mobile, "Mobile:", rs.getString("name"), request) %></td>
	<td><input type="text" size="20" name="mobile_phone" value="<%=mobile%>" maxlength="16"></td>
</tr>
<tr>
	<td class="lbl">State:</td>
	<td><input type="text" size="20" name="state" value="<%=state%>"></td>
	<td class="lbl"><%= email %></td>
	<td><input type="text" size="25" name="email" value="<%=emailString%>"></td>
</tr>
<tr>
	<td class="lbl">Zip:</td>
	<td><input type="text" size="20" name="zip" value="<%=zip%>" maxlength="10"></td>
	<td class="lbl">Pager:</td>
	<td><input type="text" size="25" name="pager" value="<%=pager%>" maxlength="16"></td>
</tr>
<%
if (validEmail) {
	query = "select * from contact_roles where email = '" + emailString + "' and role_name = 'valid'";
	ResultSet temp = db.dbQuery(query);
	allow_ext = temp.next();
	if (temp != null) temp.getStatement().close();
	query = "select * from contact_users where email = '" + emailString + "'";
	temp = db.dbQuery(query);
	if (temp.next()) pass = temp.getString("password");
	if (temp != null) temp.getStatement().close();
%>
<tr>
	<td>&nbsp;</td>
	<td>	
<script language="javascript">
	var hasPass = <%= pass != null && !pass.equals("") %>;
</script>
<%
	if (pass != null && !pass.equals("")) out.print("<input type=\"hidden\" name=\"has_pass\" value=\"true\">");
%>
     <input type="checkbox" name="allow_ext" value="y" <% if(allow_ext) out.println("checked"); %> onClick="updateExt(this);"> <span class="bold">Allow Online Access</span>
   </td>
   <td class="lbl">ID:</td>
   <td><%= Widgets.logLinkWithId(request.getParameter("contact_id"), Type.CONTACT, "window", 
		   "contacts/modifyContact.jsp?contact_id=" + request.getParameter("contact_id"), 
			request) %></td>
</tr>
<%
}
%>
<tr>
	<td>&nbsp;</td>
	<td colspan="3">
<input type="submit" value="Update"> &nbsp; 
<input type="button" value="Close" onClick="window.close()">
<%
if (allow_ext) out.print("&nbsp; <input type=\"button\" value=\"Reset Password\" onClick=\"resetPass()\">");
%>
&nbsp; <%= Widgets.docsButton(request.getParameter("contact_id"), Type.CONTACT, request) %>
</td>
</tr>
<tr>
	<td class="lbl">Comments:</td>
	<td colspan="3"><textarea name="comment" cols="60" rows="4"><%= FormHelper.string(rs.getString("comment")) %></textarea>
</tr>
</table>
</form>
<script language="javascript">
	var f = document.main;
	var d = f.contact_name;
	d.required = true;
	d.eName = "Name";
	
	d = f.radio_num;
	d.isInt = true;
	d.eName = "Radio #";
	
	d = f.phone;
	d.isPhone = true;
	d.eName = "Phone Number";
	
	d = f.fax;
	d.isPhone = true;
	d.eName = "Fax";
	
	d = f.mobile_phone;
	d.isPhone = true;
	d.eName = "Mobile Phone";
	
	d = f.pager;
	d.isPhone = true;
	d.eName = "Pager";
	
	d = f.zip;
	d.isZip = true;
	d.eName = "Zip Code";
	
	d = f.email;
	d.isEmail = true;
	d.eName = "Email";
</script>
<fieldset style="width: 300px;">
<legend>Mailing Label</legend>
<%= FormHelper.string(rs.getString("name")) + "<br />" +
	FormHelper.string(rs.getString("company_name")) + "<br />" +
	FormHelper.string(rs.getString("address")) + "<br />" +
	FormHelper.string(rs.getString("city")) + ", " + FormHelper.string(rs.getString("state")) + " " +
	FormHelper.string(rs.getString("zip")) %>
</fieldset>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</body>
</html>
