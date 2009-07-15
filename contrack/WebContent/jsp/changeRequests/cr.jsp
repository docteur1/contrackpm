<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security,java.sql.Date" %>
<%@page import="com.sinkluge.User,java.util.Iterator" %>
<%@page import="com.sinkluge.utilities.DateUtils,com.sinkluge.utilities.DataUtils"  %>
<%@page import="java.util.EnumSet, accounting.Action"  %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="com.sinkluge.utilities.ItemLogger" %>
<%@page import="accounting.Accounting, accounting.CR, accounting.CRD, accounting.Result" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<%
if (!sec.ok(Security.CO, Security.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
Logger log = Logger.getLogger(this.getClass());
boolean sw = sec.ok(Security.CO, Security.WRITE);
boolean sd = sec.ok(Security.CO, Security.DELETE);
JSONRPCBridge.registerClass("verify", com.sinkluge.JSON.Verify.class);
JSONRPCBridge.registerClass("list", com.sinkluge.JSON.List.class);
String id = request.getParameter("id");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
<script src="../utils/verify.js"></script>
<script src="../utils/jsonrpc.js"></script>
<script src="../utils/calendar.js"></script>
<script src="../utils/spell.js"></script>
<script src="scripts/cr.js"></script>
<script>
<%
// TODO: FINISH the reloadc function
%>
	function reloadc() {
		if (!changed && <%= !"POST".equals(request.getMethod()) %>) {
			window.location.reload();
		}
	}
	function save() {
		if (detailCount != 0) {
			if ((cr.status.value != "Approved") || (cr.co_id.value != "0")) {
				if (checkForm(cr)) {
					try {
						var result = jsonrpc.verify.cRNum(cr.num.value, <%= id %>);
						if (!result) {
							changed = false;
							cr.num.disabled = false;
							cr.submit();
							return true;
						} else { 
							window.alert("ERROR\n------------------------\nDuplicate CR #. The number is already "
								+ "used on:\n" + result + ".");
							cr.num.style.backgroundColor = "#FFFFCC";
							return false;
						}
					} catch (e) {
						window.alert(e);
						return false;
					}
				} else return false;
			} else {
				window.alert("ERROR\n------------------------\n"
					+ "Please select/create a change order to approve\n"
					+ "this change request.");
			}
		} else {
			window.alert("ERROR\n------------------------\nForm cannot be submitted without detail items.\nPlease"
				+ " create detail items and resubmit.");
			return false;
		}
	}
<%
int num = 1;
int signedId = 0;
String submitTo = "";
String title = "";
Date date = new Date(new java.util.Date().getTime());
Date submitDate = null;
Date approvedDate = null;
String description = "";
String comments = "";
String status = "Estimating";
String result = "Cost Change";
double daysAdded = 0;
int toId = 0;
int coId = 0;
Result accResult;
int ar = 0;
String sql = "select submit_co_to from job where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(sql);
if (rs.first()) submitTo = rs.getString(1);
if (rs != null) rs.getStatement().close();
sql = "select * from change_requests where cr_id = " + id;
rs = db.dbQuery(sql, true);
String msg = "";
CR cr = null, oldCr = null;
CRD crd = null, oldCrd = null;
if (request.getParameter("num") != null && sec.ok(Security.CO, Security.WRITE)) {
	num = Integer.parseInt(request.getParameter("num"));
	signedId = Integer.parseInt(request.getParameter("signed_id"));
	title = request.getParameter("crTitle");
	date = DateUtils.getSQLShort(request.getParameter("date"));
	submitDate = DateUtils.getSQLShort(request.getParameter("submit_date"));
	approvedDate = DateUtils.getSQLShort(request.getParameter("approved_date"));
	description = request.getParameter("description");
	comments = request.getParameter("comments");
	status = request.getParameter("status");
	result = request.getParameter("result");
	daysAdded = Double.parseDouble(request.getParameter("days_added"));
	toId = Integer.parseInt(request.getParameter("to_id"));
	coId = Integer.parseInt(request.getParameter("co_id"));
	if (!rs.first()) 
		rs.moveToInsertRow();
	else if (attr.hasAccounting()) oldCr = AccountingUtils.getCr(id);
	rs.updateInt("num", num);
	rs.updateInt("signed_id", signedId);
	rs.updateString("title", title);
	rs.updateDate("date", date);
	rs.updateDate("submit_date", submitDate);
	if (!"Approved".equals(status)) approvedDate = null; 
	rs.updateDate("approved_date", approvedDate);
	rs.updateString("comments", comments);
	rs.updateString("description", description);
	rs.updateString("status", status);
	rs.updateString("result", result);
	rs.updateDouble("days_added", daysAdded);
	rs.updateInt("to_id", toId);
	rs.updateInt("co_id", coId);
	if (id == null) {
		rs.updateInt("job_id", attr.getJobId());
		rs.insertRow();
		rs.last();
		id = rs.getString("cr_id");
		ItemLogger.Created.update(com.sinkluge.Type.CR, id, session);
		out.println("parent.left.location = \"crLeft.jsp?id=" + id + "\";");
	} else {
		rs.updateRow();
		ItemLogger.Updated.update(com.sinkluge.Type.CR, id, session);
	}
	if (rs != null) rs.getStatement().close();
	Accounting acc = AccountingUtils.getAccounting(session);

	if (attr.hasAccounting()) {
		try {
			cr = AccountingUtils.getCr(id);
			cr.setOld(oldCr);
			accResult = acc.updateCR(cr);
			if (!EnumSet.of(Action.CREATED, Action.UPDATED).contains(accResult.getAction()))
				msg += "Accounting (CR): " + accResult.getMessage() + "<br>";
		} catch (Exception e) {
			msg += "Accounting (CR): ERROR - " + e.getMessage() + "<br>";
			log.error("Problem saving change request.", e);
		}
	}
	sql = "select * from change_request_detail where cr_id = " + id;
	rs = db.dbQuery(sql, true);
	String crdId, desc, ccId, conId;
	int pos;
	while (rs.next()) {
		crdId = rs.getString("crd_id");
		if (attr.hasAccounting()) oldCrd = AccountingUtils.getCRD(crdId, oldCr, acc);
		desc = request.getParameter("work_description_CD" + crdId);
		if (log.isDebugEnabled()) log.debug("checking CRD: " + crdId + " desc: " + desc);
		if (desc == null && sec.ok(Security.CO, Security.DELETE)) {;
			if (attr.hasAccounting()) {
				Result del = acc.deleteCRD(oldCrd);
				if (del.getAction().equals(Action.DELETED)) {
					rs.deleteRow();
					ItemLogger.Deleted.update(com.sinkluge.Type.CRD, crdId, session);
				} else msg += "Accounting (Detail): " + del.getMessage() + "<br/>";
			} else {
				rs.deleteRow();
				ItemLogger.Deleted.update(com.sinkluge.Type.CRD, crdId, session);
			}
		} else {
			rs.updateString("work_description", desc);
			rs.updateString("amount", DataUtils.decimal(request.getParameter("amount_CD" + crdId)));
			rs.updateString("bonds", DataUtils.decimal(request.getParameter("bonds_CD" + crdId)));
			rs.updateString("fee", DataUtils.decimal(request.getParameter("fee_CD" + crdId)));
			if (!"Approved".equals(status)) rs.updateBoolean("authorization", false);
			rs.updateRow();
			ItemLogger.Updated.update(com.sinkluge.Type.CRD, crdId, session);
			if (attr.hasAccounting()) {
				try {
					crd = AccountingUtils.getCRD(crdId, cr, acc);
					crd.setOld(oldCrd);
					accResult = acc.updateCRD(crd);
					log.debug("CRD Result: " + accResult.getMessage());
					if (!EnumSet.of(Action.CREATED, Action.UPDATED).contains(accResult.getAction()))
						msg += "Accounting (Detail): " + accResult.getMessage()+ "<br/>";
				} catch (Exception e) {
					log.error("Problem saving detail to accounting", e);
					msg += "Accouting (Detail): ERROR " + e.getMessage() + "<br/>";
				}
			}
		}
	}
	String ids;
	int newCount = Integer.parseInt(request.getParameter("count"));
	for (int i = 1; i <= newCount; i++) {
		rs.moveToInsertRow();
		ids = request.getParameter("sc_id" + i);
		if (ids != null) {
			pos = ids.indexOf("n");
			if (pos != -1) {
				conId = ids.substring(pos + 1);
				ccId = ids.substring(0, pos);
			} else {
				ccId = ids;
				conId = "0";
			}
			rs.updateInt("job_id", attr.getJobId());
			rs.updateString("cost_code_id", ccId);
			rs.updateString("contract_id", conId);
			rs.updateString("work_description", request.getParameter("work_description" + i));
			rs.updateString("amount", DataUtils.decimal(request.getParameter("amount" + i)));
			rs.updateString("bonds", DataUtils.decimal(request.getParameter("bonds" + i)));
			rs.updateString("fee", DataUtils.decimal(request.getParameter("fee" + i)));
			rs.updateString("cr_id", id);
			rs.insertRow();
			rs.last();
			ItemLogger.Created.update(com.sinkluge.Type.CRD, rs.getString("crd_id"), session);
			if (attr.hasAccounting()) {
				try {
					crd = AccountingUtils.getCRD(rs.getString("crd_id"), cr, acc);
					accResult = acc.updateCRD(crd);
					if (!EnumSet.of(Action.CREATED, Action.UPDATED).contains(accResult.getAction()))
						msg += "Accounting (Detail): " + accResult.getMessage()+ "<br/>";
				} catch (Exception e) {
					msg += "Accouting (Detail): ERROR " + e.getMessage() + "<br>";
					log.error("Problem saving change request detail.", e);
				}
			}
		}
	}
	msg += "Saved";
	out.println("parent.opener.location.reload();");
} else if (rs.first()) {
	num = rs.getInt("num");
	signedId = rs.getInt("signed_id");
	title = rs.getString("title");
	date = rs.getDate("date");
	submitDate = rs.getDate("submit_date");
	approvedDate = rs.getDate("approved_date");
	description = rs.getString("description");
	comments = rs.getString("comments");
	status = rs.getString("status");
	result = rs.getString("result");
	daysAdded = rs.getDouble("days_added");
	toId = rs.getInt("to_id");
	coId = rs.getInt("co_id");
}
if (rs != null) rs.getStatement().close();
rs = null;
if (id == null) {
	if (request.getParameter("num") == null) {
		sql = "select max(num) from change_requests where job_id = " + attr.getJobId();
		rs = db.dbQuery(sql);
		if (rs.first()) num = rs.getInt(1) + 1;
		if (rs != null) rs.getStatement().close();
		sql = "select user_id from job_team where role = 'Project Manager' and job_id = " + attr.getJobId();
		rs = db.dbQuery(sql);
		if (rs.first()) signedId = rs.getInt(1);
		if (rs != null) rs.getStatement().close();
	}
}
out.print("var slbutton = parent.left.document.getElementById(\"save\");");
if ("Approved".equals(status)) out.print("slbutton.disabled = true; slbutton.value='Save';");
else out.print("slbutton.disabled = false; slbutton.value='Save';");
%>
</script>
</head>
<body>
<div class="title">Change Request</div><hr>
<%= !"".equals(msg) ? "<div class=\"red bold\">" + msg.replaceAll("\n", " ") + "</div><hr>" : "" %>
<form id="cr" method="POST"	onsubmit="return save();">
<table>
<tr>
<td class="lbl">CR #</td>
<td><input type="text" size="8" name="num" value="<%= num %>" onchange="changed=true;" <%= FormHelper.dis(id != null) %>></td>
<td class="lbl">ID</td>
<td><%= id == null ? "" : com.sinkluge.utilities.Widgets.logLinkWithId(id, com.sinkluge.Type.CR, "parent", request) 
	+ "<input type=\"hidden\" name=\"id\" value=\"" + id + "\">" %></td>
</tr>
<tr>
<td class="lbl"><div class="link" onclick="insertDate('date');">Date</div></td>
<td><input type="text" id="date" name="date" value="<%= FormHelper.date(date) %>" maxlength=10 size=8 onchange="changed=true;">
	<img id="caldate" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
<td class="lbl"><div class="link" onclick="insertDate('submit_date');">Submit Date</div></td>
<td><input type="text" id="submit_date" name="submit_date" value="<%= FormHelper.date(submitDate) %>" maxlength=10 size=8 onchange="changed=true;">
	<img id="calsubmit_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
</tr>
<tr>
<td class="lbl">Status</td>
<td><select name="status" onchange="statusChange();">
	<option value="Estimating" <%= FormHelper.sel("Estimating", status) %>>Estimating</option>
	<option value="Under Review" <%= FormHelper.sel("Under Review", status) %>>Under Review</option>
	<option value="Approved" <%= FormHelper.sel("Approved", status) %>>Approved</option>
	<option value="Dropped" <%= FormHelper.sel("Dropped", status) %>>Dropped</option>
	</select>
</td>
<td class="lbl">Result</td>
<td><select name="result" onchange="changed=true;">
	<option value="Cost Change" <%= FormHelper.sel("Cost Change", result) %>>Cost Change</option>
	<option value="No Cost Change" <%= FormHelper.sel("No Cost Change", result) %>>No Cost Change</option>
	<option value="T&M Basis" <%= FormHelper.sel("T&M Basis", result) %>>T&amp;M Basis</option>
	</select>
</td>
</tr>
<tr>
<td class="lbl">Signed By</td>
<td><%= com.sinkluge.utilities.Widgets.userList(signedId, "signed_id", "onchange=\"changed=true;\"") %>
</td>
<td class="lbl"><div class="link" onclick="insertDate('approved_date');">Approved</div></td>
<td><input type="text" id="approved_date" name="approved_date" value="<%= FormHelper.date(approvedDate) %>" maxlength=10 size=8 onchange="changed=true;">
	<img id="calapproved_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
</tr>
<tr>
<td class="lbl">CO</td>
<td colspan="3"><select name="co_id">
	<option value="0">---</option>
<%
sql = "select * from change_orders where job_id = " + attr.getJobId();
rs = db.dbQuery(sql);
int temp;
while (rs.next()) {
	temp = rs.getInt("co_id");
	out.print("<option value=\"" + temp + "\" " + FormHelper.sel(temp, coId) + ">"
		+ rs.getString("co_num") + ": " + rs.getString("co_description") + "</option>");
}
if (rs != null) rs.getStatement().close();
rs = null;
%>
</select></td>
</tr>
<tr>
<td class="lbl">Title</td>
<td colspan="3"><input type="text" size="80" name="crTitle" value="<%= title %>"></td>
</tr>
<tr>
<td class="lbl"><div class="link" onclick="edit('description');">Description</div></td>
<td colspan=3"><textarea id="description" name="description" rows="4" cols="80" onchange="changed=true;"><%= description %></textarea></td>
</tr>
<tr>
<td class="lbl">To</td>
<td colspan="3"><select name="to_id" onchange="changed=true;">
<%
sql = "select job_contact_id, company_name, name, type, isDefault from job_contacts join company on "
	+ "job_contacts.company_id = "
	+ "company.company_id left join contacts on job_contacts.contact_id = contacts.contact_id where job_id = "
	+ attr.getJobId() + " and (type = 'Architect' or type = 'Owner') order by company_name, name";
rs = db.dbQuery(sql);
while (rs.next()) {
	temp = rs.getInt("job_contact_id");
	if (id == null) out.println("<option value=\"" + temp + "\" " + 
		FormHelper.sel(submitTo.equals(rs.getString("type")) && rs.getBoolean("isDefault")) + ">" + rs.getString("type") + ": " +
		rs.getString("company_name") + (rs.getString("name") != null ? ", " + rs.getString("name") : ""));
	else out.println("<option value=\"" + temp + "\" " + FormHelper.sel(temp, toId) + ">" 
		+ rs.getString("type") + ": " +
		rs.getString("company_name") + (rs.getString("name") != null ? ", " + rs.getString("name") : ""));
}
if (rs != null) rs.getStatement().close();
rs = null;
%>
</select>
</tr>
<tr>
<td colspan="4">
<fieldset style="padding: 8px;">
<legend>Detail</legend>
<%= !"Approved".equals(status) ? "<div class=\"link\" onclick=\"addItem();\" id=\"addLink\">Add</div>" : "" %>
<input type="hidden" name="count" id="count" value="0">
<div id="tableDiv" style="border-left: 1px solid gray;">
<table cellspacing="0" cellpadding="3" id="detail">
<tr>
	<%= sd ? "<td class=\"head\">Delete</td>" : "" %>
	<%= sw ? "<td class=\"head\">Edit</td>" : "" %>
	<td class="head" style="white-space: nowrap;">CA #</td>
	<td class="head">Brief Description</td>
	<td class="head aright">Amount</td>
	<td class="head aright">Fee</td>
	<td class="head aright">Bond</td>
	<td class="head aright">ID</td>
</tr>
<%
int count = 0;
if (id != null) {
	sql = "select crd.*, jcd.cost_code_id, cost_code, phase_code, division, code_description, company_name from "
		+ "change_request_detail as crd left join job_cost_detail as jcd using(cost_code_id) left join contracts "
		+ "using(contract_id) left join company using(company_id) where cr_id = " + id 
		+ " order by costorder(division), costorder(cost_code), costorder(phase_code)";
	rs = db.dbQuery(sql);
	String crdId;
	while (rs.next()) {
		count++;
		crdId = rs.getString("crd_id");
		out.println("<script>idUsed[idUsed.length] = \"" + rs.getString("cost_code_id") +
			(rs.getInt("contract_id") != 0 ? "n" + rs.getString("contract_id") : "") + "\";</script>");
%>
<tr id="CD<%= crdId %>">
	<%= sd ? "<td rowspan=\"2\" class=\"it\">" + ("Approved".equals(status) ? "&nbsp;" : "<div class=\"link\" "
		+ "onclick=\"removeRow2(this);\">Delete</div>") + "</td>" : "" %>
	<%= sw ? "<td rowspan=\"2\"class=\"right\"><div class=\"link\" onclick=\"editCD(" +
			crdId + ");\">Edit</div></td>" : "" %>
	<td class="it" rowspan="2"><%= rs.getBoolean("authorization") ? 
			rs.getString("change_auth_num") : "&nbsp;" %></td>
	<td class="it" style="white-space: nowrap; border-bottom: 0;"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-"
		+ rs.getString("phase_code") + " " + rs.getString("code_description")
		+ (rs.getString("company_name") == null ? "" : ": " + rs.getString("company_name")) %></td>
</tr>
<tr id="CD<%= crdId %>2">
	<td class="inputleft"><input type="text" name="work_description_CD<%= crdId %>" 
		value="<%= rs.getString("work_description") %>" onchange="changed=true;"></td>
	<td class="inputright"><input class="aright" type="text" name="amount_CD<%= crdId %>" size="6"
		value="<%= FormHelper.cur(rs.getDouble("amount")) %>" onchange="updateFees();"></td>
	<td class="inputright"><input class="aright" type="text" name="fee_CD<%= crdId %>" size="6"
		value="<%= FormHelper.cur(rs.getDouble("fee")) %>" onchange="updateFees();"></td>
	<td class="inputright"><input class="aright" type="text" name="bonds_CD<%= crdId %>" size="6"
		value="<%= FormHelper.cur(rs.getDouble("bonds")) %>" onchange="updateFees();"></td>
	<td class="it aright">CD<%= crdId %></td>
</tr>
<%
	}
}
%>
</table>
<script>
<%
if (id == null) {
	out.println("addItem();");
	count++;
}
%>
	detailCount = <%= count %>;
	if (detailCount > 0) {
		var td = document.getElementById("tableDiv");
		td.style.overflowX = "scroll";
		td.style.borderRight = "1px solid gray";
	}
</script>
</div>
</fieldset>
</td>
</tr>
<tr>
<td style="padding: 0px;" colspan="4">
	<table>
	<tr>
	<td class="lbl">Days Added</td>
	<td><input type="text" size="8" name="days_added" value="<%= daysAdded %>" onchange="changed=true;"></td>
	<td class="lbl" style="width: 50px;">Fees</td>
	<td id="fees">0.00</td>
	<td class="lbl" style="width: 50px;">Bonds</td>
	<td id="bonds">0.00</td>
	</tr>
	<tr>
	<td class="lbl" colspan="3">Total</td>
	<td id="total" class="bold" colspan="3">0.00</td>
	</table>
</td>
</tr>
<tr>
<td class="lbl"><div class="link" onclick="edit('comments');">Comments</div></td>
<td colspan=3"><textarea id="comments" name="comments" rows="4" cols="80" onchange="changed=true;"><%= 
	FormHelper.string(comments) %></textarea></td>
</tr>
</table>
</form>
<script>
	document.getElementById("tableDiv").style.width = (document.body.clientWidth - 
		document.getElementById("tableDiv").offsetLeft - 15) + "px";
	var cr = document.getElementById("cr");
	updateFees();
	changed = false;
	cr.crTitle.focus();
	cr.crTitle.select();
	cr.crTitle.spell = true;
	cr.crTitle.required = true;
	cr.crTitle.eName = "Title";
	cr.description.spell = true;
	cr.description.required = true;
	cr.description.eName = "Description";
	cr.num.required = true;
	cr.num.eName = "CR #";
	cr.num.isFloat = true;
	cr.date.isDate = true;
	cr.date.eName = "Date";
	cr.date.required = true;
	cr.submit_date.isDate = true;
	cr.submit_date.eName = "Submit Date";
	cr.approved_date.isDate = true;
	cr.approved_date.eName = "Approved";
	cr.days_added.isFloat = true;
	cr.days_added.eName = "Days Added";
	cr.comments.spell = true;
</script>
<%
db.disconnect();
%>
</body>
</html>