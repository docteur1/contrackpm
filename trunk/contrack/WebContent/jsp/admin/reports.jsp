<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" media="all" />
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="../utils/spell.js"></script>
</head>
<body>
<form id="main" action="reports.jsp" method="POST" onSubmit="return checkForm(this);">
<font size="+1">Reports</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Reports<hr>
<%
String id = request.getParameter("id");
String query = "select * from reports where id = '" + request.getParameter("id") + "'";
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
rs.first();
if (request.getParameter("save") != null) {
	rs.updateString("txt", request.getParameter("txt"));
	rs.updateRow();
	out.print("<div class=\"bold red\">Saved</div><hr>");
}
%>
<div>
<select name="id" onChange="window.location='reports.jsp?id=' + this.value;">
	<option value="subWarranty" <%= FormHelper.sel("subWarranty", id) %>>Warranty Letter</option>
	<option value="subCloseout" <%= FormHelper.sel("subCloseout", id) %>>Closeout Letter</option>
	<option value="prMonth" <%= FormHelper.sel("prMonth", id) %>>Monthly Pay Request</option>
	<option value="prFinal" <%= FormHelper.sel("prFinal", id) %>>Final Pay Request</option>
	<option value="lienFinal" <%= FormHelper.sel("lienFinal", id) %>>Final Lien Waiver</option>
	<option value="lienConditional" <%= FormHelper.sel("lienConditional", id) %>>Conditional Lien Waiver</option>
	<option value="lienUnconditional" <%= FormHelper.sel("lienUnconditional", id) %>>Unconditional Lien Waiver</option>
	<option value="documentEmail" <%= FormHelper.sel("documentEmail", id) %>>Document Email Body</option>
	<option value="closeoutEmail" <%= FormHelper.sel("closeoutEmail", id) %>>Closeout Email Body</option>
	<option value="submittalStamp" <%= FormHelper.sel("submittalStamp", id) %>>Submittal Stamp</option>
</select>
<input type="submit" value="Save"> <input type="button" value="Spelling" onClick="spellCheck(this.form);"></div>
<div style="width: 500px; margin-top: 10px;">
	<b>%n</b> Project Name, <b>%s</b> Subcontractor's Name, <b>%c</b> Contractor's Name,
	<b>%t</b> Project State, <b>%y</b> Project City, <b>%d</b> Date, <b>%a</b> Amount
	</div>
<input type="hidden" name="save" value="true">
<textarea  style="margin-top: 10px; font-family: Times;" cols="120" rows="20" name="txt"><%= FormHelper.string(rs.getString("txt")) %></textarea>
</form>
<%
rs.getStatement().close();
db.disconnect();
%>
<script>
	var d = document.getElementById("main").txt;
	d.required = true;
	d.spell = true;
	d.eName = "Report Text";
</script>
</body>
</html>