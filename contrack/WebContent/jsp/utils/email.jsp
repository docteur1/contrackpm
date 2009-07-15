<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.Type,java.text.DecimalFormat" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
String id = request.getParameter("contact_id");
String query = "select contacts.name, contacts.email, company.company_name from contacts, company where company.company_id = contacts.company_id "
	+ "and contact_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String email = "", name = "", company = "";
if(rs.next()) {
	email = rs.getString("email");
	name = rs.getString("name");
	company = rs.getString("company_name");
}
rs.getStatement().close();
query = "select txt from reports where id = 'documentEmail'";
String body = "";
rs = db.dbQuery(query);
if (rs.first()) body = rs.getString(1);
rs.getStatement().close();
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<title>Email Document</title>
	<script language="javascript" src="verify.js"></script>
	<script language="javascript">
		function clearInfo() {
			document.getElementById("emailName").innerHTML = "";
			document.getElementById("company").innerHTML = "";
		}
	</script>
</head>
<body>
<form name="email" action="../servlets/reports/email" method="POST" onSubmit="return checkForm(this);">
<div class="title">Email Document</div><hr>
<a href="print.jsp?doc=<%= request.getParameter("doc") %>&add=<%= request.getParameter("add") %>">Print</a> &gt; Email Document&nbsp;&nbsp;
<a href="searchEmail.jsp?doc=<%= request.getParameter("doc") %>&add=<%= request.getParameter("add") %>">Search</a><hr>
<input type="hidden" name="doc" value="<%= request.getParameter("doc") %>">
<input type="hidden" name="add" value="<%= request.getParameter("add") %>">
<table>
	<tr>
	<td align="right"><b>To:</b></td>
	<td><input type="text" name="address" value="<%= FormHelper.string(email) %>" size="40" onChange="clearInfo()"></td>
	</tr>
	<tr>
	<td align="right"><b>Recipient Name:</b></td>
	<td><span id="emailName"><%=FormHelper.string(name)%></span></td>
	</tr>
	<tr>
	<td align="right"><b>Company Name:</b></td>
	<td><span id="company"><%=company%></span></td>
	<tr>
	<td align="right"><b>Subject:</b></td>
	<td><input type="text" name="subject" value="Document from <%= attr.get("short_name") %>" size="60">
	</tr>
<%
String doc = request.getParameter("doc");
String docId = doc.substring(doc.indexOf("id=") + 3);
com.sinkluge.reports.Report report = com.sinkluge.servlets.PDFReport.getReport(request, doc, 
	docId, null, db, attr, in);
if (report != null && report.type != null) {
	rs = db.dbQuery("select description, content_type, size from files where type = '"
		+ report.type.getCode() + "' and id = '" + docId + "' and email = 1");
	if (rs.isBeforeFirst()) {
%>
	<tr>
	<td class="lbl" style="vertical-align: top;">Also Attached:</td>
	<td style="background-color:  #DCDCDC;">
<%
		double size = 0;
		DecimalFormat df = new DecimalFormat("#,##0.0");
		while (rs.next()) {
			size += rs.getLong("size");
%>
		<div><%= rs.getString("description") %> (<%= rs.getString("content_type") %>) 
			<%= df.format(rs.getDouble("size") / 1000) %>K</div>
<%
		}
%>		
		<div><span class="bold">Total Size:</span> <%= df.format(size/1000) %>K</div>
	</td>
	</tr>
<%
	}
	rs.getStatement().close();
}
db.disconnect();
%>
	<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Send"></td>
	</tr>
	<tr>
	<td colspan="2"><textarea name="body" cols="80" rows="10"><%= body %></textarea></td>
	</tr>
</table>
</form>
<script language="javascript">
	var f = document.email;
	var d = f.address;
	d.select();
	d.focus();
	d.isEmail = true;
	d.required = true;
	d.eName = "Email";
	d = f.subject;
	d.required = true;
	d.eName = "Subject";
	d = f.body;
	d.required = true;
	d.eName = "Email Body";
</script>
</body>
</html>