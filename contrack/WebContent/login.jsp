<%@page import="org.apache.log4j.Logger"%>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
	<link rel="SHORTCUT ICON" href="<%= request.getContextPath() %>/images/ct64.ico">
	<title>Contrack - Login (<%= in.build %>)</title>
	<style>
		body {
			color: white;
			background-color: black;
			font-family: Arial;
		}
	</style>
	<script>
		if (self != window.top) parent.location = "<%= request.getContextPath() %>/";
		else if (opener != null) {
			opener.location.reload();
			window.close();
		} else if (parent.opener != null) {
			parent.opener.location.reload();
			window.close();
		}
	</script>
</head>
<body>
<%
if (application.getAttribute("updater") != null) {
	response.sendRedirect(request.getContextPath() + "/update.jsp");
	return;
} else {
if (System.getProperty("com.sinkluge.Test") == null) {
	Cookie[] user = request.getCookies();
	String user_name = "";
	if (user != null) {
		for (int i = 0; i < user.length;i++){
			if (user[i].getName().equals("EPUSER")) user_name = user[i].getValue();
		}
	}
%>
<form name="login" action="<%= response.encodeURL("j_security_check") %>" method="post">
		<table>
			<tr>
				<td colspan="2">
        			<img src="<%= request.getContextPath() %>/images/contrack.gif">
        		</td>
			</tr>
		</table>
		<table style="font-weight: bold;">
         <tr>
         	<td>&nbsp;</td>
         </tr>
         <tr>
         	<td>&nbsp;</td>
         </tr>
<% 
	if (request.getParameter("login_error") != null) out.print("<tr><td colspan=\"2\" style=\"color: red; text-align: center\">Invalid Username or Password!</td></tr><tr><td>&nbsp;</td></tr>");
%>
         <tr>
          	<td><u>U</u>ser</td>
            <td><input type="text" name="j_username" size="20" value="<%= user_name %>" accesskey="u"></td>
         </tr>
         <tr>
           	<td><u>P</u>assword&nbsp;&nbsp;</td>
            <td><input type="password" name="j_password" size="20" value="" accesskey="p"></td>
			</tr>
         <tr>
         	<td colspan="2" align="right"><input type="submit" value="Login"></td>
         </tr>
   	</table>
   	</form>
	<div id="popup" style="width: 500px; color: red; display: none; font-weight: bold; margin-top: 10px;">
		Contrack uses popup windows to display information. Contrack is detecting that a popup
		blocker is installed on your browser. Please add http://<%= request.getServerName() %> to 
		your popup blocker exception list.</div>
   <script>
   		var test = window.open("<%= request.getContextPath() %>/popuptest.html", "test", "toolbar=0,scrollbars=0,location=0,statusbar=0,"
   		   	+ "menubar=0,resizable=0,width=1,height=1,top=300,left=10");
		if (test) test.close();
		else document.getElementById("popup").style.display="block";
<%
	if (user_name.equals("")) out.print("document.login.j_username.focus();");
	else out.print("document.login.j_password.focus();");
%>
   </script>
<%
} else {
	Logger log = Logger.getLogger(this.getClass());
	log.debug("Auto-login user: " + System.getProperty("com.sinkluge.test.User"));
%>
<script>
	window.location = "j_security_check?j_username=<%= System.getProperty("com.sinkluge.test.User") %>"
		+ "&j_password=<%= System.getProperty("com.sinkluge.test.Password") %>";
</script>
<%
}
}
%>
</body>
</html>