<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.util.FormHelper" %>
<%@page import="java.text.DecimalFormat, java.text.SimpleDateFormat" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" type="text/css" href="../stylesheets/style.css">
	<script language="javascript" src="../scripts/verify.js"></script>
	<style>
   		body, td, a, select, input, textarea  {
   			font-size: <%= db.font_size %>pt;
   		}
   	</style>
	<script language="javascript">
		var request;
		var url = "../servlets/fileUpload";
    	function submitForm() {
    		if (checkForm(m)) {
    			uploading = true;
    			m.submit();
    			myAjax();
				document.getElementById("normal").style.display = "none";
				document.getElementById("progress").style.display = "block";
				return true;
			}
    		else return false;
    	}
    	function myAjax() {
   			if (window.XMLHttpRequest) {
				request = new XMLHttpRequest();
				request.onreadystatechange = stateChange;
				try {
					request.open("GET", url, true);
				} catch (e) {
					window.alert(e);
				}
				request.send(null);
			} else if (window.ActiveXObject) {
     				request = new ActiveXObject("Microsoft.XMLHTTP");
     				if (request) {
           			request.onreadystatechange = stateChange;
           			request.open("GET", url, true);
           			request.send();
           		}
           	}
    	}
    	function stateChange() {
    		if (request.readyState == 4) {
    			if (request.status == 200) {
    				var xml = request.responseXML;
    				var finished = xml.getElementsByTagName("finished")[0];
    				var kbsent = xml.getElementsByTagName("kbsent")[0];
    				var totalkb = xml.getElementsByTagName("totalkb")[0];
    				var percent = xml.getElementsByTagName("percent")[0];
    				if (finished == null) {
    					if (percent == null) window.setTimeout(myAjax, 750);
    					else {
    						document.getElementById("kbsent").innerHTML = kbsent.firstChild.data;
    						document.getElementById("totalkb").innerHTML = totalkb.firstChild.data;
    						document.getElementById("percent").innerHTML = percent.firstChild.data + "%";
    						document.getElementById("bar").style.width = Math.round(percent.firstChild.data*300/100) 
    							+ "px";
    						document.getElementById("bar").style.display = "block";
    						window.setTimeout(myAjax, 750);
    					}
    				} else {
    					uploading = false;
    					if (window.opener) window.opener.location.reload();
    					window.location.reload();
    				}
    			} else window.alert(request.statusText + "\n\n" + request.responseText);
    		} 
    	}
    	var className;
		function rC (obj) {
			className = obj.className;
			obj.className = "yellow";
		}
		function rCl (obj) {
			obj.className = className;
		}
		function checkForUpload(e) {
			if (uploading) return "Closing this page will cancel your upload.";
		}
		window.onbeforeunload= checkForUpload;
	</script>
	<title>Files <%= request.getParameter("type") + request.getParameter("id") %></title>
</head>
<body style="margin: 6px;">
<div id="progress" style="display: none;">
<table>
	<tr>
		<td class="lbl">Sent (kB)</td>
		<td><span id="kbsent">0.0</span>/<span id="totalkb">Unknown</span></td>
	</tr>
	<tr>
		<td class="lbl">Complete</td>
		<td id="percent">0.0%</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><div style="width: 300px; height: 15px; border: 1px solid blue; padding: 0px;">
			<div id="bar" style="display: none; background-color: blue; height: 15px;"></div></div></td>
</table>
</div>
<div id="imgDiv" style="position: absolute; width: 156px; height: 165px; text-align: center; padding: 3px; background-color: #C0C0C0; border: 1px solid black; z-index: 100; top: 5px; left: 75px; display: none;"></div>
<div id="normal">
<form name="main" action="../servlets/fileUpload" enctype="multipart/form-data" method="POST" 
	target="uploadFrame" onsubmit="return submitForm();">
<font size="+1">Files <%= request.getParameter("type") + request.getParameter("id") %></font><hr>
<table>
<tr>
	<td class="lbl">File</td>
	<td><input type="file" name="file" />*</td>
</tr>
<tr>
	<td class="lbl">Description</td>
	<td><input type="text" name="description" value="" />*</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><button onClick="return submitForm();" accesskey="u"><u>U</u>pload</button></td>
</tr>
</table>
<input type="hidden" name="id" value="<%= request.getParameter("id") %>" />
<input type="hidden" name="type" value="<%= request.getParameter("type") %>" />
</form>

<%
DecimalFormat df = new DecimalFormat("#0.0");
%>
<b>Note:</b> Uploads are limited to <%= in.upload_limit %>K 
(<%= df.format(Double.parseDouble(in.upload_limit)/1024) %>M) each.
<script language="javascript">
	var m = document.main;
	var d;
	d = m.description;
	d.required = true;
	d.eName = "Description";

	d = m.file;
	d.required = true;
	d.eName = "File";
</script>
<hr>
<br />
<table cellspacing="0" cellpadding="3">
	<tr>
		<td class="left head">Open</td>
		<td class="head">Description</td>
		<td class="head aright">Size</td>
		<td class="head">Type</td>
		<td class="head">User</td>
		<td class="head right">Uploaded</td>
	</tr>
<%
ResultSet rs = db.dbQuery("select file_id, description, size, protected, filename, contact_id, " +
		"content_type, uploaded, uploaded_by, print from files where id = '" + request.getParameter("id") + "' " 
		+ "and protected = 0 and type = '" + request.getParameter("type") + "' order by uploaded desc");
if (!rs.isBeforeFirst()) {
%>
	<tr>
		<td class="left right" colspan="6" align="center"><b>No attachments found!</b></td>
	</tr>
<%
}
boolean color = true;
df.applyPattern("#,##0.0");
SimpleDateFormat sdf = new SimpleDateFormat("d MMM yyyy h:mm a");
String id, content;
boolean canPrint;
boolean hasPrint = request.getParameter("noPrint") == null;
boolean print;
while (rs.next()) {
	id = rs.getString("file_id");
	color = !color;
	content = rs.getString("content_type");
%>
	<tr <%= color ? "class=\"gray\"" : "" %> 
		onMouseOver="rC(this);" 
		onMouseOut="rCl(this);">
	<td class="left"><a href="../servlets/files/<%= rs.getString("filename") %>?id=<%= id %>">Open</a></td>
	<td class="it" id="d<%= id %>"><%= rs.getString("description") %></td>
	<td class="it" align="right"><%= df.format(rs.getInt("size")/1024) %>K</td>
	<td class="it"><%= content %></td>
	<td class="it"><%= rs.getString("uploaded_by") %></td>	
	<td class="right"><%= sdf.format(rs.getTimestamp("uploaded")) %></td>
<%
}
if (rs != null) rs.getStatement().close();
//db.disconnect();
%>
</table>
</div>
<iframe id="uploadFrameID" name="uploadFrame" height="0" width="0" frameborder="0" scrolling="yes"></iframe>
</body>
</html>