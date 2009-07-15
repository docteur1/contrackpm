<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String job_id = Integer.toString(attr.getJobId());
String query = "select cc.*, jcd.cost_code_id from cost_codes as cc join job_divisions as jd on cc.division = "
	+ "jd.division and job_id = " + attr.getJobId() + " and cc.site_id = " + attr.getSiteId() 
	+ " left join job_cost_detail as jcd on cc.division = jcd.division and cc.cost_code "
	+ "= jcd.cost_code and cc.cost_type = jcd.phase_code and jcd.job_id = "
	+ attr.getJobId() + " order by costorder(cc.division), costorder(cc.cost_code), "
	+ "cc.cost_type";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String cost_code;
String phase_code;
String division;
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<script language="javascript">
	function c(obj) {
		id = obj.name.substring(1);
		var tObj = document.getElementById("t" + id);
		if (obj.checked) tObj.style.visibility = "visible";
		else {
			tObj.style.visibility = "hidden";
			tObj.value = "0";
		}
	}
	</script>
	<style>
		input.box {
			font-size: 8pt;
			border-style: solid;
			border-width: 1;
			border-color: gray;
			padding: 0;
			text-align: right;
			width: 50px;
			visibility: hidden;
		}
	</style>
</head>
<body>
<form name="codes" action="processAddManyCodes.jsp" method="POST">
<div class="title">Select Phases</div><hr>
<a href="codes.jsp">Costs</a> &gt; Select Phases<hr>
<div id="load"><img src="../../images/loading_circle.gif"/></div>
<div id="done" style="visibility: hidden;">
<input type="submit" value="Save">
<table cellspacing="0" cellpadding="3" style="margin-top: 8px;" id="tableHead">
<tr>
<td class="left head">Selected</td>
<td class="head nosort">Est/Budgt</td>
<td class="head">Code</td>
<td class="right head">Description</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
boolean c = true;
boolean d = true;
while(rs.next()) {
	c = !c;
	d = rs.getString("cost_code_id") != null;
	cost_code = rs.getString("cost_code");
	phase_code = rs.getString("cost_type");
	division = rs.getString("division");
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (c) out.print("class=\"gray\""); %>>
		<td class="left acenter input"><input type="checkbox" 
			<% if (!d) out.print ("name=\"c" + rs.getString("code_id") + "\" value=\"t\" onClick=\"c(this);\""); 
			   else out.print("checked disabled"); %>></td>
<%
if (!d) {
%>
		<td class="input aright"><input type="text" class="box" id="t<%= rs.getString("code_id") %>" name="t<%= rs.getString("code_id") %>" value="0"></td>
<%
} else {
%>
		<td class="it">&nbsp;</td>
<%
}
%>
		<td class="it aright"><%= division + " " + cost_code + "-" + phase_code %></td>
		<td class="right"><%= rs.getString("description") %></td>
	</tr>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</div>
<script language="javascript">
	document.getElementById("load").style.display = "none";
	document.getElementById("done").style.visibility = "visible";
</script>
</form>
</body></html>
