<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.Iterator, com.sinkluge.utilities.FormHelper" %>
<%@ page import="com.sinkluge.attributes.Attributes" %>
<%@page import="java.text.DecimalFormat, java.util.Enumeration" %>
<jsp:useBean id="st" scope="application" class="java.util.HashMap" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(com.sinkluge.security.Name.ADMIN, com.sinkluge.security.Permission.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
String id = request.getParameter("id");
if (request.getParameter("destroy") != null) {
	Enumeration e = request.getParameterNames();
	String name;
	HttpSession us;
	String message = request.getParameter("m");
	while (e.hasMoreElements()) {
		name = (String) e.nextElement();
		if (!"destroy".equals(name)) {
			if (!"m".equals(name)) {
				us = (HttpSession) st.get(name);
				if (us != null) {
					us.setAttribute("kick", true);
					if (message != null) {
						us.setAttribute("message", message);
						us.setAttribute("reason", "Session ended by " + request.getRemoteUser()
							+ ": " + message);
					} else us.setAttribute("reason", "Session ended by " + request.getRemoteUser());
				}
			}	
		}
	}
} else if (request.getParameter("message") != null) {
	Enumeration e = request.getParameterNames();
	String name;
	HttpSession us;
	String message = request.getParameter("message");
	while (e.hasMoreElements()) {
		name = (String) e.nextElement();
		if (!"message".equals(name)) {
			us = (HttpSession) st.get(name);
			if (message != null) us.setAttribute("message", message);
		}
	}
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript">
		function destroy() {
			if (window.confirm("End selected sessions?")) {
			
				var m = window.prompt("Enter a message to the users (optional):" , "");
				var url = "sessions.jsp?destroy=t";
				var cbx = getCheckedboxes();
				for (var i = 0; i < cbx.length; i++) {
					url += "&" + cbx[i].id + "=t";
				}
				if (message != null && m != "")
					url += "&m=" + m;
				window.location = encodeURI(url);
			}
		}
		function message() {
			var m = window.prompt("Enter a message to the users:", "");
			if (m != null && m != "") {
				var url = "sessions.jsp?message=" + m;
				var cbx = getCheckedboxes();
				for (var i = 0; i < cbx.length; i++) {
					url += "&" + cbx[i].id + "=t";
				}
				window.location = encodeURI(url);
			}
		}
		function doAction(obj) {
			if (getCheckedboxes().length != 0) {
				switch (obj.value) {
				case "1":
					destroy();
					break;
				case "2":
					message();
					break;
				}
			}
			obj.selectedIndex = 0;
		}
		function getCheckboxes() {
			return document.getElementsByName("checkbox");
		}
		function getCheckedboxes() {
			var ckb = getCheckboxes();
			var ckdb = new Array();
			for (var i = 0; i < ckb.length; i++) {
				if (ckb[i].checked) ckdb.push(ckb[i]);
			}
			return ckdb;
		}
		function toggle() {
			var checkboxes = getCheckboxes();
			for (var i = 0; i < checkboxes.length; i++) 
				checkboxes[i].checked = !checkboxes[i].checked;
		}
		var cls;
		function n(id) {
			id.className = cls;
		}
		function b(id) {
			cls = id.className;
			id.className = "yellow";
		}
	</script>
</head>
<body>
<div class="title">Sessions</div>
<hr>
<a href="superAdmin.jsp">Administration</a> &gt; Sessions &nbsp;
<div class="link" onclick="window.location='sessionLog.jsp';">Log</div> &nbsp;
<div class="link" onclick="window.location='sessions.jsp';">Refresh</div> &nbsp;
<select onchange="doAction(this);">
	<option value="0">--Action--</option>
	<option value="1">End Sessions</option>
	<option value="2">Send Message</option>
</select>
<hr>
<table cellspacing="0" cellpadding="3">
	<tr>
		<td class="left head"><div class="link" onclick="toggle();">Toggle</div></td>
		<td class="head">Username</td>
		<td class="head">User</td>
		<td class="head">Host</td>
		<td class="head">Proj</td>
		<td class="head">Agent</td>
		<td class="head">Inactive</td>
		<td class="right head">Created</td>
	</tr>
<%
HttpSession cSession;
boolean gray = true;
Attributes attr;
DecimalFormat df = new DecimalFormat("00");
for (Iterator<String> i = st.keySet().iterator(); i.hasNext(); ) {
	id = (String) i.next();
	cSession = (HttpSession) st.get(id);
	gray = !gray;
	attr = (Attributes) cSession.getAttribute("attr");
%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (gray) out.print("class=\"gray\""); %>>
		<td class="left right input acenter"><input type="checkbox" id="<%= cSession.getId() %>"
			value="t" name="checkbox"></td>
<%
	if (attr != null) {
%>
		<td class="it"><%= attr.getUserName() %></td>
		<td class="it"><%= attr.getFullName() %></td>
		<td class="it"><%= attr.getInfo() %></td>
<%
	} else out.println("<td class=\"it\" colspan=\"3\">&nbsp;</td>");
%>
		<td class="it"><%= attr!=null?attr.getJobNum():"&nbsp;" %></td>
		<td class="it"><%= attr!=null?attr.getBrowser():"&nbsp;" %></td>
<%
long duration = 0;
try {
	duration = System.currentTimeMillis() - (Long) cSession.getAttribute("lastAccessedTime");
} catch (Exception e) {
	duration = cSession.getLastAccessedTime();
}
%>
		<td class="it aright"><%=  df.format(duration/3600000) + ":" + df.format((duration%3600000)/60000) + ":" 
			+ df.format((duration%60000)/1000) %></td>
		<td class="right"><%= FormHelper.timestamp(cSession.getCreationTime()) %></td>
	</tr>
<%
}
%>
</table>
</body>
</html>