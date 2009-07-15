<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../../stylesheets/v2.css" type="text/css">
	<%= Widgets.fontSizeStyle(session) %>
	<script>
		function openWin(loc) {
			win = window.open(loc,"docs","directories=no,height=500,width=500,left=25,location=no,menubar=no,top=25,resizable=yes,status=no,scrollbars=yes");
			if (win.opener == null) opener = self;
			win.focus();
		}
	</script>
</head>
<body bgcolor="#DCDCDC">
<b>Modify Pay<br>Request</b>
<hr>
<table>
<tr>
	<td><input type="button" value="Save" onClick="parent.main.save();" accesskey="s"></td>
</tr>
<%
Database db = new Database();
ResultSet rs = db.dbQuery("select period, final from owner_pay_requests join "
		+ "pay_requests using (opr_id) where pr_id = " + request.getParameter("pr_id"));
boolean isFinal = false;
boolean isRet = false;
if (rs.first()) {
	isFinal = rs.getBoolean("final");
	isRet = "Retention".equals(rs.getString("period"));
}
if (rs != null) rs.getStatement().close();
rs = null;
if (sec.ok(Security.SUBCONTRACT, Security.PRINT)) {
	if (!isRet) {
%>
<tr>
	<td><input type="button" value="Print" 
		onClick="msgWindow = window.open('../../utils/print.jsp?doc=pr<%= isFinal?"Final":"Month" %>.pdf?id=<%= request.getParameter("pr_id")%>','print'); msgWindow.focus();" accesskey="p"></td>
</tr>
<%
	}
%>
<tr>
	<td><%= Widgets.docsButton(request.getParameter("pr_id"), com.sinkluge.Type.PR, request) %></td>
</tr>
<%
}
db.disconnect();
%>
<tr>
	<td><input type="button" value="Close" onClick="parent.window.close();" accesskey="c"></td>
</tr>
</table>
</body>
