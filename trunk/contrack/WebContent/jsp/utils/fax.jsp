<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<jsp:useBean id="db" class="com.sinkluge.database.Database" />
<%
String company_id = request.getParameter("company_id");
String query;
if (company_id != null) query = "select company_name, company.fax as c_fax, null as n_fax, null as name from company where company_id = " + company_id;
else query = "select company_name, company.fax as c_fax, contacts.fax as n_fax, name from contacts join company using(company_id) where "
	+ "contact_id = " + request.getParameter("contact_id");
ResultSet rs = db.dbQuery(query);
String fax = "", name = "", company = "";
String doc = request.getParameter("doc");
if(rs.next()) {
	fax = rs.getString("n_fax");
	if (fax == null || "".equals(fax)) fax = rs.getString("c_fax");
	name = rs.getString("name");
	if (name == null) name = "";
	company = rs.getString("company_name");
}
%>
<html>
<head>
	<script language="javascript" src="verify.js"></script>
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script>
		function send(id) {
			if (checkForm(id)) {
				document.getElementById("main").style.display = "none";
				document.getElementById("hid").style.display = "inline";
				window.setInterval(wait, 1000);
				return true;
			} else return false;
		}
		function wait(wait) {
			w = document.getElementById("wait").innerHTML += " .";
		}
	</script>
	<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
	<title>Fax Document</title>
</head>
<body>
<div id="hid" style="display: none;"><font size="+1">Queueing Fax</font><hr>
	<span class="bold" id="wait">Please wait .</span></div>
<div id="main">
<form name="fax" action="../servlets/reports/fax" method="POST" onSubmit="return send(this);">
<font size="+1">Fax Document</font><hr>
<a href="print.jsp?doc=<%= request.getParameter("doc") %>&add=<%= request.getParameter("add") %>">Print</a> &gt; Fax Document&nbsp;&nbsp;
<a href="searchFax.jsp?doc=<%= request.getParameter("doc") %>&add=<%= request.getParameter("add") %>">Search</a>
<input type="hidden" name="doc" value="<%= doc %>">
<input type="hidden" name="add" value="<%= request.getParameter("add") %>">
<hr>
<table>
	<tr>
	<td align="right"><b>Fax Number:</b></td>
	<td><input type="text" name="fax" value="<%= fax %>" maxlength="14"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><i>For tracking purposes only:</i></td>
	</tr>
	<tr>
	<td align="right"><b>Name:</b></td>
	<td><input type="text" name="contact" value="<%= name %>"></td>
	</tr>
	<tr>
	<td align="right"><b>Company:</b></td>
	<td><input type="text" name="company" value="<%= company %>"></td>
	</tr>
	<tr>
	<td align="right"><b>Description of Fax:</b></td>
	<td><input type="text" name="description" value="" maxlength="50"></td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Send"></td>
	</tr>
</table>
</form>
<script>
	var f = document.fax;
	var d = f.fax;
	d.focus();
	d.select();
	d.isPhone = true;
	d.required = true;
	d.eName = "Fax Number";
</script>
</div>
</body>
</html>
<%
rs.close();
db.disconnect();
%>