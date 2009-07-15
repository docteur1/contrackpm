<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.WRITE)) response.sendRedirect("../accessDenied.html");
int siteId = Integer.parseInt(request.getParameter("site_id"));
%>
<html>
<head>
	<LINK REL="stylesheet" HREF="../../stylesheets/v2.css" TYPE="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<title>Add Phase Code</title>
</head>
<body>
<font size="+1">Add Phase Code</font><hr>
<form name="main" action="processGenericCode.jsp" method="POST" onsubmit="return checkForm(this);">
<input type="hidden" name="site_id" value="<%= siteId %>">
<table>
<tr>
	<td class="lbl">Division</td>
	<td colspan="3">
		<select name="division">
<%
Database db = new Database();
ResultSet rs = db.dbQuery("select * from divisions where site_id = " + siteId + " order by costorder(division)");
while(rs.next()) out.println("<option value=\"" + rs.getString("division") + "\">" + rs.getString("division") 
		+ " " + rs.getString("description") + "</option>");
if (rs != null) rs.getStatement().close();
%>
</tr>
<tr>
	<td align="right"><b>Phase Code:</td>
	<td><input type="text" value="" name="cost_code" size=5 maxlength=15></td>
	<td align="right"><b>Phase:</td>
	<td>
		<select name="cost_type">
<%
rs = db.dbQuery("select * from cost_types where site_id = " + siteId + " order by letter");
while(rs.next()) out.println("<option value=\"" + rs.getString("letter") + "\">" + rs.getString("letter") 
		+ "-" + rs.getString("description") + "</option>");
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
		</select>
	</td>
</tr>
<tr>
	<td align="right"><b>Description:</td>
	<td colspan=3><input type="text" name="description" size=30 maxlength=50 value=""></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td colspan="3"><input type="submit" value="Save">
		&nbsp;&nbsp;<input type="button" value="Cancel" onClick="window.close();">
	</td>
</tr>
</table>
</form>
<script language="javascript">
	var f = document.main;
	
	var d = f.description;
	d.required = true;
	d.eName = "Description";
	
	d = f.cost_code;
	d.required = true;
	d.eName = "Phase Code";
</script>
</body>
</html>
