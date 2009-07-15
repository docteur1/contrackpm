<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.text.DecimalFormat, java.util.Calendar" %>
<%@page import="com.sinkluge.security.Security, java.lang.Runtime" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)){
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" >
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
	<div class="title">Contrack Administration</div><hr>
		<a href="indexService.jsp">Cache and Index Service</a>
		&nbsp;&nbsp;<a href="costTypes.jsp?site_id=1">Cost Types</a>
		&nbsp;&nbsp;<a href="reviewDivisions.jsp?site_id=1">Divisions</a>
		&nbsp;&nbsp;<a href="errors.jsp">Errors</a>
		&nbsp;&nbsp;<a href="externalSessions.jsp">External Sessions</a>
<%
if (in.hasFax) out.println("&nbsp;&nbsp;<a href=\"../utils/faxLog.jsp?admin=true\">Fax Log</a>");
%>
	&nbsp;&nbsp;<a href="permissions.jsp">Groups</a>
	&nbsp;&nbsp;<a href="updateGlobalInfo.jsp">Global Settings</a>
<%
if (in.hasKF) out.println("&nbsp;&nbsp;<a href=\"updateKFsettings.jsp\">KlickFileWeb Integration</a>");
%>
		<hr>
		<a href="lists.jsp">Lists</a>
		&nbsp;&nbsp;<a href="jobDefaults.jsp">Job Defaults</a>
		&nbsp;&nbsp;<a href="codes/genericCodes.jsp?site_id=1">Phase Codes</a>
		&nbsp;&nbsp;<a href="reports.jsp?id=prMonth">Reports</a>
		&nbsp;&nbsp;<a href="sessions.jsp">Sessions</a>
		&nbsp;&nbsp;<a href="updateInfo.jsp">Site Settings</a>
		&nbsp;&nbsp;<a href="sites.jsp">Sites</a>
		&nbsp;&nbsp;<a href="uploadLogo.jsp">Upload Logo</a>
<%
com.sinkluge.UserData ud= com.sinkluge.UserData.getInstance(in, attr.getUserId());
if(ud.getWebConfigJspName() != null) {
%>
		&nbsp;&nbsp;<a href="<%= ud.getWebConfigJspName() %>">Users</a>
<%
}
%>
		<hr>
<%
Runtime run = Runtime.getRuntime();
DecimalFormat df = new DecimalFormat("#,##0");
long runTime = System.currentTimeMillis() - in.startTime;
final long MILLIS_PER_HOUR = 3600000;
final long MILLIS_PER_DAY = MILLIS_PER_HOUR * 24;
long days = runTime / MILLIS_PER_DAY;
long hours = (runTime % MILLIS_PER_DAY) / MILLIS_PER_HOUR;
long mins = ((runTime % MILLIS_PER_DAY) % MILLIS_PER_HOUR) / 60000;
long secs = (((runTime % MILLIS_PER_DAY) % MILLIS_PER_HOUR) % 60000) / 1000;
%>
<span class="bold">Free Memory:</span> <%= df.format(run.freeMemory()) %> KB <br>
<span class="bold">Total Memory:</span> <%= df.format(run.totalMemory()) %> KB <br>
<span class="bold">Max Memory:</span> <%= df.format(run.maxMemory()) %> KB <br>
<% df.applyPattern("00"); %>
<div style="margin-top: 10px;"><span class="bold">Uptime:</span> <%= days %>
	days <%= hours %>:<%= df.format(mins) %>:<%= df.format(secs) %></div>
</body>
</html>
