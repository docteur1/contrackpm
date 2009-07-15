<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.security.Security" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) response.sendRedirect("../accessDenied.html");
%>
<html>
<head>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<SCRIPT LANGUAGE="JavaScript">
	function newLW(id,type) {
		msgWindow=open('','contract','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=300,height=300,left=25,top=25');
		msgWindow.location.href = "getLienAmount.jsp?id=" + id + "&type=" + type;
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	function blank() {
		msgWindow=open('','contract','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=300,height=430,left=25,top=25');
		msgWindow.location.href = "blankLienWaiver.jsp";
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	</script>
</head>
<body>
<div class="title">Lien Waivers</div><hr>
<a href="javascript: blank();">Blank Lien Waiver</a><hr>
<table id="tableHead" cellspacing="0" cellpadding="3">
	<tr>
	<td class="head left nosort">Final</td>
	<td class="head nosort">Unconditional</td>
	<td class="head nosort">Conditional</td>
	<td class="head">Phase</td>
	<td class="head">Description</td>
	<td class="head right">Company</td>
	</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
String query = "select co.contract_id, jcd.code_description, division, jcd.cost_code, jcd.phase_code, com.company_name from contracts as co, job_cost_detail as jcd, company as com where "
	+ "co.company_id = com.company_id and co.cost_code_id = jcd.cost_code_id and co.job_id = " + attr.getJobId()
	+ " order by costorder(division), costorder(cost_code), phase_code";

Database db = new Database();
ResultSet rs = db.dbQuery(query);
boolean color = true;
int id;
while (rs.next()) {
	id = rs.getInt("contract_id");
	color = !color;
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
		<td class="left"><a href="javascript: newLW('<%= id %>','Final');">Final</a></td>
		<td class="it"><a href="javascript: newLW('<%= id %>','Unconditional');">Unconditional</a></td>
		<td class="right"><a href="javascript: newLW('<%= id %>','Conditional');">Conditional</a></td>
		<td class="it aright"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
		<td class="it"><%= rs.getString("code_description") %></td>
		<td class="right"><%= rs.getString("company_name") %></td>
	</tr>
<%
}
rs.close();
db.disconnect();
%>
</table>
</div>
</body>
</html>
