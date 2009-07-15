<%@page contentType="text/html"%>
<%@page session="true"%>
<jsp:include page="../workspace.jsp">
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="method" value="POST"/>
	<jsp:param name="action" value="processChangePassword.jsp"/>
	</jsp:include>
<font size="+1">Change Password</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">My Info</a> &gt; Change Password<hr>
<table>
	<tr>
		<td class="lbl">Old Password</td>
		<td><input type="password" name="old_password"></td>
	</tr>
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
	var f = m.old_password;
	f.focus();
	
	f = m.new_password;
	f.isPassword = true;
	f.passwordMatch = m.verify_password;
	f.currentPassword = m.old_password;
</script>
</body>
</html>