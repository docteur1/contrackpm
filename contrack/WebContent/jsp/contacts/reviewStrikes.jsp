<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%! String cS(String strike) {
			if(strike == null) strike = "n";
			return strike;
		}
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script src="../utils/table.js"></script>
</head>
<body>
	<div class="title">Strike Report</div><hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
	<td class="left head nosort">Edit</td>
	<td class="head nosort">Contracts</td>
	<td class="head nosort">Strikes</td>
	<td class="head">Company Name</td>
	<td class="right head"># of Strikes</td>
</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
Database db = new Database();
String query = "select count(*), company_name, c.company_id from company as c left join company_comments as cc "
	+ "using(company_id) where cc.strike = 1 group by c.company_id order by count(*) desc, company_name";
ResultSet rs = db.dbQuery(query);
int company_id, strikes;
boolean color = true;
String strike, font="black";
while (rs.next()){
		color = !color;
		company_id = rs.getInt("company_id");
		strikes = rs.getInt("count(*)");

%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left"><a href="modifyCompany.jsp?id=<%=company_id%>">Edit</a></td>
	<td class="it"><a href="reviewCompanyContracts.jsp?id=<%=company_id%>">Contracts</a></td>
	<td class="right"><a href="modifyCompanyComments.jsp?id=<%=company_id%>">Strikes</a></td>
	<td class="it"><%=rs.getString("company_name") %></td>
	<td class="right"><%=strikes%></td>
</tr>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
</div>
</body>
</html>
