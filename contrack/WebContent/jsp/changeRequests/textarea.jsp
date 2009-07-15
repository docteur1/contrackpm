<html>
<head>
	<link rel=stylesheet href="<%= request.getContextPath() %>/jsp/stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<title>Edit</title>
	<script src="<%= request.getContextPath() %>/jsp/utils/spell.js"></script>
	<script>
		var cof = opener.document.getElementById("<%= request.getParameter("id") %>");
		function ret() {
			cof.value = d.value;
			cof.focus();
			cof.select();
			window.close();
		}
	</script>
	<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
</head>
<body>
<form>
<textarea style="display: block;" id="description" name="description" rows=29 cols=80></textarea>
<input type="button" value="Return" onClick="ret()">
<input type="button" value="Spelling" onClick="spellCheck(this.form);">
</form>
<script>
	var d = document.getElementById("description");
	d.value = cof.value;
	d.spell = true;
	d.focus();
	d.select();
</script>
</body>
</html>