<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@page import="org.apache.commons.fileupload.FileItemIterator" %>
<%@page import="org.apache.commons.fileupload.FileItemStream" %>
<%@page import="org.apache.commons.fileupload.FileUploadBase.InvalidContentTypeException" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="java.io.ByteArrayOutputStream" %>
<%@page import="com.sinkluge.utilities.ImageUtils" %>
<%@page import="org.apache.commons.fileupload.util.Streams" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" />
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script>
		function resize(obj) {
			obj.width = obj.width/2;
			obj.style.visibility = "visible";
		}
<%
if (!sec.ok(Security.ADMIN, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String contentType = null;
byte[] fBytes = null;
ResultSet rs = null;
String siteId = request.getParameter("site_id");
try {
	ServletFileUpload upload = new ServletFileUpload();
	upload.setSizeMax(Integer.parseInt(in.upload_limit)*1000);
	FileItemStream item = null;
	for(FileItemIterator iter = upload.getItemIterator(request); iter.hasNext(); ) {
	    item = iter.next();
	    if (!item.isFormField()){
			if (item.getContentType().indexOf("gif") != -1 || item.getContentType().indexOf("jpeg") != -1
					|| item.getContentType().indexOf("png") != -1) {
				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				ImageUtils.genJPEGThumb(item.openStream(), baos, 1150, 350);
				fBytes = baos.toByteArray();
				contentType = item.getContentType();
	    	} else {
%>
	window.alert("Only GIF, JPEG, or PNG images may be used!");
<%
	    	}
		} else if ("site_id".equals(item.getFieldName())) siteId = Streams.asString(item.openStream());
	}
} catch (InvalidContentTypeException e) {
} catch (org.apache.commons.fileupload.FileUploadBase.SizeLimitExceededException e) {
%>
	window.alert("File too large!\n----------------\nThe uploaded file size was "
		+ "<%= e.getActualSize()/1000  %>K\nThe permited size is <%= in.upload_limit %>K.");
<%
} catch (IllegalArgumentException e) {
	// Thrown is the image is stupid...
%>
	window.alert("The image is invalid: <%= e.getMessage() %>");
<%
}
Database db = new Database();
if (fBytes != null) {
	rs = db.dbQuery("select * from sites where site_id = " + siteId, true);
	if (rs.first()) {
		rs.updateBytes("logo", fBytes);
		rs.updateString("content_type", contentType);
		rs.updateRow();
	}
	if (rs != null) rs.getStatement().close();
	rs = null;
}
if (siteId == null) siteId = "1";
%>
	</script>
</head>
<body>
<font size="+1">Logo</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; Logo<hr>
<div style="width: 579px;">
	The logo should fit the green box as well as possible. Ideally this is 1150x350 pixels. Only use JPEG or GIF 
	images. A little white border should improve the appearance of many reports.
</div>
<div style="margin-top: 10px; position: relative;">
	<div style="border: 4px solid black; background-color: green; height: 179px; width: 579px; filter: alpha(opacity:50); opacity: 0.5; MozOpacity: 0.5;">&nbsp;</div>
	<div style="z-index: -1; position: absolute; top: 4px; left: 4px; "><img onload="resize(this);" 
		style="visibility: hidden; border: 2px solid black;" 
		src="<%= request.getContextPath() %>/jsp/servlets/logo/logo?site_id=<%= siteId %>"></div>
</div>
<form enctype="multipart/form-data" action="uploadLogo.jsp" id="main" method="POST" onSubmit="return checkForm(this);">
<table style="margin-top: 10px">
	<tr>
		<td class="lbl">Site:</td>
		<td><select name="site_id" onChange="window.location='uploadLogo.jsp?site_id=' + this.value;">
<%
rs = db.dbQuery("select site_id, site_name from sites order by site_id");
while (rs.next()) out.println("<option value=\"" + rs.getString(1) + "\" " + FormHelper.sel(rs.getString(1),
		siteId) + ">" + rs.getString(2) + "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
	</tr>
	<tr>
		<td class="lbl">Upload:</td>
		<td><input type="file" name="logo"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Upload"></td>
</table>
</form>
<script>
	var f = document.getElementById("main");
	var d = f.logo;
	d.required = true;
	d.eName = "Upload";
</script>
</body>
</html>