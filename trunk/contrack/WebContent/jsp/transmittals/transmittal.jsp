<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security, java.util.Date" %>
<%@page import="java.util.Iterator" %>
<%@page import="com.sinkluge.utilities.DateUtils, com.sinkluge.reports.ReportUtils"  %>
<%@page import="com.sinkluge.reports.Report"  %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission"  %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger, java.util.zip.DeflaterOutputStream" %>
<%@page import="com.sinkluge.servlets.PDFReport, org.apache.commons.io.output.ByteArrayOutputStream" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/verify.js"></script>
	<script src="../utils/jsonrpc.js"></script>
	<script src="../utils/calendar.js"></script>
	<script src="../utils/spell.js"></script>
	<script>
<%
boolean my = request.getParameter("my") != null;
if (!my && !sec.ok(Name.TRANSMITTALS, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
String docPath = request.getParameter("docPath");
String companyId = "";
String contactId = "";
String companyName = "";
String attn = "";
String address = "";
String city = "";
String state = "";
String zip = "";
String copyTo = "";
String attachment = request.getParameter("attachment");
String description = "";
String purpose = "Other";
String remarks = "";
String status = "";
String phone = "";
String fax = "";
int pages = 1, userId = attr.getUserId();
Date dateCreated = new Date();
java.sql.Date respondBy = null;
Database db = new Database();
ResultSet rs = db.dbQuery("select * from transmittal where id = " + id, true);
companyId = request.getParameter("company_id");
boolean saved = false;
if (attachment != null) {
	if (!rs.first()) {
		rs.moveToInsertRow();
		rs.updateDate("created", new java.sql.Date(System.currentTimeMillis()));
		if (my) {
			rs.updateBoolean("my", true);
		}
		else {
			rs.updateInt("job_id", attr.getJobId());
			rs.updateBoolean("my", false);
		}
	}
	if (companyId == null) {
		companyName = request.getParameter("company_name");
		rs.updateString("company_name", companyName);
		attn = request.getParameter("attn");
		rs.updateString("attn", attn);
		address = request.getParameter("address");
		rs.updateString("address", address);
		city = request.getParameter("city");
		rs.updateString("city", city);
		state = request.getParameter("state");
		rs.updateString("state", state);
		zip = request.getParameter("zip");
		rs.updateString("zip", zip);
		phone = request.getParameter("phone");
		rs.updateString("phone", phone);
		fax = request.getParameter("fax");
		rs.updateString("fax", fax);
	} else {
		contactId = request.getParameter("contact_id");
		rs.updateString("company_id", companyId);
		rs.updateString("contact_id", contactId);
	}
	rs.updateString("user_id", request.getParameter("user_id")); 
	copyTo = request.getParameter("copy_to");
	rs.updateString("copy_to", copyTo);
	description = request.getParameter("description");
	rs.updateString("description", description);
	purpose = request.getParameter("purpose");
	rs.updateString("purpose", purpose);
	remarks = request.getParameter("remarks");
	rs.updateString("remarks", remarks);
	status = request.getParameter("transmittal_status");
	rs.updateString("transmittal_status", status);
	respondBy = DateUtils.getSQLShort(request.getParameter("respond_by"));
	rs.updateDate("respond_by", respondBy);
	pages = Integer.parseInt(request.getParameter("pages"));
	rs.updateInt("pages", pages);
	if (id == null) {
		rs.insertRow();
		rs.last();
		id = rs.getString("id");
		com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.TRANSMITTAL,
			id, docPath != null ? "With document attachment" : null, session);
		if (docPath != null) {
			String path = request.getPathInfo();
			path = docPath;
			String docId = path.substring(path.indexOf("id=") + 3);
			Report rep = PDFReport.getGeneratedReport(request, path , docId, attr, in, false);
			ReportUtils.addAttachments(rep, db, in.pdf_key.getBytes(), true, false, session);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
	    	DeflaterOutputStream def = new DeflaterOutputStream(baos);
	    	rep.getStream().writeTo(def);
	    	def.finish();
			ResultSet file = db.dbQuery("select * from files where file_id = 0", true);
			file.moveToInsertRow();
			file.updateString("filename", "report.pdf");
			file.updateString("content_type", "application/pdf");
			file.updateLong("size", baos.size());
			file.updateString("uploaded_by", attr.getFullName());
			file.updateTimestamp("uploaded", new java.sql.Timestamp(System.currentTimeMillis()));
			file.updateBoolean("print", true);
			file.updateString("id", id);
			file.updateString("type", "TR");
			file.updateString("description", "Attachment");
			file.updateBytes("file", baos.toByteArray());
			file.insertRow();
			file.getStatement().close();
			rep = null;
			def.close();
			def = null;
			baos = null;
		}
	} else {
		rs.updateRow();
		com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.TRANSMITTAL,
			id, session);
	}
	saved = true;
%>
	parent.left.location = "transmittalLeft.jsp?id=<%= id %><%= my ? "&my=t" : "" %>";
<%
	// Only reload if there is a reason to...
	if (docPath == null) {
%>
	parent.opener.location.reload();
<%
	}
} else if (rs.first()) {
	companyId = rs.getString("company_id");
	if (companyId == null) {
		companyName = rs.getString("company_name");
		attn = rs.getString("attn");
		address= rs.getString("address");
		city = rs.getString("city");
		state = rs.getString("state");
		zip = rs.getString("zip");
		phone = rs.getString("phone");
		fax = rs.getString("fax");
	} else contactId = rs.getString("contact_id");
	copyTo = rs.getString("copy_to");
	userId = rs.getInt("user_id");
	description = rs.getString("description");
	purpose = rs.getString("purpose");
	remarks = rs.getString("remarks");
	status = rs.getString("transmittal_status");
	respondBy = rs.getDate("respond_by");
	pages = rs.getInt("pages");
}
if (companyId != null) {
	rs.getStatement().close();
	rs = db.dbQuery("select company_name from company where company_id = " + companyId);
	if (rs.first()) companyName = rs.getString(1);
}
if (attachment == null) attachment = "Other";
%>
		var changed = false;
		function doUnload() {
			if(changed) return "You have unsaved work on this page!";
		}
		window.onbeforeunload = doUnload;
		function save() {
			if (checkForm(tr)) {
				changed = false;
				tr.submit();
			} else return false;
		}
		function spell() {
			spellCheck(tr);
		}
	</script>
