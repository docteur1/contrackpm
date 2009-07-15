<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:include page="../workspace.jsp">
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="contractDisable" value="true"/>
	<jsp:param name="myInfoDisable" value="true" />
	<jsp:param name="method" value="POST"/>
	<jsp:param name="action" value="processChangePasswordFirst.jsp"/>
	</jsp:include>
<font size="+1">Change Password</font><hr>
Set a Password<hr>
&nbsp;<p>You have used a temporary password to login. Please set a new password.<p>&nbsp;
<table>
	<tr>
		<td class="lbl">New Password</td>
		<td><input type="password" name="new_password"></td>
	</tr>
	<tr>
		<td class="lbl">Verify New Password</td>
		<td><input type="password" name="verify_password"></td>
	</tr>
</table>
</td>
</tr>
</table>
</form>
<script language="javascript">
	var m = document.main;
	var f = m.new_password;
	f.focus();
	f.isPassword = true;
	f.passwordMatch = m.verify_password;
	f.currentPassword = m.old_password;
</script>
</body>
</html>