<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement, com.sinkluge.Type" %>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.utilities.ItemLogger" %>
<%@page import="com.sinkluge.database.Database" %>
<%
String id = request.getParameter("id");
String search = request.getParameter("search");
String merge_id = request.getParameter("merge_id");
Database db = new Database();
if (merge_id == null) {
	String query = "select company_name from company where company_id = " + id;
	ResultSet rs = db.dbQuery(query);
	String company_name = "";
	if (rs.first()) company_name = rs.getString(1);
	if (rs != null) rs.getStatement().close();
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript">
		function b(id) {
			id.style.backgroundColor = "#FFFFCC";
		}
		function n(id,color) {
			id.style.backgroundColor = color;
		}
		function merge(id) {
			if (confirm("Merge company \"" + document.getElementById("c" + id).value 
				+ "\"\ninto company \"<%= company_name %>\"?")) 
					window.location = "merge.jsp?id=<%= id %>&merge_id=" + id;
		}
	</script>
</head>
<body>
<form action="merge.jsp" method="GET">
<input type="hidden" name="id" value="<%= id %>">
<font size="+1">Merge Companies</font>
<hr>
<a href="reviewCompanies.jsp">Companies</a> &gt; 
	<a href="modifyCompany.jsp?id=<%= id %>">Modify Company</a> &gt; Merge
<hr>
<table>
	<tr>
		<td class="lbl">Company Name:</td>
		<td><input id="search" type="text" name="search" value="<%= FormHelper.string(search) %>"></td>
		<td><input type="submit" value="Search"></td>
	</tr>
</table>
<hr>
<%
	if (search != null) {
		query = null;
		rs = null;
		query = "select distinct company_id, company.company_name, city, state from company where company_name "
			+ "like ? and company_id != " + id + " order by company_name limit 50";
		PreparedStatement ps = db.preStmt(query);
		ps.setString(1, search + "%");
		rs = ps.executeQuery();
		while (rs.next()){
%>
<input type="hidden" id="c<%= rs.getString("company_id") %>" value="<%= rs.getString("company_name") %>">
<div><a href="javascript: merge(<%= rs.getString("company_id") %>);">
	<%= rs.getString("company_name") %></a> - <%= FormHelper.string(rs.getString("city")) %>, 
	<%= FormHelper.string(rs.getString("state")) %></div>
<%
		}
		if (rs != null) rs.getStatement().close();
		db.disconnect();
	}
%>
</form>
<script>
	var s = document.getElementById("search");
	s.focus();
	s.select();
</script>
</body>
</html>
<%
} else {
	String sql = "update contacts set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	sql = "delete from company where company_id = " + merge_id;
	db.dbInsert(sql);
	
	sql = "update company_comments set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	sql = "update job_contacts set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	sql = "update contracts set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	sql = "update letter_contacts set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	sql = "update transmittal set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	sql = "update rfi set company_id = " + id + " where company_id = " + merge_id;
	db.dbInsert(sql);
	long logId = ItemLogger.Updated.update(Type.COMPANY, id, session);
	ItemLogger.setComment(logId, "Merged with company id: " + Type.COMPANY.getCode() 
			+ merge_id);
	// Merge the log data with a comment
	sql = "update log set id = '" + id + "', comment = substring(concat(comment, ' From merged company id : " 
		+ Type.COMPANY.getCode() + merge_id	+ ".'), 0, 255) where id = '" + merge_id + "' and type = '" + Type.COMPANY.name() + "'";
	db.dbInsert(sql);
	logId = ItemLogger.Deleted.update(Type.COMPANY, merge_id, session);
	ItemLogger.setComment(logId, "Merged into company id: " + id);
	response.sendRedirect("modifyCompany.jsp?id=" + id);
}
db.disconnect();
%>
