<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet,com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission, java.sql.Date" %>
<%@page import="com.sinkluge.utilities.DateUtils,com.sinkluge.utilities.DataUtils"  %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Accounting, accounting.CR, accounting.CRD,
	accounting.Result, accounting.Action, java.util.EnumSet" %>
<%@page import="com.sinkluge.utilities.ItemLogger" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<%
if (!sec.ok(Name.CHANGES, Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
JSONRPCBridge.registerClass("verify", com.sinkluge.JSON.Verify.class);
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
<script>
	function edit(field) {
		openWin("textarea.jsp?id=" + field, 600, 500);
	}
	function openWin(loc, x, y) {
		var msgWindow = open(loc, "edit2", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
			+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
		if (msgWindow.opener == null) msgWindow.opener = self;
		msgWindow.focus();
	}
	var changed = false;
	function spell() {
		spellCheck(crd);
	}
	var jsonrpc = new JSONRpcClient("../JSON-RPC");
	function save() {
		if (crd.authorization && crd.authorization.checked) {
			crd.sent_date.isDate = true;
			crd.sent_date.eName = "Sent Date";
			crd.change_auth_num.isInt = true;
			crd.change_auth_num.eName = "CA #";
			crd.change_auth_num.required = true;
		}
		if (checkForm(crd)) {
			if (crd.authorization && crd.authorization.checked) {
				try {
					var result = jsonrpc.verify.cDNum(crd.change_auth_num.value, crd.id.value);
					if (!result) {
						changed = false;
						crd.sc_id.disabled = false;
						crd.change_auth_num.disabled = false;
						crd.submit();
						return true;
					} else { 
						if (result.indexOf("approved") != -1) {
							window.alert("ERROR\n------------------------\nCannot create authorization.\n"
								+ result);
						} else {
							window.alert("ERROR\n------------------------\nDuplicate CA #. The number is already "
								+ "used on:\n" + result + ".");
							crd.change_auth_num.style.backgroundColor = "#FFFFCC";
						}
						return false;
					}
				} catch (e) {
					window.alert(e);
					return false;
				}
			} else {
				changed = false;
				crd.submit();
				return true;
			}
		} else return false;
	}
	function auth() {
		if (crd.authorization) {
			if (crd.change_auth_num.value * 1 == 0 ) {
				var result = jsonrpc.verify.getNextCANum();
				crd.change_auth_num.value = result;
			}
			var div = document.getElementById("auth");
			if (crd.authorization.checked) div.style.visibility = "visible";
			else div.style.visibility = "hidden";
		}
	}
	function updateFees(e) {
		changed = true;
		if (crd.fee) {
			var total = 0;
			var elem;
			for (var i = 0; i < crd.length; i++) {
				elem = crd.elements[i];
				if (elem.name) {
					if (elem.name.indexOf("amount") != -1) total += parseNum(elem);
					else if (elem.name.indexOf("fee") != -1) total += parseNum(elem);
					else if (elem.name.indexOf("bond") != -1) total += parseNum(elem);
				}
			}
			document.getElementById("total").innerHTML = formatNum(total);
		}
	}
	function parseNum(elem) {
		var val;
		try {
			val = elem.value;
			if (val == null) val = "";
			var c;
			for (var i = 0; i < val.length; i++) {
				c = val.charAt(i);
				if (c == ",") val = val.substring(0,i) + val.substring(i+1);
			}
			val = parseFloat(val);
		} catch (e) {
			val = 0;
		}
		elem.value = formatNum(val);
		return val;
	}
	function formatNum(num) {
		var nStr = num.toFixed(2);
		nStr += "";
		x = nStr.split(".");
		x1 = x[0];
		x2 = x.length > 1 ? "." + x[1] : "";
		var rgx = /(\d+)(\d{3})/;
		while (rgx.test(x1)) {
			x1 = x1.replace(rgx, '$1' + "," + '$2');
		}
		return x1 + x2;
	}
<%
boolean auth = false;
String crInfo = null;
String scId = request.getParameter("sc_id");
String comments = null;
String workDescription = request.getParameter("work_description");
int contractId = 0;
Date sentDate = null, created = null;
int changeAuthNum = 0;
int subCANum = 0;
Result accResult;
boolean approvedCr = false;
double amount = 0, fee = 0, bonds = 0;
Database db = new Database();
String sql = "select * from change_request_detail where crd_id = " + id;
ResultSet rs = db.dbQuery(sql, true), rs2 = null;
String msg = null;
CRD crd = null, oldCrd = null;
if (workDescription != null && sec.ok(Name.CHANGES, Permission.READ)) {
	scId = request.getParameter("sc_id");
	String conId = null;
	String ccId= null;
	if (scId != null) {
		int pos = scId.indexOf("n");
		if (pos != -1) {
			conId = scId.substring(pos + 1);
			ccId = scId.substring(0, pos);
		} else {
			ccId = scId;
			conId = "0";
		}
		contractId = Integer.parseInt(conId);
	}
	comments = request.getParameter("comments");
	try { amount = Double.parseDouble(request.getParameter("amount")); } 
	catch (Exception  e) { amount = 0; }
	try { fee = Double.parseDouble(request.getParameter("fee")); } 
	catch (Exception  e) { fee = 0; }
	try { bonds = Double.parseDouble(request.getParameter("bonds")); } 
	catch (Exception e) { bonds = 0; }
	auth = request.getParameter("authorization") != null;
	if (auth) {
		sentDate = DateUtils.getSQLShort(request.getParameter("sent_date"));
		changeAuthNum = Integer.parseInt(request.getParameter("change_auth_num"));
	} else {
		sentDate = null;
		changeAuthNum = 0;
	}
	Accounting acc = null;
	if (attr.hasAccounting()) acc = AccountingUtils.getAccounting(session); 
	if (!rs.first()) {
		rs.moveToInsertRow();
		rs.updateInt("job_id", attr.getJobId());
		rs.updateDate("created", new Date(System.currentTimeMillis()));
	} else {
		if (attr.hasAccounting()) oldCrd = AccountingUtils.getCRD(id, acc);
	}
	sql = "select num, title, status from change_requests where cr_id = " + rs.getString("cr_id");
	rs2 = db.dbQuery(sql);
	if (rs2.next()) {
		crInfo = rs2.getString("num") + ": " + rs2.getString("title");
		approvedCr = "Approved".equals(rs2.getString("status"));
	}
	if (rs2 != null) rs2.getStatement().close();
	if (!auth) rs.updateInt("sub_ca_num", 0);
	else if (rs.getInt("sub_ca_num") == 0) {
		rs2 = db.dbQuery("select max(sub_ca_num) from change_request_detail "
				+ "where contract_id = " + conId);
		if (rs2.first()) subCANum = rs2.getInt(1) + 1;
		rs.updateInt("sub_ca_num", subCANum);
		if (rs2 != null) rs2.getStatement().close();
	} else subCANum = rs.getInt("sub_ca_num");
	rs.updateDate("sent_date", sentDate);
	rs.updateInt("change_auth_num", changeAuthNum);
	rs.updateString("work_description", workDescription);
	rs.updateString("comments", comments);
	rs.updateBoolean("authorization", auth);
	if (!approvedCr) {
		if (scId != null) {
			rs.updateString("cost_code_id", ccId);
			rs.updateString("contract_id", conId);
		}
		rs.updateDouble("amount", amount);
		rs.updateDouble("fee", fee);
		rs.updateDouble("bonds", bonds);
	} else {
		ccId = rs.getString("cost_code_id");
		conId = rs.getString("contract_id");
		amount = rs.getDouble("amount");
		fee = rs.getDouble("fee");
		bonds = rs.getDouble("bonds");
	}
	if (id == null) {
		rs.insertRow();
		rs.last();
		id = rs.getString("crd_id");
		ItemLogger.Created.update(com.sinkluge.Type.CRD, id, session);
		out.println("parent.left.location = \"crdLeft.jsp?id=" + id + "\";");
	} else {
		rs.updateRow();
		ItemLogger.Updated.update(com.sinkluge.Type.CRD, id, session);
		out.println("parent.left.location.reload();");
	}
	if (attr.hasAccounting()) {
		crd = AccountingUtils.getCRD(id, acc);
		crd.setOld(oldCrd);
		accResult = acc.updateCRD(crd);
		log("CRD Save: " + accResult.getMessage());
		if (!EnumSet.of(Action.CREATED, Action.UPDATED).contains(accResult.getAction()))
			msg = "Accounting: " + accResult.getMessage();
	}
%>
	if (parent.opener.changed) parent.opener.changed = false;
	parent.opener.reloadc();
<%
	msg = "Saved " + (msg == null ? "" : "<br/>" + msg);
} else if (rs.first()) {
	sql = "select num, title, status from change_requests where cr_id = " + rs.getString("cr_id");
	rs2 = db.dbQuery(sql);
	if (rs2.next()) {
		crInfo = rs2.getString("num") + ": " + rs2.getString("title");
		approvedCr = "Approved".equals(rs2.getString("status"));
	}
	if (rs2 != null) rs2.getStatement().close();
	contractId = rs.getInt("contract_id");
	scId = rs.getString("cost_code_id");
	if (contractId != 0) scId += "n" + contractId;
	workDescription = rs.getString("work_description");
	comments = rs.getString("comments");
	auth = rs.getBoolean("authorization");
	sentDate = rs.getDate("sent_date");
	created = rs.getDate("created");
	changeAuthNum = rs.getInt("change_auth_num");
	amount = rs.getDouble("amount");
	bonds = rs.getDouble("bonds");
	fee = rs.getDouble("fee");
	subCANum = rs.getInt("sub_ca_num");
}
%>
</script>
</head>
<body>
<form id="crd" method="POST" onsubmit="return save();">
<div class="title"><%= auth || id == null ? "Change Authorization" : 
	"Change Request Detail" %></div><hr>
<%= msg != null ? "<div class=\"red bold\">" + msg + "</div><hr>" : "" %>
<%= id != null ? "<input type=\"hidden\" name=\"id\" value=\"" + id + "\">" : "" %>
<table>
<%
if (id != null) {
%>
<tr>
<td class="lbl">ID</td>
<td><%= com.sinkluge.utilities.Widgets.logLinkWithId(id, com.sinkluge.Type.CRD, "parent", request) %></td>
</tr>
<%
}
if (crInfo != null) {
%>
<tr>
<td class="lbl">CR</td>
<td colspan="3" class="bold"><%= crInfo %></td>
</tr>
<%
}
%>
<tr>
<td class="lbl">Code/Sub</td>
<td><select name="sc_id" <%= FormHelper.dis(id != null) %>>
<%
if (id == null || auth) {
	sql = "select contract_id, cost_code_id, division, cost_code, phase_code, "
		+ "code_description, company_name from contracts join job_cost_detail as jcd "
		+ "using(cost_code_id) join company using(company_id) where contracts.job_id = " 
		+ attr.getJobId() + " order by costorder(division), costorder(cost_code), "
		+ "costorder(phase_code)";
} else {
	sql = "select contract_id, cost_code_id, division, cost_code, phase_code, code_description, company_name from "
		+ "job_cost_detail as jcd left join contracts using(cost_code_id) left join company using(company_id) "
		+ "where jcd.job_id = " + attr.getJobId() + " order by costorder(division), costorder(cost_code), "
		+ "costorder(phase_code)";
}
rs = db.dbQuery(sql);
String tempId;
String temp;
while (rs.next()) {
	tempId = rs.getString("cost_code_id");
	temp = rs.getString("code_description") == null ? "" : rs.getString("code_description");
	if (rs.getInt("contract_id") != 0) tempId += "n" + rs.getString("contract_id");
	out.println("<option value=\"" + tempId + "\" " + FormHelper.sel(tempId, scId) + ">" + rs.getString("division") 
			+ " " + rs.getString("cost_code") + " " + rs.getString("phase_code") + " " 
			+ temp.replaceAll("'","") + (rs.getInt("contract_id") == 0 ? "" : ": " 
			+ rs.getString("company_name").replaceAll("'","")) + "</option>");
}
if (rs != null) rs.getStatement().close();
%>
	</select></td>
</tr>
<%
if (created != null) {
%>
<tr>
	<td class="lbl">Created</td>
	<td><%= FormHelper.medDate(created) %></td>
</tr>
<%	
}
%>
<tr>
<td class="lbl"><div class="link" onclick="edit('work_description');">Work Description</div></td>
<td colspan=3"><textarea id="work_description" name="work_description" rows="4" cols="80" 
	onchange="changed=true;"><%= FormHelper.string(workDescription) %></textarea></td>
</tr>
<tr>
<td colspan="4">
<fieldset style="padding: 8px;">
<legend>Details</legend>
<table>
<%
if (contractId != 0 || id == null) {
%>
<tr>
<%
	if (crInfo == null) {
%>
<td colspan="2"><div style="visibility: hidden;"><input type="checkbox" 
	name="authorization" value="true" checked></div></td>
<%
	} else {
%>
<td class="lbl">Authorization</td>
<td><input type="checkbox" name="authorization" value="true" <%= FormHelper.chk(auth) %> 
	onclick="auth();"></td>
<%
	}
%>
<td rowspan="4">
<div id="auth">
<table>
<tr>
<td class="lbl">CA #</td>
<td><input type="text" name="change_auth_num" size="6" value="<%= changeAuthNum %>" 
	onchange="changed=true;" <%= FormHelper.dis(id != null) %>></td>
</tr>
<tr>
<td class="lbl"><div class="link" onclick="insertDate('sent_date');">Sent</div></td>
<td><input type="text" id="sent_date" name="sent_date"
	value="<%= FormHelper.date(sentDate) %>" maxlength=10 size=8 onchange="changed=true;">
	<img id="calsent_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
</tr>
<tr>
<td class="lbl" style="width: 75px; white-space: nowrap;">Sub CA #</td>
<td><%= subCANum == 0 ? "&nbsp;" : subCANum %></td>
</tr>
</table>
</div>
</td>
</tr>
<%
}
%>
<tr>
<td class="lbl">Amount</td>
<td><input type="text" class="aright" name="amount" value="<%= FormHelper.cur(amount) %>" 
	onchange="updateFees();" size="6" <%= FormHelper.dis(approvedCr) %>></td>
</tr>
<%
if (crInfo != null) {
%>
<tr>
<td class="lbl">Fee</td>
<td><input type="text" class="aright" name="fee" value="<%= FormHelper.cur(fee) %>" 
	onchange="updateFees();" size="6" <%= FormHelper.dis(approvedCr) %>></td>
</tr>
<tr>
<td class="lbl">Bonds</td>
<td><input type="text" class="aright" name="bonds" value="<%= FormHelper.cur(bonds) %>" 
	onchange="updateFees();" size="6" <%= FormHelper.dis(approvedCr) %>></td>
</tr>
<tr>
<td class="lbl">Total</td>
<td><span id="total" class="bold"><%= FormHelper.cur(amount + bonds + fee) %></span></td>
</tr>
<%
}
%>
</table>
</fieldset>
</td>
</tr>
<tr>
<td class="lbl"><div class="link" onclick="edit('comments');">Comment</div></td>
<td colspan=3"><textarea id="comments" name="comments" rows="4" cols="80" 
	onchange="changed=true;"><%= FormHelper.string(comments) %></textarea></td>
</tr>
</table>
</form>
<script>
	var crd = document.getElementById("crd");
	auth();
	updateFees();
	changed = false;
	crd.work_description.spell = true;
	crd.work_description.required = true;
	crd.work_description.select();
	crd.work_description.focus();
	crd.work_description.eName = "Work Description";
	crd.amount.isFloat = true;
	crd.amount.eName = "Amount";
<%
if (crInfo != null) {
%>
	crd.fee.isFloat = true;
	crd.fee.eName = "Fee";
	crd.bonds.isFloat = true;
	crd.bonds.eName = "Bonds";
<%
}
%>
	crd.comments.spell = true;
</script>
</body>
</html>
<%
db.disconnect();
%>