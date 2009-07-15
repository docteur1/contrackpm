<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.sinkluge.CacheAndIndexService,
    com.sinkluge.Scheduler" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" >
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<div class="title">Cache and Index Service</div><hr/>
<div class="link" onclick="window.location='superAdmin.jsp';">Administration</div>
&gt; Cache and Index Service<hr/>
<%
if (request.getParameter("start") == null) {
%>
<input type="button" value="Run Manually" 
	onclick="window.location='indexService.jsp?start=true';"/>
<%
} else {
	Scheduler scheduler = (Scheduler) application.getAttribute("scheduler");
	CacheAndIndexService cais = (CacheAndIndexService) session.getAttribute("cais");
	if (cais == null) {
		cais = new CacheAndIndexService(application);
		scheduler.stopIndexService();
		new Thread(cais).start();
		session.setAttribute("cais", cais);
	}
%>
<div><span class="bold">Status:</span> <%= cais.isRunning() ? "Running" : "Finished" %></div>
<pre>------------------------------------------------
Begin manual index session
Stopping indexing service...
Index service stopped
Launching new thread
<%= cais.getLog() %>
------------------------------------------------</pre>
<%
	if (cais.isRunning()) {
%>
<div class="bold">Window will refesh automatically every 3 seconds.</div>
<script>
window.setTimeout(function () { window.location.reload(); }, 3000);
</script>
<%
	} else {
		session.removeAttribute("cais");
		cais = null;
		scheduler.startIndexService();
%>
<div class="bold">Index Service Restarted</div>
<%
	}
}
%>
</body>
</html>