<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.utilities.Widgets" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.database.Database" %>
<%
if (!sec.ok(sec.SUBCONTRACT,4)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("id");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script>
		function printSel(obj) {
			var d = document.getElementById("add");
			msgWin = window.open("", "print");
			var url = "../utils/print.jsp?doc=" + obj.value + "&add=" + d.value;
			msgWin.location = url;
			msgWin.focus();
			obj.selectedIndex = 0;
		}
	</script>
</head>
<body bgcolor="#DCDCDC">
<form>
<b>Modify<br>Subcontract
<hr>
<table>
<%
if (sec.ok(sec.SUBCONTRACT, sec.WRITE)) {
%>
<tr>
<td><input type="button" value="Save" onClick="parent.main.save();" accesskey="s"></td>
</tr>
<tr>
<td><input type="button" value="Spelling" onClick="parent.main.spell();" accesskey="k"></td>
</tr>
<%
}
if (sec.ok(sec.SUBCONTRACT, sec.PRINT)) {
%>
<tr>
<td><%= Widgets.docsButton(request.getParameter("id"), com.sinkluge.Type.SUBCONTRACT, request) %></td>
</tr>
<%
}
%>
<tr>
<td><input type="button" value="Close" onClick="parent.window.close();" accesskey="c"></td>
</tr>
<tr>
<%
if (sec.ok(sec.SUBCONTRACT, sec.PRINT)) {
%>
<td><select onChange="printSel(this);">
	<option>--Reports--</option>
	<option value="subChecklist.pdf?id=<%= id %>">Checklist</option>
	<option value="subJobSummary.pdf?id=<%= id %>">Summary</option>
	<option value="subSubmittals.pdf?id=<%= id %>">Sbmt Form</option>
	<option value="subWorksheet.pdf?id=<%= id %>">Worksheet</option>
	<option value="subAll.pdf?id=<%=id %>">All Docs</option>
	<option disabled>Pay Requests</option>
	<option value="prBlankFinal.pdf?id=<%= id %>"> &nbsp; Final</option>
	<option value="prBlankMonth.pdf?id=<%= id %>"> &nbsp; Monthly</option>
	<option disabled>&nbsp;</option>
	<option value="sub.pdf?id=<%= id %>">Agreement</option>
</select></td>
<%
}
%>
</tr>
<tr>
	<td><b>Due In (Days):</b></td>
</tr>
<tr>
	<td><input type="text" id="add" value="10" style="width: 50px;" onChange="checkForm(this.form);"></td>
</tr>
</table>
</form>
<script>
	var d = document.getElementById("add");
	d.required = true;
	d.isInt = true;
	d.eName = "Due In";
</script>
</body>
</html>
