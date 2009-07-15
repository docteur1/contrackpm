<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="com.sinkluge.utilities.SimpleMailer, java.sql.ResultSet, com.sinkluge.utilities.ESubmit" %>
<%@ page import="com.sinkluge.security.Name, com.sinkluge.security.Permission, com.sinkluge.Type" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%
Type type = Type.valueOf(request.getParameter("type"));
int id = Integer.parseInt(request.getParameter("id"));
if (!sec.ok(type.getSecurityName(), Permission.PRINT)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
if (request.getParameter("to") != null) {
	ESubmit.setESubmit(id, type, session);
	String message = request.getParameter("message");
	String additional = request.getParameter("additional");
	if (additional != null) message += additional;
	message = "<html><head><style>*{font-family:Arial;font-size:10pt;}</style></head><body>" + message;
	message += "</body></html>";
	try {
		SimpleMailer.sendMessage(attr.getEmail(), attr.getFullName(), request.getParameter("to"), attr.getEmail(),
			request.getParameter("subject"), message, "text/html", in);
		com.sinkluge.utilities.ItemLogger.eSubmited.update(type,
			Integer.toString(id), Integer.parseInt(request.getParameter("contact_id")),
			Integer.parseInt(request.getParameter("company_id")), session);
%>
<script>
	window.alert("The message was successfully sent");
	window.location = "<%= request.getParameter("loc") %>";
</script>
<%
	} catch (org.apache.commons.mail.EmailException e) {
%>
<script>
	window.alert("ERROR\n------------------------\nUnable to send the message:\n<%= e.getMessage() %>");
	window.location = "<%= request.getParameter("loc") %>";
</script>
<%
	}
} else { // request.getParameter("to") != null
%>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<title>eSubmit - <%= type.getFriendlyName() %></title>
</head>
<body>
<div class="title">eSubmit - <%= type.getFriendlyName() %></div><hr>
<div class="link" onclick="window.location='<%= request.getParameter("loc") %>';">Back to <%= type.getFriendlyName() %></div>
	&gt; eSubmit - <%= type.getFriendlyName() %><hr>
<%
String message = null;
ResultSet rs = null;
String sql = null;
String to = "ERROR", subject = "Subject";
int toId = ESubmit.geteSubmitContactId(id, type);
if (toId != 0) {
%>
<form id="main" method="POST">
<input type="hidden" name="id" value="<%= id %>">
<input type="hidden" name="type" value=<%= type %>">
<table>
<tr>
<td class="lbl">To</td>
<%
	Database db = new Database();
	rs = db.dbQuery("select company_id, name, email from contacts where contact_id = " + toId);
	int companyId = 0;
	if (rs.first()) {
		to = rs.getString("name") + " <" + rs.getString("email") + ">";
		companyId = rs.getInt("company_id");
	}
	rs.getStatement().close();
%>
<td><%= org.apache.commons.lang.StringEscapeUtils.escapeXml(to) %>
	<input type="hidden" name="to" value="<%= to %>">
	<input type="hidden" name="company_id" value="<%= companyId %>" />
	<input type="hidden" name="contact_id" value="<%= toId %>" /></td>
</tr>
<%
	switch (type) {
	case SUBMITTAL:
		sql = "select a.company_name as arch, s.company_name as sub, submittals.description, submittal_num from submittals join "
			+ "contracts using(contract_id) join company as s on contracts.company_id = s.company_id join job_contacts "
			+ "on architect_id = job_contact_id join company as a on job_contacts.company_id = "
			+ "a.company_id where submittal_id = " + id;
		rs = db.dbQuery(sql);
		if (rs.first()) {
			subject = attr.getJobName() + " Submittal # " + rs.getString("submittal_num");
			message = "<div id=\"msg\"><div style=\"margin-bottom: 15px;\"><img src=\"../../images/contrack.gif\" alt=\"Contrack Logo\"></div><table>";
			message += "<tr><td><b>Subcontractor/Supplier:</b></td><td>" + rs.getString("sub") + "</td></tr>";
			message += "<tr><td><b>Architect/Engineer:</b></td><td>" + rs.getString("arch") + "</td></tr>";
			message += "<tr><td><b>Submittal Number:</b></td><td>" + rs.getString("submittal_num") + "</td></tr>";
			message += "<tr><td><b>Description:</b></td><td>" + rs.getString("description") + "</td></tr>";
			message += "<tr><td>&nbsp;</td><td><a href=\"" + in.external_url + "\" target=\"_blank\">Process Submittal Online</a></td></tr></table></div>";
		}
	case RFI:
		sql = "select rfi_num, request, urgency from rfi where rfi_id = " + id;
		rs = db.dbQuery(sql);
		if (rs.first()) {
			subject = attr.getJobName() + " RFI # " + rs.getString("rfi_num");
			message = "<div id=\"msg\"><div style=\"margin-bottom: 15px;\"><img src=\"../../images/contrack.gif\" alt=\"Contrack Logo\"></div><table>";
			message += "<tr><td><b>RFI Number:</b></td><td>" + rs.getString("rfi_num") + "</td></tr>";
			message += "<tr><td><b>Request:</b></td><td>" + rs.getString("request") + "</td></tr>";
			message += "<tr><td><b>Urgency:</b></td><td>" + rs.getString("urgency") + "</td></tr>";
			message += "<tr><td>&nbsp;</td><td><a href=\"" + in.external_url + "\">Reply to RFI Online</a></td></tr></table>";
		}
	}
	rs.getStatement().close();
	db.disconnect();
	message = message.replaceAll("\n", "<br/>");
%>
<tr>
<td class="lbl">Subject</td>
<td><input type="text" name="subject" value="<%= subject %>" size="80"></td>
</tr>
<tr>
<td colspan="2">
<fieldset>
<legend>Message Preview</legend>
<%= message %>
<input type="hidden" name="msg" value="<%= org.apache.commons.lang.StringEscapeUtils.escapeXml(message) %>">
</fieldset>
</td>
</tr>
<tr>
<td class="lbl">CC Myself</td>
<td><input type="checkbox" name="cc"></td>
<tr>
<td class="lbl">Additional<br/>Message<br/>(optional)</td>
<td><textarea name="additional" cols="100" rows="3"></textarea></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="submit" value="Send"></td>
</tr>
</table>
</form>
</body>
<%
} // if toId != 0
} // request.getParameter("to") != null
%>
</html>