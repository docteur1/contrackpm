<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.DecimalFormat" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
boolean sw = sec.ok(Security.ACCOUNT, Security.WRITE);
boolean slc = sec.ok(Security.LABOR_COSTS, Security.READ);
boolean scd = sec.ok(Security.COST_DATA, Security.READ);
boolean hasAcc = attr.hasAccounting();
boolean isIE = request.getHeader("user-agent").indexOf("MSIE") != -1;
%>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="stylesheets/style.css">
	<script language="javascript" src="scripts/codesMain.js"></script>
</head>
<body>
<div id="load" style="padding: 200px; position: absolute;"><b>Loading... Please Wait...</b></div>
<div id="done" style="visibility: hidden;">
<table cellspacing="0">
<%
int job_id = attr.getJobId();
Database db = new Database();
String query = "select letter from cost_types where labor = 1";
ResultSet rs = db.dbQuery(query);
String laborTypes = "";
while (rs.next()) laborTypes += rs.getString(1);
if (rs != null) rs.getStatement().close();
rs = null;
//Build the rs
query = "select jcd.cost_code_id, division, cost_code, code_description as description, "
	+ "phase_code, estimate, budget, cost_to_complete, percent_complete, "
	+ "pm_cost_to_date, sum(c.amount) as c_amount, count(c.contract_id) as c_num, "
	+ "sum(cr.amount) as cr_amount, num from job_cost_detail as jcd "
	+ "left join contracts as c on jcd.cost_code_id = c.cost_code_id left join "
	+ "changes as cr on cr.cost_code_id = jcd.cost_code_id where jcd.job_id = " + job_id;
// What division if any are we looking at
String divS = request.getParameter("div");
String div_query = "select division, description from job_divisions where job_id = " + job_id;
attr.setDiv(divS);
if (divS != null) {
	query += " and division = '" + divS + "'";
	div_query += " and division = '" + divS + "'";
} else {
	div_query += " order by costorder(division)";
}
query += " group by cost_code_id order by costorder(division), costorder(jcd.cost_code), jcd.phase_code";
rs = db.dbQuery(query);
ResultSet div = db.dbQuery(div_query);

// Stuff we need to do this.
// {estimate, contract, budget, co, contigency, pm_cost_to_date, pm_hours_to_date, cost_to_complete}
final int ESTIMATE = 0;
final int CONTRACT = 1;
final int BUDGET = 2;
final int CR = 3;
final int CTD = 5;
final int CTC = 6;

float[] total = {0,0,0,0,0,0,0};

int c_num;
String cost_code, phase;
long cost_code_id;

float[] val = {0,0,0,0,0,0,0};

divS = "";
String newDiv, oldDiv = null;

DecimalFormat df = new DecimalFormat("#,###");

