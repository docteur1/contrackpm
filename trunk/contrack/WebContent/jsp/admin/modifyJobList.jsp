<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper, com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
String query = "select job_id, job_num, job_name, active from job order by active desc, costorder(job_num) desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String job_id;
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
</head>
<body>
<form name="jobList" action="processModifyJobList.jsp" method="POST">
<font size="+1">My Project List</font><hr>
<a href="personalAdmin.jsp">My Settings</a> &gt; My Project List<hr>
<%
if (request.getParameter("save") != null) out.print("<span class=\"red bold\">Saved</span><hr>");
%>
<div><input type="submit" value="Save"> &nbsp; 
	<span class="red">Red</span> indicates an inactive job.
</div>
<table cellspacing="0" cellpadding="3" id="tableHead" style="margin-top: 10px;">
<tr>
<td class="left head">Selected</td>
<td class="head">Project #</td>
<td class="right head">Project Name</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean c = true;
ResultSet userJob;
while(rs.next()) {
	c = !c;
	userJob = db.dbQuery("select * from user_jobs where job_id = " + rs.getInt("job_id")
		+ " and user_id = " + attr.getUserId());
	job_id = rs.getString("job_id");
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" class="<%= c?"gray":"" %>" />
	<td class="left input acenter"><input type="checkbox" value="y" <%=
		FormHelper.chk(userJob.first()) %> name="<%= job_id %>"></td>
	<td class="it acenter"><%= rs.getString("job_num") %></td>
	<td class="right"><% if (rs.getString("active").equals("n")) out.println("<span class=\"red\">" + rs.getString("job_name") + "</span>");
		else out.println(rs.getString("job_name")); %></td>
</tr>
<%
	userJob.getStatement().close();
}
rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</div>
</form>
</body></html>
