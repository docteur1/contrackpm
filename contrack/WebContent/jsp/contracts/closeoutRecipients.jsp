<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.Verify, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.SUBCONTRACT, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<script src="../utils/table.js"></script>
		<script language="javascript">
			function setTo(type) {
				var f = document.closeoutForm;
				var e = null;
				for (var i = 0; i < f.length; i++) {
					e = f.elements[i];
					if (type == 0 && e.value == "email") {
						if (!e.disabled) 	e.checked = true;
						else if (!f.elements[i+1].disabled) f.elements[i+1].checked = true;
						else f.elements[i+2].checked = true;
						i = i + 3;
					} else if (type == 1 && e.value == "fax") {
						if (!e.disabled) e.checked = true;
						else f.elements[i+1].checked = true;
						i = i + 2;
					} else if (type == 2 && e.value == "print") e.checked = true;
				}
			}
			function toggleSend() {
				var f = document.closeoutForm;
				var e = null;
				var count = 0;	
				for (var i = 0; i < f.length; i++) {
					e = f.elements[i];
					if (e.type == "checkbox") e.checked = !e.checked;
				}
			}
			function sendDocs () {
				var f = document.closeoutForm;
				var e = null;
				var count = 0;	
				for (var i = 0; i < f.length; i++) {
					e = f.elements[i];
					if ((e.value == "email" || e.value == "fax") && e.checked) count++;
				}
				if (count > 0) {
				 	if (confirm("This will automatically send faxes or emails\nto the various recipients.\n\nContinue?")) openWin();
				} else openWin();
			}
			function openWin() {
				var newWin = window.open("","closeoutWin");
				document.closeoutForm.submit();
			}
		</script>
	</head>
<body>
	<form name="closeoutForm" action="../servlets/closeout/closeout.pdf#view=FitV&statusbar=1&navpanes=0"
		method="GET" target="closeoutWin">
	<div class="title">Closeout: Select Recipients</div><hr>
	<a href="closeout.jsp">Closeout</a> &gt; 
	Send/Print Documents&nbsp;&nbsp;&nbsp;<a href="javascript: sendDocs();">Send/Print</a>
	&nbsp;&nbsp;<div class="link" onclick="toggleSend()">Toggle Send</div>
	&nbsp;&nbsp;<b>Set to:</b>&nbsp;&nbsp;&nbsp;<a href="javascript: setTo(0);">Email</a>
	<%= in.hasFax ? "&nbsp;&nbsp;<div class=\"link\" onclick=\"setTo(1);\">Fax</div>" : "" %>
	&nbsp;&nbsp;<a href="javascript: setTo(2);">Print</a>
	<hr>

	<table cellspacing="0" cellpadding="3" id="tableHead">
		<tr>
			<td class="left head">Code</td>
			<td class="head">Company</td>
			<td class="head">Email</td>
			<%= in.hasFax ? "<td class=\"head\">Fax</td>" : "" %>
			<td class="head">Print</td>
			<td class="head">Send</td>
			<td class="head right">Warranty</td>
		</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
String query = "select contract_id, division, cost_code, phase_code, email, company.fax as cf, contacts.fax as nf, "
	+ "company.company_name, name, req_warranty, have_warranty from contracts join job_cost_detail as jcd "
	+ "using(cost_code_id) join company on contracts.company_id = company.company_id left join contacts on "
	+ "contracts.contact_id = contacts.contact_id where contracts.job_id = " + attr.getJobId() 
	+ " order by costorder(division),costorder(cost_code), phase_code";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String contract_id, reqWar, haveWar, fax, email, name;
boolean c = true;
boolean war = false, vFax, vEmail;
while(rs.next()) {
	c = !c;
	contract_id = rs.getString("contract_id");
	reqWar = rs.getString("req_warranty");
	haveWar = rs.getString("have_warranty");
	name = rs.getString("name");
	if (name != null) fax = rs.getString("nf");
	else fax = rs.getString("cf");
	email = rs.getString("email");
	if (fax != null) vFax = Verify.phone(fax);
	else vFax = false;
	if (email != null) vEmail = Verify.email(email);
	else vEmail = false;
	war = reqWar.equals("y") && !haveWar.equals("y");
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (c) out.print("class=\"gray\""); %>>
			<td class="left" align="right"><%= rs.getString("division") + " " + rs.getString("cost_code") + "-" + rs.getString("phase_code") %></td>
			<td class="it"><%= rs.getString("company_name") + (name!=null?"- " + name:"") %></td>
			<td class="input"><input type="radio" name="s<%= contract_id %>" value="email" <%= FormHelper.dis(!vEmail) %> <%= FormHelper.chk(vEmail) %>></td>
			<%= in.hasFax ? "<td class=\"input\"><input type=\"radio\" name=\"s" + contract_id 
				+ "\" value=\"fax\"" + FormHelper.dis(!vFax) + " " + FormHelper.chk(!vEmail && vFax) 
				+ "></td>" : "" %>
			<td class="input"><input type="radio" name="s<%= contract_id %>" value="print" <%= FormHelper.chk(!(vEmail || vFax)) %>></td>
			<td class="input"><input type="checkbox" name="d<%= contract_id %>" value="y" checked></td>
			<td class="input right"><% if(war) out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
		</tr>
<%
}
if (rs != null) rs.close();
rs = null;
db.disconnect();
%>
</table>
</div>
</form>
</body>
</html>