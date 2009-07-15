<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.text.DecimalFormat, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String id = request.getParameter("id");
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/style.css">
	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript">
		function hide() {
			parent.document.getElementById("fs").rows = "41,0,*,16";
			parent.edit.document.location = "blank.html";
		}
		function save(next) {
			if(!next) f.command.value = "b";
			else f.command.value = "n";
			saveNormal();
		}
		function saveNormal() {
			if (checkForm(f)) {
				f.action = "processEditCode.jsp";
				f.submit();
				return true;
			} else return false;
		}
		function updatePerform() {
			var budget = com(editCode.budget.value) - 0;
			document.getElementById("perform").innerHTML = Math.round(budget + co - ctd - com(editCode.complete.value));
		}
		function del() {
			if(confirm("Delete this phase code?")) {
				f.action = "deletePhase.jsp?id=<%= id %>";
				f.submit();
				return true;
			} else return false;
		}
		function lock(lock) {
			if (lock && confirm("Lock budget and estimate?")) window.location = "lock.jsp?id=<%= id %>";
			else if (!lock && confirm("Unlock budget and estimate?")) window.location = "lock.jsp?id=<%= id %>&unlock=t";
			return false;
		}
		function com(val) {
			for (var i = 0; i < val.length; i++) {
				var c = val.charAt(i);
				if (c == ",") val = val.substring(0,i) + val.substring(i+1);
			}
			return val;
		}
		function calc() {
			var budget = com(editCode.budget.value) - 0;
			f.complete.value = Math.round(budget + co + coInt - ctd);
			updatePerform();
			if (budget + co != 0) f.percent.value = Math.round((ctd/(budget + co))*100);
			else f.percent.value = 0;
			if (f.percent.value-0 > 200) f.percent.value = 100;
			return false;
		}
	</script>
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
			cursor: pointer;
		}
	</style>
</head>
<body>
<form name="editCode" method="POST">
<table cellspacing="0" cellpadding="0" style="background-color: #E1DED9;">
<%
String query = "select amount from changes where cost_code_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
float co = 0, coInt = 0;
if (rs.first()) {
	co = rs.getFloat(1);
}
rs.close();
rs = null;
query = "select sum(amount) from change_request_detail where authorization = 1 and "
	+ "cost_code_id = "	+ id;
rs = db.dbQuery(query);
if (rs.first()) {
	coInt = rs.getFloat(1);
}
rs.close();
rs = null;
query = "select division, cost_code, phase_code, locked, code_description, estimate, contracts.amount, budget, pm_cost_to_date, cost_to_complete, comment, "
	+ "percent_complete from job_cost_detail left join contracts on job_cost_detail.cost_code_id = contracts.cost_code_id where "
	+ "job_cost_detail.cost_code_id = " + id;