</head>
<body>
<div class="title"><%= my ? "My " : "" %>Transmittal</div><hr>
<%= saved ? "<div class=\"red bold\">Saved</div><hr>" : "" %>
<form id="main" method="POST">
<%= id != null ? "<input type=\"hidden\" name=\"id\" value=\"" + id + "\">" : "" %>
<%= docPath != null ? "<input type=\"hidden\" name=\"docPath\" value=\""
		+ docPath + "\"><input type=\"hidden\" name=\"add\" value=\"" + request.getParameter("add")
		+ "\">" : "" %>
<table>
<%
if (id != null) {
%>
<tr>
	<td class="lbl">ID</td>
	<td><%= com.sinkluge.utilities.Widgets.logLinkWithId(id, com.sinkluge.Type.TRANSMITTAL,
		"parent", request) %></td>
</tr>
<%	
}
%>
<%
if (companyId != null) {
%>
<tr>
	<td class="lbl">Company</td>
	<td><%= companyName %><input type="hidden" name="company_id" value="<%= companyId %>"></td>
</tr>
<tr>
<%
	rs.getStatement().close();
	rs = db.dbQuery("select contact_id, name from contacts where company_id = " + companyId
		+ " order by name");
%>
	<td class="lbl">Contact</td>
	<td><select onchange="changed=true;" name="contact_id">
<%
	while (rs.next()) out.println("<option value=\"" + rs.getString("contact_id") + "\""
		+ FormHelper.sel(rs.getString(1), contactId) + ">" + rs.getString("name") + "</option>");

%>
		</select></td>
</tr>
<%
} else {
%>
<tr>
	<td class="lbl">Company</td>
	<td><input onchange="changed=true;" type="text" name="company_name" value="<%= companyName %>"></td>
</tr>
<tr>
	<td class="lbl">Attn</td>
	<td><input onchange="changed=true;" type="text" name="attn" value="<%= attn %>"></td>
</tr>
<tr>
	<td class="lbl">Address</td>
	<td><input onchange="changed=true;" type="text" name="address" value="<%= address %>"></td>
</tr>
<tr>
	<td class="lbl">City</td>
	<td><input onchange="changed=true;" type="text" name="city" value="<%= city %>">
		<span class="bold">State</span> <input onchange="changed=true;" type="text" name="state" value="<%= state %>" size="7">
		<span class="bold">Zip</span> <input onchange="changed=true;" type="text" name="zip" value="<%= zip %>" maxlength="10" size="7">
	</td>
</tr>
<tr>
	<td class="lbl">Phone</td>
	<td><input onchange="changed=true;" type="text" size="20" maxlength="14" name="phone" value="<%= phone %>">
		<span class="bold">Fax</span>
		<input onchange="changed=true;" type="text" size="20" maxlength="14" name="fax" value="<%= fax %>">
	</td>
</tr>
<%
}
%>
<tr>
	<td class="lbl">Date Created</td>
	<td><%= FormHelper.medDate(dateCreated) %></td>
</tr>
<tr>
	<td class="lbl"><div class="link" onclick="insertDate('respond_by');">Respond By</div></td>
	<td><input onchange="changed=true;" type="text" id="respond_by" name="respond_by" maxlength="10" size="8" 
			value="<%= FormHelper.date(respondBy) %>">
		<img id="calrespond_by" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
		</td>
