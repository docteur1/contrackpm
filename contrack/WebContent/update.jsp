<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.sinkluge.database.Database" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%@ page import="com.sinkluge.updates.*" %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Contrack Update Monitor (<%= in.build %>)</title>
</head>
<body>
<%
Updater updater = (Updater) application.getAttribute("updater");
if (updater == null) {
	response.sendRedirect("jsp/");
	return;
} else if (Status.NO_UPDATES.equals(updater.getStatus())) {
	application.removeAttribute("updater");
	response.sendRedirect("jsp/");
	return;
} else {
	Status status = updater.getStatus();
%>
<pre id="msg">UPDATING CONTRACK -- PLEASE WAIT
---------------------------------------------------
STATUS: <%= status.name() %>
---------------------------------------------------
<%= status.getMessage() %>
---------------------------------------------------</pre>
<%
	if (status.equals(Status.PROCESSING) ) {
%>
Window will refresh automatically
<script>
	window.setTimeout(function () { window.location.reload(); }, 5000);
</script>
<%
	} else if (status.equals(Status.COMPLETE)) {
		application.removeAttribute("updater");
		in.loadProperties();
		if (in.testMode) {
%>
<script>
	window.setTimeout(function () { window.location = "index.jsp"; }, 2500);
</script>
<%
		}
%>
Update Complete! <a href="jsp/">Sign On</a>
<%
	}
}
%>
</body>
</html>