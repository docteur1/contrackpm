<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.FormHelper"%>
<%@page import="java.util.Iterator" %>
<%@page import="com.sinkluge.list.List.Contract, com.sinkluge.list.List.JobInfo" %>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:useBean id="list" scope="session" class="com.sinkluge.list.List" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
String param = request.getParameter("saveDisable");
boolean saveDisable = param != null && param.equals("true");
param = request.getParameter("printDisable");
boolean printDisable = param != null && param.equals("true");
param = request.getParameter("contractDisable");
boolean contractDisable = param != null && param.equals("true");
param = request.getParameter("myInfoDisable");
boolean myInfoDisable = param != null && param.equals("true");
String method = request.getParameter("method");
if (method == null) method = "GET";
%>
<html>
<head>
	<title>Contrack - <%= db.get("short_name") %></title>
	<link rel="SHORTCUT ICON" href="../../ct64.ico">
   <link rel="stylesheet" type="text/css" href="../stylesheets/style.css">
   <script language="javascript" src="../scripts/verify.js"></script>
   <script language="javascript" src="../scripts/contrack.js"></script>
<%
if (db.email == null) {
%>
	<script>
		window.location = "<%= request.getContextPath() %>/jsp/init.jsp";
	</script>
<%	
}
if (in.live_support_url != null) {
%>
<script language="JavaScript" type="text/javascript" src="<%= in.live_support_url %>jivelive.jsp"></script>
<%
}
%>
   <style>
   		body, td, a, select, input, textarea  {
   			font-size: <%= db.font_size %>pt;
   		}
   	</style>
</head>
<body>
<table style="width: 100%; height: 100%" cellspacing="0" border="1">
<tr>
<td style="border-bottom-style: solid; border-bottom-width: 2; border-color: black; background-color: #C0C0C0; width: 100%; padding: 0;">
<table style="width: 100%">
	<tr>
<%
if (!contractDisable) {
%>
		<form name="packet" action="../manage/setCompany.jsp" method="post">
<%
}
%>
		<input type="hidden" name="requesting_path" value="<%= request.getServletPath() + "?" + request.getQueryString() %>">
		<td><select name="company_id" onChange="this.form.submit();" <%= FormHelper.dis(contractDisable) %>>
<%
String query = "select distinct company_id, company_name from contacts left join company using(company_id) where email = '" 
	+ db.email + "' order by company_name";
db.connect();
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
int company_id;
if (!rs.isBeforeFirst()) out.print("<option>ERROR!</option>");
while (rs.next()) {
	company_id = rs.getInt(1);
	out.println("<option value=\"" + company_id + "\" " + FormHelper.sel(company_id, db.company_id) + ">" + rs.getString(2)
		+ "</option>");
}
if (rs != null) rs.close();
rs = null;
%>		
		</select></td>
		</form>
		<form name="packet" action="../manage/setContract.jsp" method="post">
		<input type="hidden" name="requesting_path" value="<%= request.getServletPath() + "?" + request.getQueryString() %>">
		<td><select name="id" onChange="this.form.submit();" <%= FormHelper.dis(contractDisable) %>>
<%
if (list.isEmpty()) out.print("<option>No projects found!</option>");
JobInfo ji;
Contract c;
for (Iterator<JobInfo> e = list.getJobs(); e.hasNext(); ) {
	ji = e.next();
	if (ji.hasContracts()) {
		for (Iterator<Contract> i = ji.getContractIterator(); i.hasNext(); ) {
			c = i.next();
			out.println("<option value=\"c" + c.getContactId() + "\" " + FormHelper.sel(db.contract_id, c.getContactId()) 
				+ ">" + ji.getJobName() + ": " + c.getCodeDescription() + "</option>");
		}
	} else out.println("<option value=\"j" + ji.getJobId() + "\" " + FormHelper.sel(db.job_id, ji.getJobId()) 
			+ ">" + ji.getJobName() + "</option>");
}
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.disconnect();
%>
			</select></td>
		<td style="background-color: black; width: 3px;"></td></form>
		<form name="main" action="<%= request.getParameter("action") %>" method="<%= method %>">
		<td style="padding-left: 5px;"><button accesskey="s" id="sBt" name="save" onClick="return submitForm();" <%= FormHelper.dis(saveDisable) %>><u>S</u>ave</button></td>
		<td style="padding-left: 5px;"><button id="pBt" name="print" accesskey="p" onClick="printDoc(); return false;" <%= FormHelper.dis(printDisable) %>><u>P</u>rint</button></td>
		<td style="padding-left: 10px; width: 100%"><div id="message" style="color: red; font-weight: bold;"><%= db.msg %></div></td>
<%
// Reset db.msg now it has been displayed
db.msg = "";
%>
		<td nowrap><b>User: </b><%= db.contact_name %></td>
<%
if (in.live_support_url != null) {
%>
		<td style="padding-left: 10px;"><input type="button" value="Help" 
		onclick="launchWin('framemain','<%= in.live_support_url %>start.jsp?workgroup=<%=
		in.live_support_workgroup %>&location=' + window.location.href + '&noUI=true&username=<%= 
			response.encodeURL(db.contact_name + " (" + db.company_name + ")") %>&email=<%= db.email %>',500, 400);"></td>
<%
}
%>
		<td style="padding-left: 10px;"><input type="button" value="My Info" onClick="location='../user/index.jsp';" <%= FormHelper.dis(myInfoDisable) %>></td>
		<td style="padding-left: 10px;"><input type="button" value="Logout" onClick="location='../../index.jsp?logoff=true';"></td>
	</tr>
</table>
</td>
</tr>
<tr style="height: 100%;">
<td width="100%" style="padding: 10px; vertical-align: top;">