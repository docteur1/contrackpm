<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.PRINT)) response.sendRedirect("../accessDenied.html");
String query = "select division, cost_code, phase_code, code_description from job_cost_detail where job_id = " + attr.getJobId() + " order by costorder(division), costorder(cost_code), phase_code";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
SimpleDateFormat formatter = new SimpleDateFormat("MMMM d, yyyy");
%>
<html>
	<head>
		<title>Jobsite Summary of Phase Codes</title>
		<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
	</head>
	<body>
<div class="title"><%= attr.getJobNum() + ": " + attr.getJobName() %></div>
<div><%=formatter.format(new java.util.Date())%></div>
<hr>
		<table cellspacing="0">
				<thead>
				<tr>
				<td class="aright head">Div Phase-Type</td>
				<td class="head">Description</td>
				<td class="aright head">Div Phase-Type</td>
				<td class="head">Description</td>
				</tr>
				</thead>
				<tbody>
<%			while (rs.next()) { %>
			<tr>
				<td align="right"><%= rs.getString("division") + " " + rs.getString("cost_code") + " - " + rs.getString("phase_code") %></td>
				<td><%=rs.getString("code_description")%></td>
<%				if (rs.next()) { %>
				<td align="right"><%= rs.getString("division") + " " + rs.getString("cost_code") + " - " + rs.getString("phase_code") %></td>
				<td><%=rs.getString("code_description")%></td>
<%
	} else {// End second column if
%>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
<%
	}
%>
	</tr>
<%
} // End while
if (rs != null) rs.close();
rs = null;
db.disconnect();
%>
		</tbody></table>
	</body>
</html>