while (rs.next()) {
	cost_code = rs.getString("cost_code");
	//What division are we in?
	newDiv = rs.getString("division");
	//First run set old_div to new_div;
	if (oldDiv == null) oldDiv = newDiv;
	// When these aren't equal we've hit the end of a division but we don't care if we are not showing all records
	if (!newDiv.equals(oldDiv)) {
		// Does the division exist?
		while (div.next()) {
			divS = div.getString("division");
			// Again check to see if we are in the same division
			if (oldDiv.equals(divS)) {
				// end of the division spit out info and totals
%>
	<tr class="yellow">
		<td colspan="3" align="right"><b><%= divS + " " + div.getString("description") %></b></td>
		<td class="rg60"><%= df.format(total[ESTIMATE]) %></td>
		<td class="r60"><%= df.format(total[CONTRACT]) %></td>
		<td class="rg60"><%= df.format(total[BUDGET]) %></td>
		<td class="r60"><%= df.format(total[CR]) %></td>
		<td class="rg60"><%= df.format(total[CTD]) %></td>
		<td class="r60">&nbsp;</td>
		<td class="rg60"><%= df.format(total[CTC]) %></td>
		<td class="r60"><%= df.format(total[BUDGET] + total[CR]- total[CTD] - 
				total[CTC]) %></td>
	</tr>
<%
				//zero out the running totals;
				for(int i = 0; i < 7; i++) total[i] = 0;
				break;
			} else continue;// (old_div == division)
		} // end while (div.next())
		//Update old_div so we can trap next go around.
		oldDiv = newDiv;
	} // end if (new_div != old_div & all)

	//Let's get down to the business of spitting out the row

	val[ESTIMATE] = rs.getFloat("estimate");
	val[CONTRACT] = rs.getFloat("c_amount");
	val[BUDGET] = rs.getFloat("budget");
	val[CR] = rs.getFloat("cr_amount");
	val[CTD] = rs.getFloat("pm_cost_to_date");
	val[CTC] = rs.getFloat("cost_to_complete");
	phase = rs.getString("phase_code");
	cost_code_id = rs.getLong("cost_code_id");
	c_num = rs.getInt("c_num");
%>
	<tr onMouseOver="rC(this);"; onMouseOut="rCl(this)";>
		<td class="r35"><%= cost_code %></td>
		<td class="l130">
<%
	if (sw) {
%> 
			<a name="<%= cost_code_id %>" href="javascript: editCode(<%= cost_code_id %>);">
			<div class="clip" title="<%= rs.getString("description") %>"></div></a>
<%
	} else {
%>
			<a name="<%= cost_code_id %>"></a><div class="clip" title="<%= rs.getString("description") %>"></div>
<%		
	}
%>
			</td>
		<td class="r13"><%= phase %></td>
		<td class="rg60"><%= df.format(val[ESTIMATE]) %></td>
		<td class="r60">
<%
	if (c_num != 0) {
%>
			<a href="javascript: openWin(con_url + '<%= cost_code_id %>',700,400);"><%= df.format(val[CONTRACT]) %></a>
<%
	} else {
%>
			&nbsp;
<%
	}
%>
			</td>
		<td class="rg60"><%= df.format(val[BUDGET]) %></td>
<%
	if (rs.getInt("num") != 0) {
%>
		<td class="r60"><a href="javascript: openWin(co_url + '<%= cost_code_id 
			%>',700,400);"><%= df.format(val[CR]) %></a></td>
<%
	} else {
%>
		<td class="r60">&nbsp;</td>
<%
	}
%>
		<td class="rg60">
<%
	if (hasAcc & ((scd && !attr.isLabor(phase)) || (slc && attr.isLabor(phase)))) 
		out.print("<a href=\"javascript: openWin(del_url + '"
			+ cost_code_id + "',830,400);\" oncontextmenu=\"openWin(v_url + '"
			+ cost_code_id + "',830,400);\">" + df.format(val[CTD]) + "</a>");
	else out.print(df.format(val[CTD]));
%>	
		</td>
		<td class="r60"><%= df.format(rs.getFloat("percent_complete")) %>%</td>
		<td class="rg60"><%= df.format(val[CTC]) %></td>
		<td class="r60"><%= df.format(val[BUDGET] + val[CR] - val[CTD] - val[CTC]) %></td>
	</tr>
<%
	// Now add in the totals;
	for (int i = 0; i < 7; i++) total[i] += val[i];
} // rs.next();

//Are there still divisions left (there should be unless they are using phases higher than whats in the divisions table
while (div.next()) {
	divS = div.getString("division");
	if (divS.equals(oldDiv) || oldDiv == null) {
%>
	<tr class="yellow">
		<td colspan="3" align="right" style="width: <%= isIE?"190":"180" %>px;"><b><%= divS + " " + div.getString("description") %></b></td>
		<td class="rg60"><%= df.format(total[ESTIMATE]) %></td>
		<td class="r60"><%= df.format(total[CONTRACT]) %></td>
		<td class="rg60"><%= df.format(total[BUDGET]) %></td>
		<td class="r60"><%= df.format(total[CR]) %></td>
		<td class="r60"><%= df.format(total[CTD]) %></td>
		<td class="rg60">&nbsp;</td>
		<td class="r60"><%= df.format(total[CTC]) %></td>
		<td class="rg60"><%= df.format(total[BUDGET] + total[CR] - total[CTD] - total[CTC]) %></td>
	</tr>
<%
	}
} //(div.next())

if (rs != null) rs.close();
rs = null;
if (div != null) div.close();
div = null;
%>
</table>
</div>
<script>
	var divs = document.getElementsByTagName("div");
	for (var i = 0; i < divs.length; i++) {
		if (divs[i].className == "clip") divs[i].innerHTML = divs[i].title;
	}
	document.getElementById("load").style.visibility = "hidden";
	document.getElementById("done").style.visibility = "visible";
<%
if (request.getParameter("id") != null) {
%>
	if (navigator.userAgent.indexOf("MSIE") != -1) document.location.hash = "<%= request.getParameter("id") %>";
	else document.location.href = "codesMain.jsp?<%= request.getQueryString() %>#<%= request.getParameter("id") %>";
<%
}
%>
</script>
</body>
<%
// Clean up mysql memory
db.disconnect();
%>
