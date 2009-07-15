<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.security.Security"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.RFI, Security.PRINT)) response.sendRedirect("../accessDenied.html");
SimpleDateFormat formatter = new SimpleDateFormat("MMMM d, yyyy");
%>
<html>
	<head>
		<title>RFI Summary</title>
		<link rel="stylesheet" href="../stylesheets/print.css" type="text/css">
	</head>
	<body>
		<div class="title"><%= attr.getJobNum()+ " - " + attr.getJobName() %> RFI Summary</div>
		<div><%= formatter.format(new java.util.Date())%></div><hr>
			<%
		String query = "select rfi.*, company_name, name from rfi join company on company.company_id = rfi.company_id "
			+ "left join contacts using(contact_id) where job_id = " + attr.getJobId() + " order by "
			+ "company_name, costorder(rfi_num) asc";
			Database db = new Database();
		ResultSet rs = db.dbQuery(query);
		String rfiID;
		String dateCheck="";
		int count=0;
		String req = "";
		String reply = "";
		%>
		<table cellpadding="2" cellspacing="0">
			<thead>
			<tr>
				<td class="head left">RFI</td>
				<td class="head">Company</td>
				<td class="head">Attn</td>
				<td class="head aright">Date Sent</td>
				<td class="head aright">Date Rec'd</td> <!-- ' -->
				<td class="head">Request</td>
				<td class="head">Reply</td>
				<td class="head right">ID</td>
			</tr>
			</thead>
			<tbody>
			<%
			formatter.applyPattern("MMM d, yyyy");
			String attn;
			while (rs.next()){
				count++;
				attn = rs.getString("name");
				if (attn == null) attn = "&nbsp;";
				dateCheck = rs.getString("date_received");
				dateCheck = dateCheck==null?"0000-00-00":"date";
				if (dateCheck.equals("0000-00-00")) dateCheck = "NR";
				else if (rs.getDate("date_received") == null) dateCheck = "&nbsp;";
				else dateCheck = formatter.format(rs.getDate("date_received"));
				rfiID=rs.getString("rfi_num");
				req = rs.getString("rfi.request");
				req = req==null || req.equals("")?"&nbsp;":req;
				reply = rs.getString("rfi.reply");
				reply = reply==null || reply.equals("")?"&nbsp;":reply;
			%>
			<tr>
				<td ><%= rfiID %></td>
				<td><%= rs.getString("company_name") %></td>
				<td><%= attn %></td>
				<td class="aright"><%= formatter.format(rs.getDate("date_created")) %></td>
				<td class="aright"><%= dateCheck %></td>
				<td><%= req %></td>
				<td><%= reply %></td>
				<td>RF<%= rs.getString("rfi_id") %></td>
			</tr>
			<%
			}
			rs.close();
			db.disconnect();
			%>
			</tbody>
		</table>
	</body>
</html>
