<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sinkluge.UserData" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
String oldPassword = request.getParameter("oldPassword");
String result = null;
if (oldPassword != null) {
	UserData user = UserData.getInstance(in, attr.getUserId());
	result = user.changeUserPassword(oldPassword, request.getParameter("newPassword"), in);
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script language="javascript" src="../utils/verify.js"></script>
<script language="javascript">
	function verify(f) {
		var oldPassword = f.oldPassword.value;
		var newPassword = f.newPassword.value;
		var verifyPassword = f.verifyPassword.value;
		if (blank(oldPassword)) alert("Current password is required");
		else if (blank(newPassword)) alert("New password is required");
		else if (newPassword != verifyPassword) alert("Passwords do not match");
		else return true;
		return false;
	}
	function blank(s) {
		return s == null || s == "" || s.match(/^\s+$/);
	}
</script>
</head>
<body>
<font size="+1">Change Password</font><hr>
<a href="personalAdmin.jsp">Settings</a> &gt; Change Password<hr>
<%
if (result != null) out.print("<div class=\"red bold\">" + result + "</div><hr>");
%>
<form action="changePassword.jsp" method="POST" id="form" onSubmit="return verify(this);">
<table>
<tr>
<td class="lbl">Current Password:</td>
<td><input type="password" name="oldPassword"></td>
</tr>
<tr>
<td class="lbl">New Password:</td>
<td><input type="password" name="newPassword"></td>
</tr>
<tr>
<td class="lbl">Verify New Password:</td>
<td><input type="password" name="verifyPassword"></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="submit" value="Change Password"></td>
</tr>
</table>
</form>
<script language="javascript">
	var f = document.getElementById("form");
	f.oldPassword.focus();
</script>
</body>
</html>