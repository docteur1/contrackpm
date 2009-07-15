<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.User" %>
<%@page import="java.util.Iterator, java.util.StringTokenizer" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.database.Database" %>
<%
if (!sec.ok(Security.LETTERS, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String ids = request.getParameter("ids");
String email = "";
String fax = "";
String print = "";
StringTokenizer st = new StringTokenizer(ids, ",");
String type, temp;
while (st.hasMoreTokens()) {
	temp = st.nextToken();
	type = temp.substring(0,1);
	if (type.equals("E")) {
		if (!email.equals("")) email += ",";
		email += temp.substring(1);
	} else if (type.equals("F")) {
		if (!fax.equals("")) fax += ",";
		fax += temp.substring(1);
	} else {
		if (!print.equals("")) print += ",";
		print += temp.substring(1);
	}
}
%>
<html>
<head>
<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="../utils/spell.js"></script>
	<script language="javascript">
		parent.left.location="newLetterLeft2.jsp";
			function spell() {
				spellCheck(f);
			}
			function save() {
				if(checkForm(f)) f.submit();
			}
	</script>
</head>
<body>
<form name="newLetter" action="processLetter.jsp" method="POST">
<input type="hidden" name="email" value="<%= email %>">
<input type="hidden" name="fax" value="<%= fax %>">
<input type="hidden" name="print" value="<%= print %>">
<font size="+1">New Letter (2 of 2)</font><hr>

<table>
				<tr><td align="right"><b>From:</td>
				<td><%= com.sinkluge.utilities.Widgets.userList(attr.getUserId(), "user_id") %></td></tr>
		<tr><td align="right"><b>Copy To:</td><td align="left">
	<input type = "text" name="cc" size=25>
</td></tr>
		<tr><td align="right"><b>Subject:</td><td align="left">
		<input type = "text" name="subject" size=25>
		</td></tr>
		<tr><td align="right"><b>Salutation:</td><td align="left">
		<input type = "text" name="salutation" size=25>
		</td></tr>
		<tr><td align="right"><b>Body of Letter:</td>
    <td align="left"><textarea name="body_text" rows=20 cols=80></textarea></td></tr>


</table>


</form>
<script language="javascript">
	var f = document.newLetter;
	var d = f.body_text;
	d.spell = true;
	d.required = true;
	d.eName = "Body";
	
	d = f.subject;
	d.required = true;
	d.eName = "Subject";
	d.spell = true;
	
</script>
</body></html>

