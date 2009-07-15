<html>
<head>
	<link rel=stylesheet href="<%= request.getContextPath() %>/jsp/stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<title>Edit</title>
	<script language="javascript" src="../utils/spell.js"></script>
	<script language = "javascript">
		var cof = opener.document.<%= request.getParameter("id") %>;
		function ret() {
			cof.description.value = tf.description.value;
			cof.description.focus();
			window.close();
		}
	</script>
	<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
</head>
<body>
<form name="t">
<table>
	<tr>
		<td><b>Description</td>
	</tr>
	<tr>
		<td><textarea name="description" rows=29 cols=110></textarea></td>
	</tr>
</table>
<input type="button" value="Return" onClick="ret()">
 <input type="button" value="Spelling" onClick="spellCheck(this.form);">
</form>
</body>
<script language = "javascript">
	var tf = document.t;
	tf.description.value = cof.description.value;
	tf.description.focus();
	tf.description.select();
	tf.description.spell = true;
</script>
</html>