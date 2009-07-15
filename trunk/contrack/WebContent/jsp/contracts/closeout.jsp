<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<%
JSONRPCBridge.registerClass("closeout", com.sinkluge.JSON.CloseoutJSON.class);
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/table.js"></script>
	<script src="../utils/jsonrpc.js"></script>
	<script>
		var jsonrpc = new JSONRpcClient("../JSON-RPC");
		function update(controlId){
			jsonrpc.closeout.update(controlId.name, controlId.value, controlId.type == "checkbox"); 
		}
		function doWarranty(id) {
			printWin("../utils/print.jsp?doc=subWarranty?id=" + id);
		}
		function doCloseout(id) {
			printWin("../utils/print.jsp?doc=subCloseout?id=" + id);
		}
		function printWin(loc) {
			var msgWin = window.open(loc, "print");
			msgWin.focus();
		}
		function openBox(obj) {
			obj.parentNode.parentNode.tempClassName = obj.parentNode.parentNode.oldClassName;
			obj.style.height = "80px";
			obj.onblur = closeBox;
		}
		function closeBox(e) {
			if (e) var box = e.target;
			else var box = window.event.srcElement;
			box.style.height = "20px";
			update(box);
			box.onblur = null;
		}
	</script>
	<style>
		td {
			padding-left: 3px;
			padding-right: 3px;
		}
		textarea {
			padding-left: 2px;
			background: transparent;
			border-color: gray;
			height: 20px;
		}
		td.head1 {
			font-weight: bold;
			border-top: 1px solid gray;
			background-color: #FFFFCC;
		}
		td.head2 {
			font-weight: bold;
			border-bottom: 1px solid gray;
			background-color: #FFFFCC;
		}
		td.left1 {
			border-left: 1px solid gray;
		}
		td.right1 {
			border-right: 1px solid gray;
		}
	</style>
</head>
<body>
<form name="closeoutForm">
<div class="title">Subcontract Closeout</div><hr>
<div class="link" onclick="window.location='closeoutRecipients.jsp';">Send/Print Documents</div>
<hr>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
			<td colspan=2 class="left1 head1">&nbsp;</td>
			<td colspan=2 class="head1">&nbsp;</td>
			<td colspan=2 class="acenter head1" style="background-color: #DCDCDC">Subm'tl</td>
			<td colspan=2 class="acenter head1">Wrnty</td>
			<td colspan=2 class="acenter head1" style="background-color: #DCDCDC">Train</td>
			<td class="acenter head1">Lien</td>
			<td colspan=3 class="head1 right1">&nbsp;</td>
		</tr>
	<tr>
			<td class="left head2 nosort">Closeout</td>
			<td class="head2 nosort">Warranty</td>
			<td class="head2">Code</td>
			<td class="head2">Company</td>
			<td class="acenter head2" style="background-color: #DCDCDC">N</td>
			<td class="acenter head2" style="background-color: #DCDCDC">H</td>
			<td class="acenter head2">N</td>
			<td class="acenter head2">H</td>
			<td class="acenter head2" style="background-color: #DCDCDC">N</td>
			<td class="acenter head2" style="background-color: #DCDCDC">H</td>
			<td class="acenter head2">H</td>
			<td class="head2">Specialty</tb>
			<td class="acenter head2">H</td>
			<td class="head2 right">Notes</td>
		</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
String query = "select contract_id, division, cost_code, phase_code, left(company.company_name,30) as name, req_tech_submittals, have_tech_submittals, "
	+ "req_warranty, have_warranty, req_owner_training, have_owner_training, have_lien_release, req_specialty, have_specialty, tracking_notes from "
	+ "contracts, job_cost_detail as jcd, company where contracts.company_id = company.company_id and contracts.job_id = " 
	+ attr.getJobId() + " and contracts.cost_code_id = jcd.cost_code_id order by costorder(division), costorder(cost_code), phase_code";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String contractId, reqSub, haveSub, reqWar, haveWar, reqTrain, haveTrain, haveLien, reqSpecialty, haveSpecialty, notes;
boolean color = true;
while(rs.next()) {
	color = !color;
	contractId = rs.getString("contract_id");
	reqSub = rs.getString("req_tech_submittals");
	haveSub = rs.getString("have_tech_submittals");
	reqWar = rs.getString("req_warranty");
	haveWar = rs.getString("have_warranty");
	reqTrain = rs.getString("req_owner_training");
	haveTrain = rs.getString("have_owner_training");
	haveLien = rs.getString("have_lien_release");
	reqSpecialty = rs.getString("req_specialty");
	if(reqSpecialty == null) reqSpecialty = "";
	haveSpecialty = rs.getString("have_specialty");
	notes = rs.getString("tracking_notes");
	if(notes == null) notes = "";
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
			<td class="left"><div class="link" onclick="doCloseout(<%= contractId %>);">Closeout</div></td>
			<td class="right"><div class="link" onclick="doWarranty(<%= contractId %>);">Warranty</div></td>
			<td class="it aright"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
			<td class="it"><%= rs.getString("name") %></td>
			<td class="input" style="background-color: #DCDCDC"><input type="checkbox" title="Require Submittal" <% if (reqSub.equals("y")) out.println("checked"); %> onClick="update(this)" name="rS<%= contractId %>" value="y"></td>
			<td class="input" style="background-color: #DCDCDC"><input type="checkbox" title="Have Submittal" <% if (haveSub.equals("y")) out.println("checked"); %> onClick="update(this)" name="hS<%= contractId %>" value="y"></td>
			<td class="input"><input type="checkbox" title="Require Warranty" <% if (reqWar.equals("y")) out.println("checked"); %> onClick="update(this)" name="rW<%= contractId %>" value="y"></td>
			<td class="input"><input type="checkbox" title="Have Warranty" <% if (haveWar.equals("y")) out.println("checked"); %> onClick="update(this)" name="hW<%= contractId %>" value="y"></td>
			<td class="input" style="background-color: #DCDCDC"><input title="Require Training" type="checkbox" <% if (reqTrain.equals("y")) out.println("checked"); %> onClick="update(this)" name="rT<%= contractId %>" value="y"></td>
			<td class="input" style="background-color: #DCDCDC"><input title="Have Training" type="checkbox" <% if (haveTrain.equals("y")) out.println("checked"); %> onClick="update(this)" name="hT<%= contractId %>" value="y"></td>
			<td class="input acenter"><input title="Have Lien Waiver" type="checkbox" <% if (haveLien.equals("y")) out.println("checked"); %> onClick="update(this)" name="hL<%= contractId %>" value="y"></td>
			<td class="input"><textarea title="Specialty" style="border-style: solid; border-width: 1;" onfocus="openBox(this);" name="rP<%= contractId %>"><%= reqSpecialty %></textarea></td>
			<td class="input"><input title="Have Specialty" type="checkbox" <% if (haveSpecialty.equals("y")) out.println("checked"); %> onClick="update(this)" name="hP<%= contractId %>" value="y"></td>
			<td class="input right"><textarea title="Comments" style="border-style: solid; border-width: 1" onfocus="openBox(this);" name="tN<%= contractId %>"><%= notes %></textarea></td>
		</tr>
<%
}
rs.close();
db.disconnect();
%>
</table>
</div>
</body>
</html>