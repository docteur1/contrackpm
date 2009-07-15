<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
String query = "select count(*) from job_cost_detail as jcd join cost_types on phase_code = letter left join "
	+ "contracts using(cost_code_id) where contractable = 1 and contract_id is null";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (rs.first() && rs.getInt(1) == 0) {
	rs.getStatement().close();

%>
<script>
	window.alert("Unable to create contract!\n______________________________\n\nNo valid contractable phase codes!");
	parent.close();
</script>
<%
} else {
String name = request.getParameter("name");
boolean results = name != null;
name = name == null?"":name;
%>
<head>
	<link href="../stylesheets/v2.css" rel="stylesheet" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript">
		parent.left.location="newContractLeft.jsp";
		function warnStrike(strikes, company_id, contact_id, url) {
			if(confirm("This company has " + strikes + " strikes.\n\nContinue anyway?")) {
				if (contact_id != null) window.location = url + "?company_id=" + company_id + "&contact_id=" + contact_id;
				else window.location = url + "?company_id=" + company_id;
			}
		}
	</script>
</head>
<body>
	<form name="search" action="newContract.jsp" method="POST">
	<font size="+1">Search for a Company</font><hr>
	<b>Company Name: </b><input type="text" name="name" value="<%= name %>"><p>
	<input type="submit" value="Search">
	</form>
	<script language="javascript">
		document.search.name.focus();
		document.search.name.select();
	</script>
<%
	if (results) {
%>
	<hr><font size="+1">Select a Company</font><hr>
<%
		query = "select c.company_id, c.company_name, c.city, c.state, n.contact_id, n.name, n.city, n.state " +
			"from company as c left join contacts as n using (company_id) where company_name like ? order by " +
			"company_name, name limit 25";
		db.connect();
		PreparedStatement ps = db.preStmt(query);
		ps.setString(1, name + "%");
		rs = ps.executeQuery();
		int strikes = 0;
		ResultSet strike;
		String companyId, contactId, info, url;
		while (rs.next()) {
			ResultSet ids = db.dbQuery("select account_id from company_account_ids where company_id = " 
					+ rs.getString("company_id") + " and site_id = " + attr.getSiteId());
			if (!ids.first() && attr.hasAccounting()) url = "newContract2.jsp";
			else url = "newContract3.jsp";
			if (ids != null) ids.getStatement().close();
			query = "select count(*) from company_comments where strike = 1 and company_id = " + rs.getString("company_id");
			strikes = 0;
			strike = db.dbQuery(query);
			if (strike.first()) strikes = strike.getInt(1);
			if (strike != null) strike.getStatement().close();
			contactId = rs.getString("contact_id");
			companyId = rs.getString("company_id");
			if (contactId != null) info = FormHelper.string(rs.getString("name")) 
				+ " (" + FormHelper.string(rs.getString("n.city")) + ", " + FormHelper.string(rs.getString("n.state")) + ")";
			else info = "(" + FormHelper.string(rs.getString("c.city")) + ", " 
				+ FormHelper.string(rs.getString("c.state")) + ")";
			if (strikes > 0) {
%>
	<div><a href="javascript: warnStrike(<%= strikes %>,<%= companyId %>,<%= contactId %>, '<%= url %>')">
		<%= rs.getString("company_name") %></a> <%= info %>
		 - <font color="red"><b><%= strikes %> strike(s)</b></font></div>

<%
			} else {
				if (contactId == null) out.print("<div><a href=\"" + url + "?company_id=" 
					+ companyId + "\">");
				else out.print("<div><a href=\"" + url + "?company_id=" 
						+ companyId + "&contact_id=" + contactId + "\">");
%>
	
		<%= rs.getString("company_name") %></a> <%= info %></div>
<%
			}
		}	// end while (rs.next())
		if (rs != null) rs.close();
		rs = null;
		strike = null;
		if (ps != null) ps.close();
		ps = null;
	} // end if (results)
}
db.disconnect();
%>
</body>
</html>

