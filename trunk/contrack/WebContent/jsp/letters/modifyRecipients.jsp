<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.Verify"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="JSONRPCBridge" scope="session"
     class="org.jabsorb.JSONRPCBridge" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.LETTERS, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String letterId = request.getParameter("letter_id");
JSONRPCBridge.registerClass("search", com.sinkluge.JSON.Search.class); 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script src="../utils/jsonrpc.js"></script>
	<script src="scripts/letter.js"></script>
	<script>
		var hasFax = <%= in.hasFax %>;
		parent.left.location = "modifyRecipientsLeft.jsp?id=<%= letterId %>"
		try {
			var jsonrpc = new JSONRpcClient("<%= request.getContextPath() %>/jsp/JSON-RPC");
		} catch (e) {
			alert(e);
		}
		var surl = "processModifyRecipients.jsp?ids=";
		var letter_id = <%= request.getParameter("letter_id") %>;
	</script>
</head>
<body>
	<font size="+1">Modify Recipients</font><hr>
<table>
<tr>
<td class="vertical-align: top;" rowspan="<%= in.hasFax ? "3" : "2" %>">
<fieldset>
<legend>Select Recipients</legend>
<form onSubmit="return searchFormSubmit();" style="margin-bottom: 10px;">
<b>Search:</b> <input type="text" id="search" onKeyUp="searchFormSubmit();" size="7"> <input type="submit" value="Search">
</form>
<table cellspacing="0" cellpadding="3" id="searchTableHead">
<tr>
	<td class="left right head" colspan="2"><a href="javascript: selectAll();">Select All</a></td>
</tr>
</table>
<div class="table" id="searchTableDiv" style="height: 350px;">
<table cellspacing="0" cellpadding="3" id="searchTableProj">
<%
String query = "(select distinct company.company_id, contacts.contact_id, company_name, name, email, company.fax as cf, contacts.fax as nf "
	+ "from contracts join company using(company_id) left join contacts "
	+ "using(company_id) where job_id = " + attr.getJobId();
query += ") union (select company.company_id, contacts.contact_id, company_name, name, email, company.fax as cf, contacts.fax as nf "
	+ "from job_contacts join company using(company_id) left join contacts "
	+ "using(company_id) where job_id = " + attr.getJobId()	+ ") order by company_name, name";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
