<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="accounting.Accounting,com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Subcontract,accounting.Code" %>
<%@page import="com.sinkluge.utilities.ItemLogger"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.utilities.Widgets"%><html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="../stylesheets/v2.css">
<%= Widgets.fontSizeStyle(attr) %>
<script>
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
Database db = new Database();
int id = Integer.parseInt(request.getParameter("id"));
if (request.getParameter("company_id") != null) {
	if (attr.hasAccounting()) {
		Accounting acc = AccountingUtils.getAccounting(session);
		db.dbInsert("update contracts set company_id = " + request.getParameter("company_id")
			+ ", contact_id = " + request.getParameter("contact_id") + " where contract_id = " + id);
		ItemLogger.Updated.update(com.sinkluge.Type.SUBCONTRACT, request.getParameter("id"), 
			"Changed subcontract/purchase order company.", session);
		Subcontract sub = AccountingUtils.getSubcontract(id);
		if (sub.getAltCompanyId() != null) {
			acc.updateSubcontract(sub);
%>
	parent.opener.location.reload();
	window.location = "modifyContract.jsp?saved=t&id=<%= id %>";
<%
		} else {
%>
	parent.opener.location.reload();
	window.location = "processModifyContract2.jsp?id=<%= id %>";
<%
		}
	} else {
%>
	parent.opener.location.reload();
	window.location = "modifyContract.jsp?saved=t&id=<%= id %>";
<%	
	}
%>
</script>
<%
} else {
String name = request.getParameter("search");
ResultSet rs = db.dbQuery("select company_id from contracts where contract_id = " + id);
int companyId = 0;
if (rs.first()) companyId = rs.getInt(1);
rs.getStatement().close();
%>
	parent.left.location = "changeCompanyOnContractLeft.jsp?id=<%= id %>";
	function change(companyId, contactId, strikes) {
<%
rs = db.dbQuery("select count(*) from change_request_detail where contract_id = " + id);
if (rs.first() && rs.getInt(1) > 0) out.println ("var ca = " + rs.getInt(1) + ";");
else out.println("var ca = 0;");
rs.getStatement().close();
rs = db.dbQuery("select count(*) from pay_requests where contract_id = " + id);
if (rs.first() && rs.getInt(1) > 0) out.println ("var pr = " + rs.getInt(1) + ";");
else out.println("var pr = 0;");
rs.getStatement().close();
%>
		var oldCompanyId = <%= companyId %>;
		if (oldCompanyId != companyId) {
			if (ca) {
				window.alert("Cannot change the company on this contact because it's associated"
					+ " with " + ca + " change authorization(s).");
				window.location = "modifyContract.jsp?id=<%= id %>";
				return;
			}
			if (pr) {
				window.alert("Cannot change the company on this contract because it's associated"
					+ " with " + pr + " pay request(s).");
				window.location = "modifyContract.jsp?id=<%= id %>";
				return;
			}
		}
		if (strikes > 0 && !window.confirm("This company has " + strikes + " strikes.\n\nContinue anyway?")) {
			window.location = "modifyContract.jsp?id=<%= id %>";
			return;
		}
		window.location = "changeCompanyOnContract.jsp?id=<%= id %>&company_id="
			+ companyId + (contactId != 0 ? "&contact_id=" + contactId : ""); 
	}
</script>
</head>
<body>
<div class="title">Change Company/Contact</div><hr>
<form method="POST">
<span class="bold">Search</span>
<input type="text" id="search" name="search" value="<%= name != null ? name : "" %>">
<input type="submit" value="Search">
</form>
<script>
	var f = document.getElementById("search");
	f.select();
	f.focus();
</script>
<%
	if (name != null) {
		PreparedStatement ps = db.preStmt("select company.company_id, contact_id, company_name, name, "
			+ "company.city, company.state, contacts.city, contacts.state from company left join contacts "
			+ "using (company_id) where company_name like ?  order by company_name, name limit 25");
		ps.setString(1, name + "%");
		rs = ps.executeQuery();
		if (rs.isBeforeFirst()) out.println("<hr><div class=\"bold\" style=\"margin-bottom: 8px;\""
			+ ">Search Results:</div>");
		ResultSet rs2 = null;
		int strikes;
		while (rs.next()) {
			rs2 = db.dbQuery("select count(*) from company_comments where strike = 1 and company_id = " +
					rs.getString("company_id"));
			if (rs2.first()) strikes = rs2.getInt(1);
			else strikes = 0;
			rs2.getStatement().close();
%>
<div><div class="link" onclick="change(<%= rs.getInt("company_id") %>, <%= rs.getInt("contact_id") %>,
	<%= strikes %>);"><%= rs.getString("company_name") + (rs.getInt("contact_id") != 0 ?
	" (" + rs.getString("name") + ")" : "") %></div>, <%= rs.getInt("contact_id") == 0 ?
	rs.getString("company.city") + ", " + rs.getString("company.state") :
	rs.getString("contacts.city") + ", " + rs.getString("contacts.state")%>
	<%= strikes > 0 ? " - <span class=\"red bold\">" + strikes + " strike(s)" :	"" %></div>
<%
		}
		rs.getStatement().close();
	}
}
db.disconnect();
%>
</body>
</html>