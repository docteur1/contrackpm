<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.User" %>
<%@page import="java.util.Iterator" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.RFI,2)) response.sendRedirect("../accessDenied.html");
String company_id = request.getParameter("company_id");
String rfi_num = "1";
String query = "select rfi_num from rfi where job_id = " + attr.getJobId() 
	+ " and company_id = " + company_id + " order by costorder(rfi_num) desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String rfi_nums = "";
while (rs.next()) {
	if (!rs.isLast()) rfi_nums += "\"" + rs.getString("rfi_num") + "\",";
	else if (rs.isLast()) rfi_nums += "\"" + rs.getString("rfi_num") + "\"";
	if (rs.isFirst()) {
		try {
			rfi_num = Integer.toString(Integer.parseInt(rs.getString("rfi_num")) + 1);
		} catch (NumberFormatException e) {
			rfi_num = "1";
		}
	}
}
if (rs != null) rs.close();
rs = null;

String query3 = "select company_name from company where company_id = " + company_id;
ResultSet rs3 = db.dbQuery(query3);
String company_name = "Company";
if (rs3.next()) company_name = rs3.getString(1);
rs3.getStatement().close();
query3="select contact_id, name from company join contacts using(company_id) "
	+ "where company_id = "+company_id + " order by name";
rs3 = db.dbQuery(query3);
%>

<html>
<head>
<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
 	<script language="javascript" src="../utils/spell.js"></script>
 	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript">
			parent.left.location = "newRFILeft2.jsp";
			var rfi_nums = new Array(<%= rfi_nums %>);
			function save () {
				if (checkForm(document.newRFI) && verifyNums()) document.newRFI.submit();
			}
			function spell () {
				spellCheck(document.newRFI);
			}
			function verifyNums() {
				var f = document.newRFI.rfi_num;
				f.style.backgroundColor = "#FFFFFF";
				var error = false;
				for(var i = 0; i < rfi_nums.length; i++) {
					if (f.value == rfi_nums[i]) error = true;
				}
				if (error) {
					alert("Error\n-------------\nRFI numbers must be unique\nfor a given company.");
					f.style.backgroundColor = "#FFFFCC";
					return false;
				} else return true;
			}
		</script>
		<script language="javascript" src="../utils/calendar.js"></script>

	</head>
<body>
<form name="newRFI" action="processRFI.jsp" method="POST">
<font size="+1">New RFI</font><hr>
<table valign="top">
<tr><td align="right"><b>RFI #:</td>
	<td align="left"><input type="text" name="rfi_num" value="<%=rfi_num%>" size="6" onChange="verifyNums();"></td></tr>
					<tr><td align="right"><b>Company:</td>
	    <td align="left"><input type="hidden" name="company_id" value="<%=company_id%>">
		<%= company_name %>
		</td></tr>
	<tr><td align="right"><b>Attention:</td><td align="left">
		<select name="contact_id" <%= FormHelper.dis(!rs3.isBeforeFirst()) %>>
<%
	while (rs3.next()) out.println("<option value=\"" + rs3.getString("contact_id") + "\">" + rs3.getString("name") + "</option>");
	rs3.getStatement().close();
%>
	</select>
</td></tr>
	<tr><td align="right"><b><a href="javascript:insertDate('respond_by')">Respond By:</a></td>
			<td><input type="text" id="respond_by" name="respond_by" maxlength=10 size=8 value="">
			<img id="calrespond_by" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>

				<tr><td align="right"><b>From:</td>
				<td><%= com.sinkluge.utilities.Widgets.userList(attr.getUserId(), "user_id") %></td></tr>
</table><br/>
		<b>Request:</b><br>
    <textarea name="request" rows=5 cols=80></textarea>
    <fieldset style="width: 275px; margin-top: 10px;">
		<legend><b>Urgency</b></legend>
			<table><tr>
			<td><input type="radio" name="urgency" value="Work Stopped"></td>
			<td>Work Stopped!</td>
			<td><input type="radio" name="urgency" value="As Soon As Possible"></td>
			<td>As Soon As Possible</td>
			</tr>
			<tr>
			<td><input type="radio" name="urgency" value="At Next Visit"></td>
			<td>At Next Visit</td>
			<td><input type="radio" name="urgency" value="At Your Convenience" checked></td>
			<td>At Your Convenience</td>
			</tr>
			</table>
		</fieldset><br>
		<b>Reply:</b><br>
    <textarea name="reply" rows=5 cols=80></textarea>
</form>
<script language="javascript">
	var f = document.newRFI;
	var d = f.rfi_num;
	d.required = true;
	d.select();
	d.focus();
	if (rfi_nums.length != 0) d.title= "Last RFI number used on this job for this company = " + rfi_nums[0];
	d.eName = "RFI #";
	
	d = f.respond_by;
	d.isDate = true;
	d.eName = "Respond By";
	
	d = f.request;
	d.required = true;
	d.eName = "Request";
	d.spell = true;
	
	d = f.reply;
	d.spell = true;
	
</script>
</body></html>
<%
db.disconnect();
%>