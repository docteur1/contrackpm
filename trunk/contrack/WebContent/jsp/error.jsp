<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.Enumeration, org.apache.log4j.Logger" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session"
     class="org.jabsorb.JSONRPCBridge" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
JSONRPCBridge.registerClass("home", com.sinkluge.JSON.Home.class); 
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/jsp/stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<title>Contrack - Error Page</title>
	<script src="<%= request.getContextPath() %>/jsp/utils/jsonrpc.js"></script>
	<script>
		var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
	</script>
</head>
<body>
<div style="font-size: 200%; color: red; font-weight: bold;">ERROR</div><hr>
<%
if (!in.testMode) {
%>
<div>Contrack encountered an error. Please provide some information as to how 
this error occurred (what task were you trying to perform, etc). You may also try your request again
by clicking <div class="link bold" onclick="history.back();">here</div>. If you repeatedly encounter this error,
please submit it to the <div class="link bold" 
onclick="window.open('https://www.e-p.com/mantisbt/bug_report_page.php');">Bug Tracker</div>.
</div>
<table>
<tr>
	<td class="bold">Comments</td>
</tr>
<tr>
	<td><textarea id="comments" name="comments" cols="60" rows="5"></textarea></td>
</tr>
<tr>
	<td><input type="button" onclick="submitError();" value="Submit"></td>
</tr>
</table>
<hr>
<%
}
String log = "<br>User:  " + attr.getUserName();
log += "<br>Time:  " + new java.util.Date();
log += "<br>URI:  " + request.getAttribute("javax.servlet.error.request_uri");
log += "<br>Servlet:  " + request.getAttribute("javax.servlet.error.servlet_name");
log += "<br>Platform:  " + request.getHeader("user-agent");
log += "<br>Method:  " + request.getMethod();
log += "<br>Job ID:  " + attr.getJobId();
log += "<br>Job #:  " + attr.getJobNum();
Runtime run = Runtime.getRuntime();
log += "<br>Free Memory: " + run.freeMemory();
log += "<br>Total Memory: " + run.totalMemory();
log += "<br>Max Memory: " + run.maxMemory();
log += "<br>Parameters:";
String pn;
for (Enumeration params = request.getParameterNames(); params.hasMoreElements(); ) {
	pn = (String) params.nextElement();
	log += "<br> &nbsp; &nbsp;" + pn + ":  " + request.getParameter(pn);
}
Throwable e = (Throwable)request.getAttribute("javax.servlet.error.exception");
String temp = e.getMessage();
if (temp != null) temp = temp.replaceAll("\n", "<br>");
log += "<br>Message:  " + temp;
StackTraceElement[] stack = e.getStackTrace();
for (int n = 0; n < stack.length; n++) {
	log += "<br> &nbsp; &nbsp;" + stack[n].toString();
}
if (e instanceof ServletException) e = ((ServletException) e).getRootCause();
else e = e.getCause();
if (e != null) {
 	log += "<br>Root Cause:  " + e.getClass().getName();
	log += "<br>Root Message:  " + e.getMessage();
	stack = e.getStackTrace();
 	for (int n = 0; n < stack.length; n++) {
  		log += "<br> &nbsp; &nbsp;" + stack[n].toString();
	}
}
%>
<pre id="msg"><%= log %></pre>
<script>
	var msg = document.getElementById("msg");
	jsonrpc.home.setError(setErrorCallback, null, msg.innerHTML, null, false);
	var id = null;
	function setErrorCallback(result, e) {
		id = result;
	}
	function submitError() {
		 jsonrpc.home.setError(setErrorCallback2, id, msg.innerHTML, document.getElementById("comments").value);
	}
	function setErrorCallback2(result, e) {
		window.alert("Thank you for your feedback!");
		history.back();
	}
</script>
</body>
</html>