boolean color = true, eOK, fOK;
String email, fax;
int id, oldId = 0, contactId;
while (rs.next()) {
	contactId = rs.getInt("contact_id");
	id = rs.getInt("company_id");
	if (id != oldId) {
		color = !color;
		email = rs.getString("email");
		eOK = Verify.email(email);
		fax = rs.getString("cf");
		fOK = in.hasFax && Verify.phone(fax);
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left input"><%= contactId==0?"<input type=\"checkbox\" value=\"" + (contactId == 0 && fOK?"F":"") + "#C" +  id + "\">":"&nbsp;" %></td>
	<td class="right bold"><%= rs.getString("company_name") %> <%= (contactId == 0 && fOK?"F":"") %></td>
</tr>
<%
		if (contactId != 0) {
			color = !color;
			email = rs.getString("email");
			fax = rs.getString("nf");
			email = rs.getString("email");
			eOK = Verify.email(email);
			fax = rs.getString("cf");
			fOK = in.hasFax && Verify.phone(fax);
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left input"><input type="checkbox" value="<%= (eOK?"E":"") + (fOK?"F":"") %>#N<%= contactId %>"></td>
	<td class="right"><%= rs.getString("name") %> <%= (eOK?"E":"") + (fOK?"F":"") %></td>
</tr>
<%
		}
	} else {
		color = !color;
		email = rs.getString("email");
		fax = rs.getString("nf");
		email = rs.getString("email");
		eOK = Verify.email(email);
		fax = rs.getString("cf");
		fOK = in.hasFax && Verify.phone(fax);
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left input"><input type="checkbox" value="<%= (eOK?"E":"") + (fOK?"F":"") %>#N<%= contactId %>"></td>
	<td class="right"><%= rs.getString("name") %> <%= (eOK?"E":"") + (fOK?"F":"") %></td>
</tr>
<%
	}
	oldId = id;
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
<table cellspacing="0" cellpadding="3" id="searchTable" style="display: none;">
</table>
</div>
</fieldset>
</td>
<td style="height: <%= in.hasFax ? "33%" : "50%" %>;"><input type="button" value="Email-->" 
	onClick="add('email');"></td>
<td style="height: <%= in.hasFax ? "33%" : "50%" %>; vertical-align: top;">
<table cellspacing="0" cellpadding="3" id="emailTableHead">
<tr>
<td class="left right head" colspan="2">Email &nbsp; <a href="javascript: removeAll('email');">Remove All</a></td>
</tr>
</table>
<div class="table" id="emailTableDiv" style="height: <%= in.hasFax ? "100" : "180" %>px;">
<%
query = "select company.company_id, company_name, letter_contacts.contact_id, name from letter_contacts join "
	+ "company using(company_id) left join contacts using(contact_id) where letter_id = " + letterId
	+ " and method = 'Email' order by company_name, name";
rs = db.dbQuery(query);
%>
<table cellspacing="0" cellpadding="3" id="emailTableProj" <%= (rs.isBeforeFirst()?"style=\"display: none;\"":"") %>>
<tr>
<td class="left right bold acenter" style="width: 110px;" colspan="2">No recipients</td>
</tr>
</table>
<table cellspacing="0" cellpadding="3" <%= (rs.isBeforeFirst()?"":"style=\"display: none;\"") %> id="emailTable">
<%
color = true;
oldId = 0;
while (rs.next()) {
	id = rs.getInt("company_id");
	contactId = rs.getInt("contact_id");
	if (id != oldId) {
		color = !color;
		if (contactId == 0) {
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left"><a href="javascript: remove('email','C<%= id %>');">Remove</a></td>
	<td class="right bold"><input type="hidden" name="C<%= id %>" value="E"><%= rs.getString("company_name") %></td>
</tr>
<%
		} else {
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left">&nbsp;</td>
	<td class="right bold"><%= rs.getString("company_name") %></td>
</tr>
<%
		}
	}
	if (contactId != 0) {
		color = !color;
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left"><a href="javascript: remove('email','N<%= contactId %>');">Remove</a></td>
	<td class="right"><input type="hidden" name="N<%= contactId %>" value="E"><%= rs.getString("name") %></td>
</tr>
<%		
	}
	oldId = id;
}
query = "select company.company_id, company_name, letter_contacts.contact_id, name from letter_contacts join "
	+ "company using(company_id) left join contacts using(contact_id) where letter_id = " + letterId
	+ " and method = 'Fax' order by company_name, name";
rs = db.dbQuery(query);
%>
</table>
</div>
</td>
</tr>
<%
if (in.hasFax) {
%>
<tr>
<td style="height: 33%;"><input type="button" value="Fax-->" onClick="add('fax');"></td>
<td style="height: 33%; vertical-align: top;">
<table cellspacing="0" cellpadding="3" id="faxTableHead">
<tr>
<td class="left right head" colspan="2">Fax &nbsp; <a href="javascript: removeAll('fax');">Remove All</a></td>
</tr>
</table>
<div class="table" id="faxTableDiv" style="height: 110px;">
<table cellspacing="0" cellpadding="3" id="faxTableProj" <%= (rs.isBeforeFirst()?"style=\"display: none;\"":"") %>>
<tr>
<td class="left right bold acenter" style="width: 100px;" colspan="2">No recipients</td>
</tr>
</table>
<table cellspacing="0" cellpadding="3" <%= (rs.isBeforeFirst()?"":"style=\"display: none;\"") %> id="faxTable">
<%
color = true;
oldId = 0;
while (rs.next()) {
	id = rs.getInt("company_id");
	contactId = rs.getInt("contact_id");
	if (id != oldId) {
		color = !color;
		if (contactId == 0) {
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> id="C<%= id %>">
	<td class="left"><a href="javascript: remove('fax','C<%= id %>');">Remove</a></td>
	<td class="right bold"><input type="hidden" name="C<%= id %>" value="F"><%= rs.getString("company_name") %></td>
</tr>
<%
		} else {
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left">&nbsp;</td>
	<td class="right bold"><%= rs.getString("company_name") %></td>
</tr>
<%
		}
	}
	if (contactId != 0) {
		color = !color;
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> id="N<%= contactId %>">
	<td class="left"><a href="javascript: remove('fax','N<%= contactId %>');">Remove</a></td>
	<td class="right"><input type="hidden" name="N<%= contactId %>" value="F"><%= rs.getString("name") %></td>
</tr>
<%		
	}
	oldId = id;
}
%>
</table>
</div>
</td>
</tr>
<%
}
query = "select company.company_id, company_name, letter_contacts.contact_id, name from letter_contacts join "
	+ "company using(company_id) left join contacts using(contact_id) where letter_id = " + letterId
	+ " and method = 'Print' order by company_name, name";
rs = db.dbQuery(query);
%>
<tr>
<td style="height: <%= in.hasFax ? "33%" : "50%" %>;"><input type="button" value="Print-->"
	onClick="add('print');"></td>
<td style="height: <%= in.hasFax ? "33%" : "50%" %>; vertical-align: top;">
<table cellspacing="0" cellpadding="3" id="printTableHead">
<tr>
<td class="left right head" colspan="2">Print &nbsp; <a href="javascript: removeAll('print');">Remove All</a></td>
</tr>
</table>
<div class="table" id="printTableDiv" style="height: <%= in.hasFax ? "100" : "180" %>px;">
<table cellspacing="0" cellpadding="3" id="printTableProj" <%= (rs.isBeforeFirst()?"style=\"display: none;\"":"") %>>
<tr>
<td class="left right bold acenter" style="width: 100px;" colspan="2">No recipients</td>
</tr>
</table>
<table cellspacing="0" cellpadding="3" id="printTable" <%= (rs.isBeforeFirst()?"":"style=\"display: none;\"") %>>
<%
color = true;
oldId = 0;
while (rs.next()) {
	id = rs.getInt("company_id");
	contactId = rs.getInt("contact_id");
	if (id != oldId) {
		color = !color;
		if (contactId == 0) {
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left"><a href="javascript: remove('print','C<%= id %>');">Remove</a></td>
	<td class="right bold"><input type="hidden" name="C<%= id %>" value="P"><%= rs.getString("company_name") %></td>
</tr>
<%
		} else {
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %>>
	<td class="left">&nbsp;</td>
	<td class="right bold"><%= rs.getString("company_name") %></td>
</tr>
<%
		}
	}
	if (contactId != 0) {
		color = !color;
%>
<tr onMouseOver="bb(this);" onMouseOut="nn(this);" <% if (color) out.print("class=\"gray\""); %> title="<%= rs.getString("company_name") %>">
	<td class="left"><a href="javascript: remove('print','N<%= contactId %>');">Remove</a></td>
	<td class="right"><input type="hidden" name="N<%= contactId %>" value="P"><%= rs.getString("name") %></td>
</tr>
<%		
	}
	oldId = id;
}
%>
</table>
</div>
</td>
</tr>
</table>
<script>
	resizeHead("searchTable");
	resizeHead("emailTable");
	if (hasFax) resizeHead("faxTable");
	resizeHead("printTable");
	document.getElementById("search").focus();
	if (window.navigator.userAgent.indexOf("MSIE") != -1) {
		var fs = document.getElementsByTagName("FIELDSET");
		for (var i = 0; i < fs.length; i++) {
			fs[i].style.padding = "8px;"
		}
	}
</script>
</body>
</html>
<%
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>