</tr>
<tr>
	<td class="lbl">Copy To</td>
	<td><input onchange="changed=true;" type="text" name="copy_to" value="<%= FormHelper.string(copyTo) %>"></td>
</tr>
<%
if (!my) {
%>
<tr>
	<td class="lbl">From</td>
	<td><%= com.sinkluge.utilities.Widgets.userList(userId, "user_id", "onchange=\"changed=true;\"") %></td>
</tr>
<%
} else out.println("<input type=\"hidden\" name=\"user_id\" value=\"" + attr.getUserId() + "\">");
%>
<tr>
	<td class="lbl">Attachments</td>
	<td><select onchange="changed=true;" name="attachment">
		<option value = "Shop Drawings" <%= FormHelper.sel("Shop Drawings", attachment) %>>Shop Drawings</option>
		<option value = "Specifications" <%= FormHelper.sel("Specifications", attachment) %>>Specifications</option>
		<option value = "Prints/Plans" <%= FormHelper.sel("Prints/Plans", attachment) %>>Prints/Plans</option>
		<option value = "Copy Of Letter" <%= FormHelper.sel("Copy Of Letter", attachment) %>>Copy Of Letter</option>
		<option value = "Samples" <%= FormHelper.sel("Samples", attachment) %>>Samples</option>
		<option value = "Change Order" <%= FormHelper.sel("Change Order", attachment) %>>Change Order</option>
		<option value = "Submittals" <%= FormHelper.sel("Submittals", attachment) %>>Submittals</option>
		<option value = "None" <%= FormHelper.sel("None", attachment) %>>None</option>
		<option value = "Other" <%= FormHelper.sel("Other", attachment) %>>Other</option>
		</select></td>
</tr>
<tr>
	<td class="lbl">Description of Attachments</td>
    <td><textarea name="description" rows="5" cols="80"><%= FormHelper.string(description) %></textarea></td>
</tr>
<tr>
	<td class="lbl">Purpose</td>
	<td><select onchange="changed=true;" name="purpose">
		<option value = "For Your Approval"  <%= FormHelper.sel("For Your Approval", purpose) %>>For Your Approval</option>
		<option value = "Per Your Request" <%= FormHelper.sel("Per Your Request", purpose) %>>Per Your Request</option>
		<option value = "Approved as Submitted" <%= FormHelper.sel("Approved as Submitted", purpose) %>>Approved as Submitted</option>
		<option value = "To Be Resubmitted" <%= FormHelper.sel("To Be Resubmitted", purpose) %>>To Be Resubmitted</option>
		<option value = "For Your Use" <%= FormHelper.sel("For Your Use", purpose) %>>For Your Use</option>
		<option value = "For Review And Comment" <%= FormHelper.sel("For Review and Comment", purpose) %>>For Review And Comment</option>
		<option value = "Approved As Noted" <%= FormHelper.sel("Approved as Noted", purpose) %>>Approved As Noted</option>
		<option value = "None" <%= FormHelper.sel("None", purpose) %>>None</option>
		<option value = "Other" <%= FormHelper.sel("Other", purpose) %>>Other</option>
		</select></td>
</tr>
<tr>
	<td class="lbl">Remarks</td>
    <td><textarea name="remarks" rows="5" cols="80"><%= FormHelper.string(remarks) %></textarea></td>
</tr>
<tr>
	<td class="lbl">Transmittal Status</td>
	<td><select onchange="changed=true;" name="transmittal_status">
		<option value = "Response Required" <%= FormHelper.sel("Response Required", status) %>>Response Required</option>
		<option value = "Submittals Processed" <%= FormHelper.sel("Submittals Processed", status) %>>Submittals Processed</option>
		<option value = "Completed" <%= FormHelper.sel("Completed", status) %>>Completed</option>
		</select></td>
</tr>
<tr>
	<td class="lbl">Pages</td>
	<td><input onchange="changed=true;" type="text" name="pages" value="<%= pages %>" size="7"> <i>including transmittal document</i></td>
</tr>
</table>
</form>
<script>
	var tr = document.getElementById("main");
	var fe = tr.pages;
	fe.eName = "Pages"
	fe.isInt = true;
	fe.required = true;
	fe = tr.remarks;
	fe.spell = true;
	fe = tr.description;
	fe.spell = true;
	fe = tr.respond_by;
	fe.isDate = true;
	fe.eName = "Respond By";
<%
if (companyId == null) {
%>
	fe = tr.zip;
	fe.isZip = true;
	fe.eName = "Zip";
	fe = tr.phone;
	fe.isPhone = true;
	fe.eName = "Phone";
	fe = tr.fax;
	fe.isPhone = true;
	fe.eName = "Fax";
<%
}
rs.getStatement().close();
rs = null;
db.disconnect();
%>
</script>
</body>
</html>