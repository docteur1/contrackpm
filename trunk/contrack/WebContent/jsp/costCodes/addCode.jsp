<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/style.css">
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript" src="scripts/addCode.js"></script>
	<style>
		input, select, button {
			border-style: solid;
			border-width: 1;
			border-color: gray;
			padding: 0;
		}
		td {
			padding-top: 1px;
			padding-bottom: 1px;
		}
		button {
			background-color: #FFA07A;
		}
	</style>
</head>
<body>
<form name="newCode" method="POST">
<table cellspacing="0" cellpadding="0" style="background-color: #E1DED9;">
<tr>
<td colspan="7" style="text-align: center;">
<select name="div" id="div" tabindex="14">
<%
String query = "select division, description from job_divisions where job_id = " + attr.getJobId()
	+ " order by costorder(division)";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
while (rs.next()) out.print("<option value=\"" + rs.getString(1) + "\"" 
	+ FormHelper.sel(rs.getString(1), attr.getDiv()) + ">" + rs.getString(1) + " " 
	+ rs.getString(2) + "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
%>
</select> &nbsp;
<%
query = "select cc.* from cost_codes as cc join job_divisions as jd using(division) "
	+ "where site_id = " + attr.getSiteId() + " and job_id = " + attr.getJobId() + " order by "
	+ "costorder(division), costorder(cc.cost_code), cc.cost_type";
rs = db.dbQuery(query);
%>
	<select name="ddCostCode" onChange="loadCode(this);" tabindex="1" <%= FormHelper.dis(!rs.isBeforeFirst()) %>>
		<option value="">&nbsp;</option>
<%
while(rs.next()) {
%>
	<option><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" 
		+ rs.getString("cost_type") + " " + rs.getString("description") %></option>
<%
}
if (rs != null) rs.close();
rs = null;
%>
		</select>
</td>
	<td rowspan="2" class="r60" style="text-align:center;" title="Lock budget and estimate"><b>Lock</b><br>
		<input type="checkbox" style="border: 0px;" tabindex="10" name="lock" value="y"></td>
	<td colspan="3" style="text-align: right;"><button tabindex="15" accesskey="s" onClick="return save();"><u>S</u>ave</button>
		&nbsp; <button onClick="return hide();" tabindex="16" accesskey="c"><u>C</u>lose</button></td>
</tr>
<tr>
	<td class="r35"><input type="text" name="cost_code" style="width: 35px; text-align: right; padding-right: 2px;" 
		tabindex="2" maxlength="15"></td>
	<td class="l130"><input type="text" tabindex="3" name="description" style="width: 127px; padding-left: 2px;"></td>
	<td style="padding-left: 1px; padding-right: 1px; width: 11px;">
		<input id="type" type="text" tabindex="4" value="L" name="phase" 
			style="text-transform:uppercase; width: 11px; text-align: center;" maxlength="1"
			onChange="verifyCostType(this.value.toUpperCase())"></td>
	<td class="r60"><input type="text" id="estimate" tabindex="6" name="estimate" class="r60" value="0"></td>
	<td class="r60">&nbsp;</td>
	<td class="r60"><input type="text" tabindex="8 "name="budget" value="0" class="r60" onChange="f.complete.value = this.value;"></td>
	<td class="r60">&nbsp;</td>
	<td class="r60"><input type="text" tabindex="11" name="percent" value="0" style="width: 45px; text-align:right;"> %</td>
	<td class="r60"><input type="text" tabindex="12" name="complete" value="0" class="r60"></td>
	<td class="r60">&nbsp;</td>
</tr>
</table>
</form>
<script language="javascript">
	var f = document.newCode;

	var d = f.cost_code;
	d.eName = "Phase Code";
	d.required = true;
	d.focus();
	d.select();

	d = f.phase;
	d.required = true;
	d.eName = "Phase";

	d = f.description;
	d.required = true;
	d.eName = "Description";

	d = f.phase;
	d.required = true;
	d.eName = "Type";

	d = f.estimate;
	d.eName = "Estimate";
	d.isFloat = true;

	d = f.budget;
	d.eName = "Budget";
	d.isFloat = true;

	d = f.percent;
	d.eName = "Percent Complete";
	d.isFloat = true;

	d = f.complete;
	d.eName = "$ To Finish";
	d.isFloat = true;
	
<%
query = "select * from cost_types where site_id = " + attr.getSiteId() + " order by letter";
rs = db.dbQuery(query);
if (rs.first()) {
%>
	var typesList = [ new Type("<%= rs.getString("letter") %>", "<%= rs.getString("description") %>") ];
<%
}
while (rs.next()) {
%>
	typesList[typesList.length] = new Type("<%= rs.getString("letter") %>", "<%= rs.getString("description") %>");
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</script>
</body>
</html>
