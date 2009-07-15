<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.User" %>
<%@page import="java.util.Iterator" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.LETTERS, Security.READ)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("letter_id");
String query = "select * from letters where letter_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if(rs.next()){
%>

<html>
	<head>
		<script language="javascript" src="../utils/verify.js"></script>
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/spell.js"></script>
		<script language="javascript">
			parent.left.location = "modifyLetterLeft.jsp?letter_id=<%= id %>";
			function spell() {
				spellCheck(f);
			}
			function save() {
				if(checkForm(f)) f.submit();
			}
		</script>
		<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
			</head>
			<body>
						<form name="modifyLetter" action="processModifyLetter.jsp" method="POST">
			<font size="+1">Modify Letter</font><hr>
			<% if(request.getParameter("saved") != null) out.print("<font color=\"red\"><b>Saved</b></font><hr>");%>


			<input type="hidden" name="letter_id" value="<%=id%>">
			<table>
				<tr><td align="right"><b>ID:</b></td>
					<td><%= com.sinkluge.utilities.Widgets.logLinkWithId(id,
						com.sinkluge.Type.LETTER, "parent", request) %></td>
				</tr>
				<tr><td align="right"><b>From:</b></td>
					<td align="left">
<%
int userId = rs.getInt("user_id");
out.print(com.sinkluge.utilities.Widgets.userList(userId, "user_id"));
%>
		</td></tr>
			<tr><td align="right"><b>Copy To:</b></td><td align="left">
			<input type = "text" name="cc" size=25 value="<%=rs.getString("cc")%>">
			</td></tr>
			<tr><td align="right"><b>Subject:</td><td align="left">
			<input type = "text" name="subject" size=25 value="<%=rs.getString("subject")%>">
			</td></tr>
			<tr><td align="right"><b>Salutation:</td><td align="left">
			<input type = "text" name="salutation" size=25 value="<%=rs.getString("salutation")%>">
			</td></tr>


			<tr><td align="right"><b>Body of Letter:</td>
			<td align="left"><textarea name="body_text" rows=20 cols=80><%=rs.getString("body_text")%></textarea></td></tr>


			</table>
<%
}
rs.close();
db.disconnect();
%>


			</form>
<script language="javascript">
	var f = document.modifyLetter;
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


