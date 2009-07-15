<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.utilities.ItemLogger"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
String id = request.getParameter("id");
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="../utils/spell.js"></script>
	<script language="javascript">
		function del(id){
			if(window.confirm("Delete comment?")) window.location = "modifyCompanyComments.jsp?id=<%= id %>&del=" + id;
		}
		var cls;
		function n(id) {
			id.className = cls;
		}
		function b(id) {
			cls = id.className;
			id.className = "yellow";
		}
	</script>
</head>
<body>
<form name="main" action="modifyCompanyComments.jsp" method="GET" onsubmit="return checkForm(this);">
<font size="+1">Comments/Strikes</font>
<hr>
<a href="reviewCompanies.jsp">Companies</a> &gt; 
	<a href="modifyCompany.jsp?id=<%= id %>">Modify Company</a> &gt; Comments/Strikes
	&nbsp; <a href="modifyCompanyComments.jsp?id=<%= id %>">New Comment/Strike</a>
<hr>
<%
String query = "select company_name from company where company_id = " + id;
String name = "ERROR";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (rs.next()) name = rs.getString(1);
if (rs != null) rs.getStatement().close();
if (request.getParameter("del") != null) {
	query = "delete from company_comments where comment_id = " + request.getParameter("del");
	db.dbInsert(query);
}
String comment_id = request.getParameter("comment_id");
String comment = "";
boolean strike = false;
query = "select * from company_comments where comment_id = " + comment_id;
rs = db.dbQuery(query, true);
if (rs.next()) {
	if (request.getParameter("comment_text") != null) {
		comment = request.getParameter("comment_text");
		strike = request.getParameter("strike") != null;
		rs.updateString("comment_text", comment);
		rs.updateBoolean("strike", strike);
		ItemLogger.Updated.update(com.sinkluge.Type.COMPANY_COMMENT, comment_id, session);
		rs.updateRow();
	} else {
		comment = rs.getString("comment_text");
		strike = rs.getBoolean("strike");
	} 
} else if (request.getParameter("comment_text") != null) {
	rs.moveToInsertRow();
	comment = request.getParameter("comment_text");
	strike = request.getParameter("strike") != null;
	rs.updateString("comment_text", comment);
	rs.updateBoolean("strike", strike);
	rs.updateString("company_id", id);
	rs.insertRow();
	rs.last();
	comment_id = rs.getString("comment_id");
	ItemLogger.Created.update(com.sinkluge.Type.COMPANY_COMMENT, comment_id, session);
}
if (rs != null) rs.getStatement().close();
%>
<input type="hidden" name="comment_id" value="<%= comment_id %>">
<input type="hidden" name="id" value="<%= id %>">
<table>
	<tr>
		<td class="lbl">Company:</td>
		<td><%= name %></td>
	</tr>
	<tr>
		<td class="lbl">Comment:</td>
		<td><textarea name="comment_text" cols="80" rows="4"><%= comment %></textarea></td>
	</tr>
	<tr>
		<td class="lbl">Strike:</td>
		<td><input type="checkbox" name="strike" value="t" <% if (strike) out.print("checked"); %>> &nbsp; 
			<input type="submit" value="Save"> &nbsp;
			<input type="button" value="Spelling" onClick="spellCheck(this.form);">
			</td>
	</tr>
</table>
</form>
<script language="javascript">
	var d = document.main;
	var f = d.comment_text;
	f.focus();
	f.select();
	f.required = true;
	f.spell = true;
	f.eName = "Comment";
	
</script>
<table cellspacing="0" cellpadding="3" style="margin-top: 10px;">
	<tr>
		<td class="left head">Delete</td>
		<td class="head">Edit</td>
		<td class="head">Strike</td>
		<td class="head">Comment</td>
		<td class="head right">ID</td>
	</tr>
<%
query = "select * from company_comments where company_id = " + id + " order by strike, comment_id desc";
rs = db.dbQuery(query);
boolean color = false, isUser, isAdmin = sec.ok(Security.ADMIN, Security.WRITE);
SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy h:mm a");
while(rs.next()) {
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
		<td class="left"><a href="javascript: del(<%= rs.getString("comment_id") %>);">Delete</a></td>
		<td class="right"><a 
			href="modifyCompanyComments.jsp?id=<%= id %>&comment_id=<%= rs.getString("comment_id") %>">
			Edit</a></td>
		<td class="input acenter">
<%
	if (rs.getBoolean("strike")) out.print("<img src=\"../images/checkmark.gif\">");
	else out.print("&nbsp;");
%>
			</td>
		<td class="it"><%= FormHelper.string(rs.getString("comment_text")).replaceAll("\n","<br />") %></td>
		<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(rs.getString("comment_id"), 
			com.sinkluge.Type.COMPANY_COMMENT, "window", "contacts/modifyCompanyComments.jsp?id=" + id, request) %></td>
	</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</body>
</html>