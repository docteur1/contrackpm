<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.Type, com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="JSONRPCBridge" scope="session"
     class="org.jabsorb.JSONRPCBridge" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
/*
 * This is much better, but better yet, we need to test the item to make sure it belongs
 * to this job, ie add queries to the Type enum.
 */
Type type = Type.valueOf(request.getParameter("type"));
if (type == null) throw new ServletException("parameter \"type\" cannot be null");
if (!sec.ok(type.getSecurityName(), Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
JSONRPCBridge.registerClass("ful", com.sinkluge.servlets.FileUpload.class);
boolean sw = sec.ok(type.getSecurityName(), Permission.WRITE);
Database db = new Database();
%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="verify.js"></script>
	<script src="jsonrpc.js"></script>
	<script language="javascript">
		var jsonrpc = new JSONRpcClient("../JSON-RPC");
		var upload_id = 0;
    	function submitForm() {
    		if (checkForm(m)) {
        		upload_id = Math.random();
        		m.upload_id.value = upload_id;
    			m.submit();
    			uploading = true;
				document.getElementById("normal").style.display = "none";
				document.getElementById("progress").style.display = "block";
				window.setTimeout(poll, 500);
				return true;
			}
    		else return false;
    	}
    	function setFileValue(obj, id, name) {
        	if (<%= sw %>) jsonrpc.ful.setFileValue(id, name, obj.checked);
    	}
    	function setImageValue(obj, id, name) {
        	if (<%= sw %>) jsonrpc.ful.setImageValue(id, "<%= type.getCode() %>", 
                "<%= request.getParameter("id") %>", name, obj.checked);
    	}
    	function poll() {
        	jsonrpc.ful.getStatus(pollCallback, upload_id);
    	}
    	function pollCallback(result, e) {
        	if (e == null) {
        		var bar = document.getElementById("bar");
        		document.getElementById("kbsent").innerHTML = result.sent;
				document.getElementById("totalkb").innerHTML = result.total
				document.getElementById("percent").innerHTML = result.percent + "%";
            	if (result.finished) {
                	bar.style.width = "300px";
                	bar.style.display = "block";
                	uploading = false;
                	if (opener != null) {
                    	if (opener.reload) opener.reload();
                        else opener.location.reload();
                	}
                	window.setTimeout(function () {
                		window.location = "upload.jsp?id=<%= request.getParameter("id") 
                			%>&type=<%= request.getParameter("type") %>&upload_id=" + upload_id;
                	}, 750); 
            	} else {
					bar.style.width = Math.round(result.percent*300/100) + "px";
					bar.style.display = "block";
					window.setTimeout(poll, 1000);
            	}
        	} else {
            	window.alert("Error\n-------------------\n" + e.message);
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
		function del(id) {
			if(confirm("Delete this file?")) location = "processUpload.jsp?id=<%= request.getParameter("id") %>&type=<%= request.getParameter("type") %>&file_id=" + id;
		}
		var uploading = false;
		function checkForUpload(e) {
			if (uploading) return "Closing this page may cancel your upload.";
		}
		window.onbeforeunload = checkForUpload;
	</script>
	<title>Attachments <%= type.getCode() + request.getParameter("id") %></title>
</head>
<body>
<div id="progress" style="display: none;">
<table>
	<tr>
		<td class="lbl">Sent (kB)</td>
		<td><span id="kbsent">0.0</span> of <span id="totalkb">[Calculating...]</span></td>
	</tr>
	<tr>
		<td class="lbl">Complete</td>
		<td id="percent">0.0%</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><div style="width: 300px; height: 15px; border: 1px solid blue; padding: 0px;">
			<div id="bar" style="display: none; background-color: blue; height: 15px;"></div></div></td>
	</tr>
</table>
</div>
<div id="normal">
<%
boolean hasEmail = in.hasEmail && type.canEmail();
boolean hasPrint = type.canPrint();
if (sw) {
%>
<form name="main" action="../servlets/fileUpload" enctype="multipart/form-data" method="POST" 
	target="uploadFrame" onsubmit="return submitForm();">
<input type="hidden" name="upload_id" value="0" />
<font size="+1">Attachments <%= type.getCode() + request.getParameter("id") %></font><hr>
<table>
<tr>
	<td class="lbl">File</td>
	<td><input type="file" name="file" />*</td>
</tr>
<tr>
	<td class="lbl">Description</td>
	<td><input type="text" name="description" value="" /> <i>optional</i></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><%= hasPrint ?
			"<input type=\"checkbox\" name=\"print\" value=\"1\"> <span class=\"bold\">Print</span>" : "" %>
		<%= hasEmail ?	
			"<input type=\"checkbox\" name=\"email\" value=\"1\"> <span class=\"bold\">Email</span>" : "" %>
		<input type="checkbox" name="protected" value="1"> <span class="bold">Protected</span></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="button" onclick="return submitForm();" value="Upload"> &nbsp;
		<input type="button" onclick="window.close();" value="Close"></td>
</tr>
</table>
<%
}
%>
<input type="hidden" name="id" value="<%= request.getParameter("id") %>" />
<input type="hidden" name="type" value="<%= type.getCode() %>" />
</form>
<b>Note:</b> Uploads are limited to <%= in.upload_limit %>K 
(<%= FormHelper.basicDecimal(Double.parseDouble(in.upload_limit)/1024) %>M) each.
<script language="javascript">
	var m = document.main;
	var d;

	d = m.file;
	d.required = true;
	d.eName = "File";
</script>
<hr>
<div class="bold">Uploaded Files</div>
<table cellspacing="0" cellpadding="3" style="margin-bottom: 8px;">
	<tr>
		<td class="left head">Open</td>
		<td class="head">Delete</td>
		<td class="head">Description</td>
		<td class="head aright">Size</td>
		<td class="head">Type</td>
		<td class="head">User</td>
		<td class="head">Uploaded</td>
		<td class="head">Print</td>
		<%= hasEmail ? "<td class=\"head\">Email</td>" : "" %>
		<td class="right head">Protected</td>
	</tr>
<%
if (sw && request.getParameter("print") != null) {
	db.dbInsert("update files set print = " + (Boolean.parseBoolean(request.getParameter("print")) ?
		"1" : "0") + " where file_id = " + request.getParameter("file_id"));
}
if (sw && request.getParameter("email") != null) {
	db.dbInsert("update files set email = " + (Boolean.parseBoolean(request.getParameter("email")) ?
		"1" : "0") + " where file_id = " + request.getParameter("file_id"));
	db.dbInsert("update files set email = 0 where file_id = " + request.getParameter("file_id")
			+ " and protected = 1");
}
if (sw && request.getParameter("protected") != null) {
	db.dbInsert("update files set protected = " + (Boolean.parseBoolean(request.getParameter("protected")) ?
		"1" : "0") + " where file_id = " + request.getParameter("file_id"));
	db.dbInsert("update files set email = 0 where file_id = " + request.getParameter("file_id")
		+ " and protected = 1");
}
ResultSet rs = db.dbQuery("select file_id, description, size, protected, filename, " +
		"content_type, uploaded, uploaded_by, print, email from files where id = '" + 
		request.getParameter("id") + "' and type = '" + type.getCode() + "' order by uploaded desc");
if (!rs.isBeforeFirst()) {
%>
	<tr>
		<td class="left right" colspan="10" align="center"><b>No attachments found!</b></td>
	</tr>
<%
}
boolean color = true;
String id, content;
boolean canPrint;
boolean print;
while (rs.next()) {
	id = rs.getString("file_id");
	color = !color;
	content = rs.getString("content_type");
	canPrint = (content.indexOf("pdf") != -1 || content.indexOf("tif") != -1
		|| content.indexOf("jpeg") != -1 || content.indexOf("gif") != -1 || content.indexOf("png") != -1) && hasPrint;
	print = canPrint && rs.getBoolean("print");
%>
	<tr <%= color ? "class=\"gray\"" : "" %> 
		onMouseOver="rC(this);"	onMouseOut="rCl(this);">
	<td class="left"><a href="../servlets/files/<%= rs.getString("filename") %>?id=<%= id %>">Open</a></td>
	<td class="right"><a href="javascript: del(<%= id %>);">Delete</a></td>
	<td class="it" id="d<%= id %>"><%= rs.getString("description") %></td>
	<td class="it" align="right"><%= FormHelper.basicDecimal(rs.getInt("size")/1024) %>K</td>
	<td class="it"><%= content %></td>
	<td class="it"><%= rs.getString("uploaded_by") %></td>	
	<td class="it"><%= FormHelper.timestamp(rs.getTimestamp("uploaded")) %></td>
<%
	if (print || canPrint) {
%>
	<td class="input acenter"><input type="checkbox" onclick="setFileValue(this, <%= id %>, 'print');"
		<%= FormHelper.chk(rs.getBoolean("print")) %>></td><%
	} else out.print("<td class=\"it\">&nbsp;</td>");
	if (hasEmail) { 
%>
	<td class="input acenter"><input type="checkbox" onclick="setFileValue(this, <%= id %>, 'email');"
		<%= FormHelper.chk(rs.getBoolean("email")) %>></td>
<%
	}
%>
	<td class="right input acenter"><input type="checkbox" onclick="setFileValue(this, <%= id %>, 'protected');"
	<%= FormHelper.chk(rs.getBoolean("protected")) %>></td>
<%
}
if (rs != null) rs.getStatement().close();
db.disconnect();
%>
</table>
<%
if (in.hasKF) {
	id = request.getParameter("id");
	
%>
<jsp:include page="kfw.jsp">
	<jsp:param name="id" value="<%= id %>" />
	<jsp:param name="type" value="<%= type.name() %>" />
</jsp:include>
<%
}
%>
</div>
<iframe id="uploadFrameID" name="uploadFrame" <%= (in.testMode ? "height=\"200\" width=\"300\"" : 
	"height=\"0\" width=\"0\"") %> frameborder="0" scrolling="yes"></iframe>
</body>
</html>