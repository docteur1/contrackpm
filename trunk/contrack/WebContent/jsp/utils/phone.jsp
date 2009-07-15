<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.sinkluge.utilities.Widgets" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="JSONRPCBridge" scope="session"
     class="org.jabsorb.JSONRPCBridge" />
<%
JSONRPCBridge.registerClass("home", com.sinkluge.JSON.Home.class); 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="verify.js"></script>
	<script src="jsonrpc.js"></script>
</head>
<body>
<div class="title">Dialer</div><hr/>
<form id="mainForm">
<%= request.getParameter("clid") != null ? "<input type=\"hidden\" id=\"clid\" value=\""
	+ request.getParameter("clid") + "\"/>" : "" %>
<table>
<tr>
<td class="lbl">Dial</td>
<td><input type="text" name="number" value="<%= request.getParameter("phone") %>"/></td>
</tr>
<tr>
<td class="lbl">On Extension</td>
<td>
<%
Cookie[] cookies = request.getCookies();
String ext = null;
for (Cookie cookie : cookies) {
	if ("userext".equals(cookie.getName())) ext = cookie.getValue();
}
out.print(Widgets.extList(ext, "extlist", "extlist", in));
%>
</td>
</tr>
<tr id="statusRow">
<td class="lbl">Status</td>
<td id="statusCell">&nbsp;</td>
</tr>
<tr>
<td class="lbl">Show Log</td>
<td><input type="checkbox" name="showlog" value="y"/></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="button" onclick="dial();" id="dialButton" value="Dial"/>
<input type="button" onclick="hangup();" id="hangupButton" disabled="disabled" value="Hangup"/>
<input type="button" onclick="parent.closeInlineWindow();" value="Close"/></td>
</table>
</form>
<pre id="log"></pre>
<script>
	var mf = document.getElementById("mainForm");
	var n = mf.number;
	n.eName = "Phone";
	n.required = true;
	n.isPhone = true;
	n = mf.extlist;
	n.onchange = function () {
		var sb = document.getElementById("extlist");
		// Save the value as a cookie (workstation specific
		document.cookie = "userext=" + escape(sb.value) + "; path=<%= request.getContextPath() %>" + 
			"; expires=Fri, 31 Dec 2099 23:59:59 GMT;";	
	};
	var jsonrpc = new JSONRpcClient("../JSON-RPC");
	function dial() {
		if (checkForm(mf)) {
			var clid = document.getElementById("clid");
			jsonrpc.home.dialNumber(dialCB, mf.number.value, mf.extlist.value, 
				clid ? clid.value : null);
			document.getElementById("statusCell").innerHTML = "Ringing selected extension";
			document.getElementById("dialButton").disabled = true;
		}
	}
	function dialCB(result, e) {
		if (e) {
			document.getElementById("log").innerHTML = "ERROR!<br/>Message: " + e.message 
				+ "<br/>Name: " + e.name + "<br/>Code: "
				+ e.code + (e.javaStack != null ? "<br/>Stack: " + e.javaStack : "");
		} else {
			document.getElementById("hangupButton").disabled = false;
			poll();
		}
	}
	function poll() {
		jsonrpc.home.getDialStatus(pollCB);
	}
	function pollCB(result, e) {
		if (mf.showlog.checked) {
			document.getElementById("log").innerHTML = result.log;
		}
		document.getElementById("statusCell").innerHTML = result.status;
	
		if (!result.terminated) window.setTimeout(poll, 500);
		else {
			document.getElementById("dialButton").disabled = false;
			document.getElementById("hangupButton").disabled = true;
		}
	}
	function hangup() {
		jsonrpc.home.hangupCall();
	}
</script>
</body>
</html>