rs = db.dbQuery(query);
float ctd = 0;
if (rs.first()) {
DecimalFormat df = new DecimalFormat("#,###");
float budget = rs.getFloat("budget");
ctd = rs.getFloat("pm_cost_to_date");
String comment = rs.getString("comment");
if (comment == null) comment = "";
%>
<tr>
	<td colspan="4"><b>Comment</b> <input type="text" style="width: 190px;" name="comment" value="<%= comment %>"></td>
	<td class="r60"><b>CA</b></td>
	<td class="r60"><%= df.format(coInt) %></td>
	<td colspan="5" style="text-align: right;">
<%
if (rs.getBoolean("locked")) out.println("<input type=\"hidden\" name=\"locked\" value=\"t\">");
if (rs.getBoolean("locked") && sec.ok(Security.UNLOCK_BUDGET, Security.WRITE)) 
	out.print("<button accesskey=\"u\" tabindex=\"8\" accesskey=\"l\" onClick=\"return lock(false);\">Un<u>l</u>ock</button>");
else if (!rs.getBoolean("locked")) out.print("<button accesskey=\"l\" tabindex=\"8\" accesskey=\"l\" onClick=\"return lock(true);\"><u>L</u>ock</button>");
query = "select cost_code_id from job_cost_detail where ((cost_code = '" 
	+ rs.getString("cost_code") + "' and phase_code > '" + rs.getString("phase_code") + "' and division = '" 
	+ rs.getString("division") + "'" + ") or (division = '" + rs.getString("division") + "' and costorder(cost_code) "
	+ "> costorder('" + rs.getString("cost_code") + "')) " + "or (costorder(division) > costorder('" 
	+ rs.getString("division") + "'))) and job_id = " + attr.getJobId() + " order by costorder(division), "
	+ "costorder(cost_code), phase_code limit 1";
ResultSet next = db.dbQuery(query);
if (next.first()) {
%>
		&nbsp; <button accesskey="n" tabindex="9" onClick="return save(true);"><u>N</u>ext</button>
<%
}
next.getStatement().close();
query = "select cost_code_id from job_cost_detail where ((cost_code = '" 
	+ rs.getString("cost_code") + "' and phase_code < '" + rs.getString("phase_code") + "' and division = '" 
	+ rs.getString("division") + "'" + ") or (division = '" + rs.getString("division") + "' and costorder(cost_code) "
	+ "< costorder('" + rs.getString("cost_code") + "')) " + "or (costorder(division) < costorder('" 
	+ rs.getString("division") + "'))) and job_id = " + attr.getJobId() + " order by costorder(division) desc, "
	+ "costorder(cost_code) desc, phase_code limit 1";
next = db.dbQuery(query);
if (next.first()) {
%>
		&nbsp; <button accesskey="b" tabindex="10" onClick="return save(false);"><u>B</u>ack</button>
<%
}
next.getStatement().close();
next = null;
%>
		&nbsp; <button accesskey="s" tabindex="11" onClick="return saveNormal();"><u>S</u>ave</button>
		&nbsp; <button accesskey="a" tabindex="12" onClick="return calc();">C<u>a</u>lculate</button>
<%
if (sec.ok(Security.ACCOUNT, Security.DELETE)) {
%>
		&nbsp; <button accesskey="d" tabindex="13" onClick="return del();"><u>D</u>elete</button>
<%
}
%>
		&nbsp; <button onClick="hide();" tabindex="14" accesskey="c"><u>C</u>lose</button>
		</td>
</tr>
<tr>
	<td class="r35"><input type="hidden" name="id" value="<%= id %>" tabindex="1"><%= rs.getString("cost_code") %>
		<input type="hidden" name="command">
		</td>
	<td class="l130"><input type="text" tabindex="2" value="<%= rs.getString("code_description") %>" name="description" style="width: 127px; padding-left: 2px;"></td>
	<td style="padding-left: 1px; padding-right: 1px; width: 11px; text-align: center;"><%= rs.getString("phase_code") %></td>
	<td class="r60"><input type="text" tabindex="3" name="estimate" value="<%= df.format(rs.getFloat("estimate")) %>" 
		class="r60" <%= FormHelper.dis(rs.getBoolean("locked")) %>></td>
	<td class="r60"><%= df.format(rs.getFloat("amount")) %></td>
	<td class="r60"><input type="text" tabindex="4" name="budget" value="<%= df.format(budget) %>" class="r60"
		<%= FormHelper.dis(rs.getBoolean("locked")) %>></td>
	<td class="r60"><%= df.format(co) %></td>
	<td class="r60"><%= df.format(ctd) %></td>
	<td class="r60"><input type="text" tabindex="5" name="percent" value="<%= df.format(rs.getFloat("percent_complete")) %>" style="width: 45px; text-align:right;"> %</td>
	<td class="r60">
		<input type="text" name="complete" tabindex="6" value="<%= df.format(rs.getFloat("cost_to_complete")) %>" class="r60" onChange="updatePerform();"></td>
	<td class="r60" id="perform">&nbsp;</td>
</tr>
</table>
</form>
<%
}
rs.close();
rs = null;
db.disconnect();
%>
<script language="javascript">
	var f = document.editCode;

	var co = <%= co %>;
	var coInt = <%= coInt %>;
	var ctd = <%= ctd %>;

	updatePerform();

	d = f.description;
	d.required = true;
	d.eName = "Description";
	
	d = f.estimate;
	d.isFloat = true;
	d.eName = "Estimate";
	
	d = f.budget;
	d.isFloat = true;
	d.eName ="Budget";

	d = f.percent;
	d.eName = "Percent Complete";
	d.isFloat = true;

	d = f.complete;
	d.focus();
	d.select();
	d.eName = "$ To Finish";
	d.isFloat = true;
</script>
</body>
</html>
