<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper,
	com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) response.sendRedirect("../accessDenied.html");
Database db = new Database();
String letter = request.getParameter("letter");
int siteId = Integer.parseInt(request.getParameter("site_id"));
int saved = -1;
ResultSet rs = null;
String query = "select * from cost_types where site_id = " + siteId + " order by letter";
if (letter != null) {
	if (request.getParameter("op") != null) {
		db.dbInsert("delete from cost_types where letter='" + letter + "' and site_id = " + siteId);
	} else {
		PreparedStatement ps = db.preStmt("insert ignore into cost_types (site_id, letter, description) values (?,?,?)");
		ps.setInt(1, siteId);
		ps.setString(2, letter);
		ps.setString(3, request.getParameter("description"));
		saved = ps.executeUpdate();
		if (ps != null) ps.close();
	}
} else if (request.getParameter("table") != null) {
	rs = db.dbQuery(query, true);
	while (rs.next()) {
		letter = rs.getString("letter");
		rs.updateString("mapping", request.getParameter("m" + letter));
		rs.updateBoolean("labor", request.getParameter("l" + letter) != null);
		rs.updateBoolean("contractable", request.getParameter("c" + letter) != null);
		rs.updateBoolean("site_work", request.getParameter("i" + letter) != null);
		rs.updateString("contract_title", request.getParameter("t" + letter));
		rs.updateString("contractee_title", request.getParameter("s" + letter));
		rs.updateRow();
	}
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" media="all" />
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript">
		function del(txt) {
			if(confirm("Delete this cost type?")) location="costTypes.jsp?op=d&site_id=<%= siteId %>&letter=" + txt;
		}
		function b(id) {
			id.style.backgroundColor = "#FFFFCC";
		}
		function n(id,color) {
			id.style.backgroundColor = color;
		}
	</script>
</head>
<body>
<font size="+1">Cost Types</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Cost Types<hr>
<%
if (saved > -1) {
	if (saved > 0) out.print("<span class=\"red bold\">Saved</span><hr>");
	else out.print("<span class=\"red bold\">Not Saved (duplicate entry?)</span><hr>");
}
%>
<form id="main" action="costTypes.jsp" method="post" onsubmit="return checkForm(this);">
<table>
	<tr>
		<td class="lbl">Site</td>
		<td colspan="3"><select name="site_id" onChange="window.location='costTypes.jsp?site_id=' + this.value;">
<%
ResultSet sites = db.dbQuery("select site_id, site_name from sites");
while (sites.next()) out.println("<option value=\"" + sites.getString(1) + "\" " + 
		FormHelper.sel(sites.getInt(1), siteId) + ">" + sites.getString(2) + "</option>");
if (sites != null) sites.getStatement().close();
%>
		</select></td>
	</tr>
	<tr>
		<td class="lbl">Letter Code</td>
		<td><input type="text" maxlength="1" size="1" name="letter"></td>
		<td class="lbl">Description</td>
		<td><input type="text" name="description"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="3"><input type="submit" value="Add"></td>
	</tr>
</table>
</form>
<script language="javascript">
	var f = document.getElementById("main");
	var d = f.letter;
	d.eName = "Letter";
	d.required = true;
	d.focus();
	d.select();
	
	d = f.description;
	d.required = true;
	d.eName = "Description";
</script>
<form id ="main2" action="costTypes.jsp" method="post">
<input type="hidden" name="table" value="true">
<input type="hidden" name="site_id" value="<%= siteId %>">
<table cellspacing="0" cellpadding="3" style="margin-top: 10px;">
	<tr>
		<td class="left head">Delete</td>
		<td class="head">Contract</td>
		<td class="head">Letter</td>
		<td class="head">Description</td>
		<td class="head">Mapping</td>
		<td class="head">Contractable</td>
		<td class="head">Labor</td>
		<td class="head">Prove Ins</td>
		<td class="head">Contract Title</td>
		<td class="head right">Performer Title</td>
	</tr>
<%
boolean color = true;
if (rs == null) rs = db.dbQuery(query);
else rs.beforeFirst();
while (rs.next()) {
	color = !color;
%>
	<tr onMouseOver="b(this);" <% if (color) out.print("onMouseOut=\"n(this,'#DCDCDC');\" bgcolor=\"#DCDCDC\""); else out.print("onMouseOut=\"n(this,'#FFFFFF');\""); %>>
		<td class="left"><a href="javascript: del('<%= rs.getString("letter") %>');">Delete</a></td>
		<td class="right"><%= rs.getBoolean("contractable")?"<a href=\"costTypeContract.jsp?letter=" 
			+ rs.getString("letter") + "&site_id=" + siteId + "\">Contract</a>":"&nbsp;" %></td>
		<td class="it"><%= rs.getString("letter") %></td>
		<td class="it"><%= rs.getString("description") %></td>
		<td class="input"><input style="width: 50px;" type="text" name="m<%= rs.getString("letter") %>"
			value="<%= FormHelper.string(rs.getString("mapping")) %>"></td>
		<td class="input"><input type="checkbox" name="c<%= rs.getString("letter") %>"
			value="y" <%= FormHelper.chk(rs.getBoolean("contractable")) %>></td>	
		<td class="input"><input type="checkbox" name="l<%= rs.getString("letter") %>"
			value="y" <%= FormHelper.chk(rs.getBoolean("labor")) %>></td>
<%
	if (rs.getBoolean("contractable")) {
%>
		<td class="input"><input type="checkbox" name="i<%= rs.getString("letter") %>"
			value="y" <%= FormHelper.chk(rs.getBoolean("site_work")) %>></td>
		<td class="input"><input style="width: 80px;" type="text" name="t<%= rs.getString("letter") %>"
			value="<%= FormHelper.string(rs.getString("contract_title")) %>"></td>
		<td class="input right"><input style="width: 80px;" type="text" name="s<%= rs.getString("letter") %>"
					value="<%= FormHelper.string(rs.getString("contractee_title")) %>"></td>
<%
	} else out.println("<td colspan=\"3\" class=\"right\">&nbsp;</td>");
%>
	</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
<tr>
	<td colspan="2">&nbsp;</td>
	<td colspan="5"><input type="submit" value="Save"></td>
</tr>
</table>
</form>
</body>
</html>