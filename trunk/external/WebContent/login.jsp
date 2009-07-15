<%@page contentType="text/html"%>
<%
Cookie[] user = request.getCookies();
String user_name = "";
if (user != null) {
	for (int i = 0; i < user.length;i++){
		if (user[i].getName().equals("EPEXTUSER")) user_name = user[i].getValue();
	}
}
%>

<html>
<head>
	<title>Contrack - Login</title>
	<link rel="SHORTCUT ICON" href="<%= request.getContextPath() %>/ct64.ico">
	<style>
		fieldset, input, td {
			font-family: Arial;
			font-size: 9pt;
			color: white;
		}
	</style>
</head>
<body bgcolor="#000000">
<form name="login" action="j_security_check" method="POST">
<table width="100%"><tr><td align="center"><img src="<%= request.getContextPath() %>/contrack.gif">
</td></tr>
<tr><td align="center">
	<table>
	<tr><td align="center"><font color="red"><b>
<% 
if(request.getParameter("error") != null) out.print("Invalid username or password"); 
else if (user == null) out.print("Your browser does not support cookies, enable cookie support to continue");
else out.print("&nbsp;");
%>
		</b></font></td></tr>
<%
if (user != null) {
%>
	<tr><td>
	<fieldset style="width: 0%">
		<legend style="color: white;"><b>Contrack - Login</b></legend>
		<table>
			<tr>
				<td align="right"><b>User</b></td>
				<td><input style="color: black;" type="text" name="j_username" value="<%= user_name %>"></td>
			</tr>
			<tr>
				<td align="right"><b>Password</b></td>
				<td><input style="color: black;" type="password" name="j_password" value=""></td>
			</tr>
			<tr>
				<td colspan="2" align="center"><input type="submit" value="Login" style="background-color: black;"></td>
			</tr>
		</table>
	</fieldset>
	</td></tr>
	</table>
</td></tr></table>
</form>
<script>
<%
	if (user_name.equals("")) out.print("document.login.j_username.focus();");
	else out.print("document.login.j_password.focus();");
%>
</script>
<%
}
%>
</body>