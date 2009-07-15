<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.Type" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.utilities.ItemLogger" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<%
if (!sec.ok(Name.CHANGES, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
boolean d = sec.ok(Name.CHANGES, Permission.DELETE);
boolean w = sec.ok(Name.CHANGES, Permission.WRITE);
boolean p = sec.ok(Name.CHANGES, Permission.PRINT);
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="../utils/table.js"></script>
<script src="../utils/verify.js"></script>
<script src="../utils/jsonrpc.js"></script>
<script src="../utils/spell.js"></script>
<script>
	var changed = false;
	function doUnload() {
		if(changed) return "You have unsaved work on this page!";
	}
	window.onbeforeunload = doUnload;
	function verify() {
		try {
			var jsonrpc = new JSONRpcClient("../JSON-RPC");
			var result = jsonrpc.verify.cONum(f.co_num.value, <%= id %>);
		} catch(e) {
			window.alert(result);
		}
		if (!result) {
			changed = false;
			f.submit();
			return true;
		} else {
			window.alert("ERROR\n------------------------\nDuplicate CO #. The number is already "
					+ "used on:\n" + result + ".");
			f.co_num.style.backgroundColor = "#FFFFCC";
			return false;
		}
	}
	function edit(id) {
		window.location = "cos.jsp?id=" + id;
	}
	function del(id) {
		if (window.confirm("Delete this Change Order?"))
			window.location = "cos.jsp?del=" + id;
	}
	function crs(id) {
		window.location = "index.jsp?id=" + id;
	}
	function reload() {
		window.location = "<%= request.getContextPath() %>/jsp/changeRequests/cos.jsp";
	}
	function printSum(id) {
		var msgWindow = open("../utils/print.jsp?doc=changeRequestSummary.pdf?id=" + id, "print");
		msgWindow.focus();
	}
</script>
</head>
<body>
<div class="title">Change Orders</div><hr>
<%= w ? "<div class=\"link\" onclick=\"window.location='cos.jsp?new=true'\">New</div><hr>" : "" %>
<%
ResultSet rs;
String sql;
Database db = new Database();
if (request.getParameter("del") != null) {
	sql = "select count(*) from change_requests where co_id = " + request.getParameter("del");
	rs = db.dbQuery(sql);
	if (rs.first() && rs.getInt(1) != 0)
		out.print("<div class=\"red bold\">Could not delete change order, associated with " + rs.getInt(1) 
				+ " change requests.</div><hr>");
	else {
		db.dbInsert("delete from change_orders where co_id = " + request.getParameter("del"));
		ItemLogger.Deleted.update(Type.CO, request.getParameter("del"), session);
	}
	rs.getStatement().close();
}
if (request.getParameter("new") != null || id != null) {
	JSONRPCBridge.registerClass("verify", com.sinkluge.JSON.Verify.class);
	String coDescription = "";
	int coNum = 1;
	if (id == null) {
		if (request.getParameter("co_num") != null) {
			sql = "select * from change_orders where co_id = 0";
			rs = db.dbQuery(sql, true);
			coNum = Integer.parseInt(request.getParameter("co_num"));
			coDescription = request.getParameter("co_description");
			rs.moveToInsertRow();
			rs.updateInt("co_num", coNum);
			rs.updateInt("job_id", attr.getJobId());
			rs.updateString("co_description", coDescription);
			rs.insertRow();
			rs.last();
			id = rs.getString("co_id");
			ItemLogger.Created.update(Type.CO, id, session);
			rs.getStatement().close();
			out.print("<div class=\"red bold\">Saved</div><hr>");
		} else {
			sql = "select max(co_num) from change_orders where job_id = " + attr.getJobId();
			rs = db.dbQuery(sql);
			if (rs.next()) coNum = rs.getInt(1) + 1;
			rs.getStatement().close();
		}
	} else {
		sql = "select * from change_orders where co_id = " + id;
		rs = db.dbQuery(sql, true);
		if (rs.first()) {
			if (request.getParameter("co_num") != null) {
				rs.updateString("co_num", request.getParameter("co_num"));
				rs.updateString("co_description", request.getParameter("co_description"));
				ItemLogger.Updated.update(Type.CO, id, session);
				rs.updateRow();
				out.print("<div class=\"red bold\">Saved</div><hr>");
			}
			coNum = rs.getInt("co_num");
			coDescription = rs.getString("co_description");
		}
		rs.getStatement().close();
	}
	
%>
<form id="co" method="POST">
<%= id != null ? "<input type=\"hidden\" name=\"co_id\" value=\"" + id + "\">" : "" %>
<fieldset style="width: 300px;">
<legend>Change Order</legend>
<table>
<tr>
<td class="lbl">CO #</td>
<td><input type="text" name="co_num" value="<%= coNum %>" onchange="changed=true;"></td>
</tr>
<tr>
<td class="lbl">CO Description</td>
<td><input type="text" name="co_description" value="<%= coDescription %>" 
	onchange="changed=true;"></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="button" value="Save" onclick="verify();"> &nbsp; 
	<input type="button" value="Spell" onclick="spellCheck(co);"></td>
</tr>
</table>
</fieldset>
</form>
<script>
	var f = document.getElementById("co");
	f.co_num.required = true;
	f.co_num.eName = "CO #";
	f.co_description.select();
	f.co_description.focus();
	f.co_num.isInt = true;
	f.co_description.spell = true;
</script>
<%
}
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="head left nosort">Delete</td>
	<td class="head nosort">Edit</td>
	<td class="head nosort">Print</td>
	<td class="head nosort">Files</td>
	<td class="head nosort">CRs</td>
	<td class="head">CO #</td>
	<td class="head">Description</td>
	<td class="head right">ID</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
sql = "select *, (select count(*) from change_requests where change_requests.co_id " 
	+ " = change_orders.co_id) as num from change_orders where job_id = " + attr.getJobId()
	+ " order by costorder(co_num) desc";
rs = db.dbQuery(sql);
boolean color = true;
int numCrs;
while (rs.next()) {
	color = !color;
	id = rs.getString("co_id");
	numCrs = rs.getInt("num");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<td class="left"><%= d ? "<div class=\"link\" onclick=\"del(" +  id + ");\">Delete</div>" : "&nbsp;" %></td>
<td class="it"><%= w ? "<div class=\"link\" onclick=\"edit(" + id + ")\">Edit</div>" : "&nbsp;" %></td>
<td class="it"><%= p && numCrs != 0 ? "<div class=\"link\" onclick=\"printSum(" + id + ")\">Print</div>" : "&nbsp;" %></td>
<td class="it"><%= Widgets.docsLink(id, Type.CO, request) %></td>
<td class="right"><%= numCrs != 0 ? "<div class=\"link\" onclick=\"crs(" + id + ");\">CRs (" + numCrs 
		+ ")</div>" : "&nbsp;" %></td>
<td class="it aright"><%= FormHelper.stringTable(rs.getString("co_num")) %></td>
<td class="it"><%= FormHelper.stringTable(rs.getString("co_description")) %></td>
<td class="right"><%= Widgets.logLinkWithId(id, Type.CO, "window", request) %></td>
</tr>
<%
}
rs.getStatement().close();
db.disconnect();
%>
</table>
</body>
</html>