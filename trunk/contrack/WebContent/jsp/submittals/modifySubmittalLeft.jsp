<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBMITTALS,4)) response.sendRedirect("../accessDenied.html");
boolean sp = sec.ok(Security.SUBMITTALS,Security.PRINT);
boolean sw = sec.ok(Security.SUBMITTALS,Security.WRITE);
%>
<html>
<head>
	<script src="../utils/print.js"></script>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body bgcolor="#DCDCDC">
<b>Modify<br>Submittal</b>
<hr>
<table>
<%
if (sw) {
%>
<tr>
<td><input type="button" value="Save" onClick="parent.main.save();" accesskey="s"></td>
</tr>
<tr>
<td><input type="button" value="Spelling" onClick="parent.main.spell();" accesskey="k"></td>
</tr>
<%
if (sec.ok(Security.SUBMITTALS, Security.PRINT)) {
%>
<tr>
<td><%= Widgets.docsButton(request.getParameter("subID"), com.sinkluge.Type.SUBMITTAL, request) %></td>
</tr>
<%
}
%>
<tr>
<td><input type="button" value="Link" onClick="parent.main.location='link.jsp?id=<%= 
	request.getParameter("subID") %>';"></td>
<%
} // End if write
%>
<tr>
	<td><%= Widgets.eSubmit(request.getParameter("subID"), com.sinkluge.Type.SUBMITTAL,
		"parent", request) %></td>
</tr>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();" accesskey="c"></td>
</tr>
<%
ResultSet rs = null;
Database db = new Database();
if(sec.ok(Security.SUBMITTALS, Security.PRINT)) {
	rs = db.dbQuery("select contract_id from submittals where contract_id != 0 and " + 
			"submittal_id = " + request.getParameter("subID"));
%>
	<tr>
	<td><select onChange="printSel(this);">
		<option>--Reports--</option>
		<option value="sbmtArchitect.pdf?id=<%=request.getParameter("subID")%>">To Architect</option>
<%= (rs.isBeforeFirst() ? "<option value=\"sbmtSubcontractor.pdf?id=" + request.getParameter("subID") + "\">To Sub</option>"
		: "") %>
	</select></td>
	</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</body>
</html>
