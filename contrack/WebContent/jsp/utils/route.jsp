<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="java.sql.ResultSet,
    com.sinkluge.security.*, accounting.Accounting, accounting.Route,
    com.sinkluge.accounting.AccountingUtils, accounting.Route.*,
    java.util.Iterator, com.sinkluge.utilities.FormHelper,
    accounting.Voucher, accounting.Company" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%
// Gather the information...
String scId = request.getParameter("sc_id");
String id = request.getParameter("id");
int siteId = attr.getSiteId();
ResultSet rs = null;
Database db = new Database();
Security s = sec;
if (request.getParameter("sc_id") != null) {
	rs = db.dbQuery("select job.job_id, site_id from suspense_cache join " +
		"job using(job_id) where sc_id = " + scId);
	if (rs.first()) {
		int jobId = rs.getInt(1);
		siteId = rs.getInt(2);
		if (attr.getJobId() != jobId) {
			boolean isAdmin = sec.ok(Name.ADMIN, Permission.READ);
			s = new Security();
			s.isAdmin(isAdmin);
			s.setJob(jobId, request);
		}
	}
	rs.getStatement().close();	
}
// Now check the security settings
if (!s.ok(Name.APPROVE_PAYMENT, Permission.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	db.disconnect();
	return;
}
%>
<html>
<head>
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<%
Route route = null;
Accounting acc = AccountingUtils.getAccounting(application, siteId);
if (acc != null && acc.hasRouting()) route = acc.getVoucherRoute(id);
if (route == null) {
%>
<script>
	window.alert("Error\n-------------------This feature is not supported or item not found!");
	window.close();
</script>
<%
}
%>
<title>Voucher #<%= route != null ? route.getVoucherId() : "" %> Approval</title>
</head>
<body>
<%
if (route != null) {
	String action = request.getParameter("action");
	if (action != null) {
		boolean approve = "Approve".equals(action);
		route.setCurNotes(FormHelper.stringNull(request.getParameter("note")));
		if (route.getCurNotes() != null) route.setCurNotes((approve ? "Approved:\n" : 
			"Rejected:\n") + route.getCurNotes() 
			+ "\n-" + attr.getFullName());
		route.setStatus(approve ? Route.STATUS_APPROVE : Route.STATUS_REJECT);
		acc.setVoucherRoute(route);
		if (scId != null) db.dbInsert("delete from suspense_cache where sc_id = " + scId);
%>
<script>
	window.opener.wbutton.style.display = "none";
	window.close();
</script>
<%
	} else {
%>
<script>
	function openvoucher() {
		var msgWindow = window.open("../costCodes/voucherInquiry.jsp?id=<%= route.getVoucherId() %>","voucher","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=400,left=40,top=40");
		msgWindow.focus();
	}
</script>
<div class="title">Voucher #<%= route.getVoucherId() %> Approval</div><hr/>
<div class="link" onclick="openvoucher();">Voucher Inquiry</div><hr/>
<fieldset>
<legend>Notes</legend>
<%
		Note n;
		for (Iterator<Note> i = route.getNotes(); i.hasNext(); ) {
			n = i.next();
			if (!com.sinkluge.utilities.Verify.blank(n.getNote())) {
%>
	<div class="bold"><%= n.getUser() %>:</div>
	<%= n.getNote().replaceAll("\n","<br/>") %><br/><br/>
<%
			}
		}
		Voucher v = acc.getVoucher(route.getVoucherId());
		Company company = acc.getCompany(v.getAccountCompanyId());
%>
</fieldset>
<form method="POST">
<%= scId != null ? "<input type=\"hidden\" name=\"sc_id\" value=\"" + scId + "\">" : "" %>
<input type="hidden" name="id" value="<%= id %>">
<table>
<tr>
<td class="lbl">Company</td>
<td><%= company.getName() %></td>
</tr>
<tr>
<td class="lbl">Amount</td>
<td><%= FormHelper.cur(v.getAmount()) %></td>
</tr>
<tr>
<td class="lbl">Note</td>
<td><textarea id="note" name="note" cols="30" rows="3"></textarea></td>
</tr>
<tr>
<td>&nbsp;</td>
<td><input type="submit" name="action" value="Approve"> &nbsp;
<input type="submit" name="action" value="Reject"> &nbsp;
<input type="button" onclick="window.close();" value="Close">
</td>
</tr>
</table>
</form>
<%
	} // not saving route
} // route not null
%>
</body>
</html>
<%
db.disconnect();
%>