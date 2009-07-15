<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.LETTERS, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript">
		function pT() {
			var ref = "../servlets/letters/letter.pdf?id=<%=request.getParameter("letter_id")%>";
			msgWin = window.open(ref, "print");
			msgWin.focus();
		}
		function send() {
			var ref = "../servlets/letters/sendLetter.pdf?id=<%=request.getParameter("letter_id")%>";
			if (window.confirm("Send letter to email <%= in.hasFax ? "and fax " : "" %>recipients?")) {
				msgWin = window.open(ref, "print");
				msgWin.focus();
			}
		}
	</script>
</head>
<body bgcolor="#DCDCDC">
<b>Modify<br>Letter</b>
<hr>
<table>
<%
if (sec.ok(Security.LETTERS, Security.WRITE)) {
%>
<tr>
<td><input type="button" value="Save" onClick="parent.main.save();" accesskey="s"></td>
</tr>
<tr>
<td><input type="button" value="Spelling" onClick="parent.main.spell();" accesskey="k"></td>
</tr>
<%
}
if (sec.ok(Security.LETTERS, Security.PRINT)) {
%>
<tr>
<td><input type="button" value="<%= in.hasFax ? "Fax/" : "" %>Email" onClick="send()" accesskey="s"></td>
</tr>
<tr>
<td><input type="button" value="Print" onClick="pT()" accesskey="p"></td>
</tr>
<tr>
	<td><%= Widgets.docsButton(request.getParameter("letter_id"), com.sinkluge.Type.LETTER, request) %></td>
</tr>
<%
}
%>
<tr>
<td><input type="button" value="Recipients" onClick="parent.main.location = 'modifyRecipients.jsp?letter_id=<%=request.getParameter("letter_id")%>'" accesskey="t"></td>
</tr>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();" accesskey="c"></td>
</tr>
</body>
