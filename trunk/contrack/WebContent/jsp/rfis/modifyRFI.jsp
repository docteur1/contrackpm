<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.User" %>
<%@page import="java.util.Iterator" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<%@page import="java.text.SimpleDateFormat, java.util.Date" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.RFI, Security.READ)) response.sendRedirect("../accessDenied.html");
String rfi_id = request.getParameter("id");
String query = "select * from rfi where rfi_id = " + rfi_id;
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
String company_id = "0";
int contact_id = 0;
if (rs.next()) {
	company_id = rs.getString("company_id");
	contact_id = rs.getInt("contact_id");
	rs.updateBoolean("e_update", false);
	rs.updateRow();
}
if (rs != null) rs.close();
rs = null;
query = "select rfi_num from rfi where job_id = " + attr.getJobId()
	+ " and company_id = " + company_id + " and rfi_id != " + rfi_id + " order by costorder(rfi_num) desc";
rs = db.dbQuery(query);
String rfi_nums = "";
while (rs.next()) {
	if (!rs.isLast()) rfi_nums += "\"" + rs.getString("rfi_num") + "\",";
	else if (rs.isLast()) rfi_nums += "\"" + rs.getString("rfi_num") + "\"";
}
if (rs != null) rs.close();
rs = null;
%>
<html>
	<head>
		<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
 	<script language="javascript" src="../utils/spell.js"></script>
 	<script language="javascript" src="../utils/verify.js"></script>
	<script language="javascript">
			var rfi_nums = new Array(<%= rfi_nums %>);
			function save () {
				if (checkForm(document.rfi) && verifyNums()) document.rfi.submit();
			}
			function spell () {
				spellCheck(document.rfi);
			}
			function verifyNums() {
				var f = document.rfi.rfi_num;
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
			<form name="rfi" method="post" <%= sec.ok(Security.RFI, Security.WRITE)?"action=\"processModifyRFI.jsp\"":"" %>>
		<font size="+1">Modify RFI</font><hr>
		<%
		if (request.getParameter("save") != null) out.print("<font color=\"red\"><b>Saved</b><hr></font>");
		String  urgency, respond_by, date_received;
		query="select rfi.*, company_name from rfi join company using(company_id) where rfi_id=" + rfi_id;
		rs = db.dbQuery(query);
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
		Date d = null;
		if(rs.next()){
			urgency = rs.getString("urgency");
			d = rs.getDate("respond_by");
			if (d == null) respond_by = "";
			else respond_by = sdf.format(d);
			d = rs.getDate("date_received");
			if (d == null) date_received = "";
			else date_received = sdf.format(rs.getDate("date_received"));
		%>

			<input type="hidden" name="id" value="<%=rfi_id%>">
			<table valign="top">
				<tr><td align="right"><b>ID:</b></td>
					<td><%= com.sinkluge.utilities.Widgets.logLinkWithId(rfi_id, 
					com.sinkluge.Type.RFI, "parent", request) %></td>
				</tr>
				<tr><td align="right"><b>RFI #:</b></td>
					<td align="left"><input type="text" size="4" name="rfi_num" value="<%=rs.getString("rfi_num")%>" onChange="verifyNums();"></td></tr>
				<tr><td align="right"><b>Company:</b></td>
					<td align="left"><%=rs.getString("company_name")%></td></tr>
	<tr><td align="right"><b>Attention:</td><td align="left">
<%
ResultSet rs3 = db.dbQuery("select contact_id, name from company join contacts using(company_id) "
		+ "where company_id = "+company_id + " order by name");
%>
		<select name="contact_id" <%= FormHelper.dis(!rs3.isBeforeFirst()) %>>
<%
	while (rs3.next()) out.println("<option value=\"" + rs3.getString("contact_id") + "\" " 
		+ FormHelper.sel(rs3.getInt("contact_id"), contact_id) + ">" + rs3.getString("name") + "</option>");
	rs3.getStatement().close();
%>
	</select>
</td></tr>
				<tr><td align="right"><b>Date Created:</b></td>
					<td align="left"><%=sdf.format(rs.getDate("date_created"))%></td></tr>
	<tr><td align="right"><b><a href="javascript:insertDate('respond_by')">Respond By:</a></td>
			<td><input type="text" id="respond_by" name="respond_by" maxlength=10 size=8 value="<%=respond_by%>">
			<img id="calrespond_by" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>

	<tr><td align="right"><b><a href="javascript:insertDate('date_received')">Date Received:</a></td>
			<td><input type="text" id="date_received" name="date_received" maxlength=10 size=8 value="<%=date_received%>">
			<img id="caldate_received" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>

				<tr><td align="right"><b>From:</b></td>
					<td align="left">
<%= com.sinkluge.utilities.Widgets.userList(rs.getInt("user_id"), "user_id") %></td></tr>
</table>
<br>
<b>Request:</b><br><textarea name="request" rows=5 cols=80><%=rs.getString("request")%></textarea><br>
					<fieldset  style="width: 275px; margin-top: 10px;">
						<legend><b>Urgency</b></legend>
						<table><tr>
						<td><input type="radio" name="urgency" value="Work Stopped" <% if (urgency.equals("Work Stopped")) out.println("checked");%>></td>
						<td>Work Stopped!</td>
						<td><input type="radio" name="urgency" value="As Soon As Possible" <% if (urgency.equals("As Soon As Possible")) out.println("checked");%>></td>
						<td>As Soon As Possible</td>
						</tr>
						<tr>
						<td><input type="radio" name="urgency" value="At Next Visit" <% if (urgency.equals("At Next Visit")) out.println("checked");%>></td>
						<td>At Next Visit</td>
						<td><input type="radio" name="urgency" value="At Your Convenience" <% if (urgency.equals("At Your Convenience")) out.println("checked");%>></td>
						<td>At Your Convenience</td>
						</tr>
						</table>
					</fieldset><br>
			<b>Reply:</b><br><textarea name="reply" rows=5 cols=80><%=rs.getString("reply")%></textarea>


			<%}%>
		</form>
<script language="javascript">
	var f = document.rfi;
	var d = f.rfi_num;
	d.required = true;
	d.select();
	d.focus();
	if (rfi_nums.length != 0) d.title= "Last RFI number used on this job for this company = " + rfi_nums[0];
	d.eName = "RFI #";
	
	d = f.respond_by;
	d.isDate = true;
	d.eName = "Respond By";
	
	d = f.date_received;
	d.isDate = true;
	d.eName = "Date Received";
	
	d = f.request;
	d.required = true;
	d.eName = "Request";
	d.spell = true;
	
	d = f.reply;
	d.spell = true;
	
</script>
	</body>
</html>
<%
db.disconnect();
%>
