<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.sinkluge.security.*,
    java.sql.ResultSet, com.sinkluge.database.Database, com.sinkluge.utilities.FormHelper,
    java.sql.Blob" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
if (!sec.ok(Name.ADMIN, Permission.READ)){
	response.sendRedirect("../accessDenied.jsp");
	return;
}
JSONRPCBridge.registerClass("verify", com.sinkluge.JSON.Verify.class);
String id = request.getParameter("id");
Database db = new Database();
ResultSet rs = db.dbQuery("select * from users where id = " + id, true);
String docTitle = "New User";
String email = "", firstName = "", lastName = "", username = "";
boolean active = true;
boolean photo = false;
username = request.getParameter("username");
boolean insert = false;
if (username != null) {
	email = request.getParameter("email");
	firstName = request.getParameter("first_name");
	lastName = request.getParameter("last_name");
	active = request.getParameter("active") != null;
	if (!rs.first()) {
		insert = true;
		rs.moveToInsertRow();
	}
	rs.updateString("email", email);
	rs.updateString("first_name", firstName);
	rs.updateString("last_name", lastName);
	rs.updateBoolean("active", active);
	rs.updateString("username", username);
	if (insert) {
		rs.insertRow();
		if (rs.last()) id = rs.getString("id");
	} else rs.updateRow();
	if (!active) db.dbInsert("delete from user_roles where username = '" + username
		+ "' and role_name = 'Users'");
	else db.dbInsert("insert ignore into user_roles (username, role_name) values ('"
			+ username + "', 'Users')");
	String[] roles = request.getParameterValues("groups");
	db.dbInsert("delete from user_roles where username = '" + username + "' and role_name != 'Users'");
	for (String role : roles) db.dbInsert("insert into user_roles (username, role_name) values "
			+ "('" + username + "', '" + role + "')");
} else if (rs.first()) {
	firstName = rs.getString("first_name");
	lastName = rs.getString("last_name");
	active = rs.getBoolean("active");
	email = rs.getString("email");
	username = rs.getString("username");
	Blob blob = rs.getBlob("photo");
	if (blob != null) {
		if (request.getParameter("clear") != null) {
			rs.updateBytes("photo", null);
			rs.updateRow();
			photo = false;
		} else photo = true;
		blob = null;
	}
}
docTitle = "User: " + firstName + " " + lastName;
rs.getStatement().close();
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" >
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<script src="../utils/verify.js"></script>
<script src="../utils/jsonrpc.js"></script>
<script>
	function verify() {
		if (checkForm(m)) {
			document.getElementById("saveButton").disabled = true;
			var newPassword = m.password.value;
			var verifyPassword = m.confirm_password.value;
			if (newPassword != verifyPassword) {
				window.alert("Passwords do not match");
				document.getElementById("saveButton").disabled = false;
				return false;
			}
			var jsonrpc = new JSONRpcClient("../JSON-RPC");
			var uid = m.user_id ? m.user_id.value : 0;
			jsonrpc.verify.username(verifyCB, m.username.value, uid);
			return false;
		} else return false;
	}
	function verifyCB (result, e) {
		if (result) window.alert("ERROR!\n--------------\nUsername \"" + m.username.value
			+ "\" is already assigned to " + result);
		else m.submit();
		document.getElementById("saveButton").disabled = false;
	}
</script>
</head>
<body>
<div class="title"><%= docTitle %></div><hr/>
<div class="link" onclick="window.location='superAdmin.jsp';">Administration</div> &gt;
<div class="link" onclick="window.location='sqlUserAdmin.jsp';">Users</div> &gt;
<%= docTitle %> &nbsp; <div class="link" onclick="window.location='sqlUser.jsp';">New</div><hr/>
<form id="mainForm" method="post" onsubmit="return verify();">
<%= id != null ? "<input type=\"hidden\" name=\"user_id\" value=\"" + id + "\"/>" : "" %>
<table>
<tr>
<td class="lbl">Username</td>
<td><input type="text" name="username" value="<%= FormHelper.string(username) %>"/></td>
<td class="lbl">First Name</td>
<td><input type="text" name="first_name" value="<%= FormHelper.string(firstName) %>"/></td>
</tr>
<tr>
<td class="lbl">Email</td>
<td><input type="text" name="email" value="<%= FormHelper.string(email) %>"/></td>
<td class="lbl">Last Name</td>
<td><input type="text" name="last_name" value="<%= FormHelper.string(lastName) %>"/></td>
</tr>
<tr>
<td class="lbl">Password</td>
<td><input type="password" name="password"/></td>
<td class="lbl">Confirm Password</td>
<td><input type="password" name="confirm_password"/></td>
</tr>
<tr>
<td class="lbl">Active</td>
<td><input type="checkbox" name="active" value="t" <%= FormHelper.chk(active) %>/></td>
<%
if (photo) {
%>
<td rowspan="3" colspan="2">
<img src="../servlets/userphoto"/>
</td>
<%
}
%>
</tr>
<tr>
<td class="lbl">Groups</td>
<td><select multiple name="groups" size="5">
<%
rs = db.dbQuery("select distinct role_name from default_permissions where role_name != 'Users'"
	+ " order by role_name");
ResultSet rs2;
while (rs.next()) {
	rs2 = db.dbQuery("select * from user_roles where username = '" + username
		+ "' and role_name = '" + rs.getString(1) + "'");
	out.print("<option value=\"" + rs.getString(1) + "\" " + FormHelper.sel(rs2.first()) 
		+ ">" + rs.getString(1) + "</option>");
	rs2.getStatement().close();
}
rs.getStatement().close();
db.disconnect();

%>
</select></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="button" id="saveButton" value="Save" onclick="verify();"/></td>
</tr>
</table>
</form>
<%
if (id != null) {
%>
<form action="../servlets/userphoto" method="post" enctype="multipart/form-data"
	onsubmit="return checkForm(this);">
<input type="hidden" name="redirect" value="<%= request.getContextPath() 
	%>/jsp/admin/sqlUser.jsp?id=<%= id %>"/>
<input type="hidden" name="user_id" value="<%= id %>"/>
<table>
<tr>
<td class="lbl">Photo</td>
<td><input type="file" id="photo" name="photo"/></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="submit" value="Upload"/> <input type="button" value="Clear Photo"
	onclick="window.location='sqlUser.jsp?clear=t&id<%= id %>';"/></td>
</tr>
</table>
</form>
<%
}
%>
<script>
	var m = document.getElementById("mainForm");
	m.username.required = true;
	m.username.eName = "Username";
	m.first_name.required = true;
	m.first_name.eName = "First Name";
	m.last_name.required = true;
	m.last_name.eName = "Last Name";
	m.email.required = true;
	m.email.eName = "Email";
	m.email.isEmail = true;
<%
if (id != null) {
%>
	var f = document.getElementById("photo");
	f.required = true;
	f.eName = "Photo";
<%
}
%>
</script>
</body>
</html>