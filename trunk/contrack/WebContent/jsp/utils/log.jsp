<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.Type, com.sinkluge.database.Database, com.sinkluge.User" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<%
JSONRPCBridge.registerClass("home", com.sinkluge.JSON.Home.class);
String id = request.getParameter("id");
Type type = Type.valueOf(request.getParameter("type"));
String loc = request.getParameter("loc");
if (!sec.ok(type.getSecurityName(), com.sinkluge.security.Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="../utils/table.js"></script>
<script src="<%= request.getContextPath() %>/jsp/utils/jsonrpc.js"></script>
<script>
	var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
	function setComment(id) {
		var commentDiv = document.getElementById(id);
		var msg = commentDiv.innerHTML;
		if (msg == "&nbsp;") msg = ""; 
		msg = window.prompt("Enter/change the comment", msg);
		if (msg == null || msg == "") commentDiv.innerHTML = "&nbsp;";
		else commentDiv.innerHTML = msg;
		resize();
		jsonrpc.home.setLogComment(msg, id);
	}
</script>
<title>Log - <%= type.getCode() + id %></title>
</head>
<body>
<div class="title">Log - <%= type.getCode() + id %></div><hr>
<div class="link" onclick="window.location='<%= loc %>';">Back</div> &gt; Log - <%= type.getCode() + id %><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Edit</td>
	<td class="head">Date/Time</td>
	<td class="head">User</td>
	<td class="head">Action</td>
	<td class="head">External</td>
	<td class="head">To</td>
	<td class="head right">Comment</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%!
String getUser(String id, boolean ext, Database db) throws Exception {
	String out = null;
	if (!ext) {
		User user = User.getUser(id);
		if (user != null) out = "<div class=\"link\" onclick=\"window.location='mailto:"
			+ user.getFullName() + " <" + user.getEmail() + ">';\">" + user.getFullName() + "</div>";
		else out = "Unknown";
	} else {
		ResultSet rs = db.dbQuery("select name, company_name, email from contacts join company using (company_id) "
			+ "where contact_id = " + id);
		if (rs.first()) {
			out = "<div class=\"link\" onclick=\"window.location='mailto:"
				+ rs.getString("name") + " <" + rs.getString("email") + ">';\">" + rs.getString("name")
				+ " (" + rs.getString("company_name") + ")</div>";
		} else {
			out = "Unknown";
		}
	}
	return out;
}
%>
<%
Database db = new Database();
String sql = "select * from log where id = '" + id + "' and type = '" + type.getCode() + "'";
ResultSet rs = db.dbQuery(sql), rs2 = null;
boolean color = true;
int compID, conID;
while (rs.next()) {
	color = !color;
	compID = rs.getInt("to_company_id");
	if (compID != 0) {
		conID = rs.getInt("to_contact_id");
		if (conID != 0) rs2 = db.dbQuery("select name from contacts where "
				+ "contact_id = " + conID);
		else rs2 = db.dbQuery("select company_name as name from company where "
				+ "company_id = " + compID);
	}
	
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left"><div class="link" onclick="setComment(<%= rs.getString("log_id") %>);">Edit</div></td>
	<td class="it"><%= FormHelper.timestamp(rs.getTimestamp("stamp")) %></td>
	<td class="it"><%= getUser(rs.getString("uid"), rs.getBoolean("external"), db) %></td>
	<td class="it"><%= rs.getString("activity") %></td>
	<td class="input"><%= com.sinkluge.utilities.Widgets.checkmark(rs.getBoolean("external"), request) %></td>
	<td class="it"><%= rs2 != null && rs2.first() ? "<div class=\"link\" onclick=\"window.location='" 
		+ application.getContextPath() + "/jsp/contacts/modifyCompany.jsp?id=" + compID + "';\">"
		+ rs2.getString("name") + "</div>" : "&nbsp;" %></td>
	<td class="right"><div id="<%= rs.getString("log_id") %>"><%= FormHelper.stringTable(rs.getString("comment")) %></div></td>
</tr>
<%
	if (rs2 != null) rs2.getStatement().close();
	rs2 = null;
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>