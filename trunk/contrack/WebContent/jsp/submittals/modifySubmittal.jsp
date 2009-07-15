<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.ResultSet, com.sinkluge.User" %>
<%@page import="java.util.Iterator" %>
<%@page import="java.util.Date, com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.security.Security"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />

<%!String cDate(String d){
	if(d.equals("11/30/0002")) return "";
	else return d;
}%>
<%
if (!sec.ok(Security.SUBMITTALS,4)) response.sendRedirect("../accessDenied.html");
SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
SimpleDateFormat df = new SimpleDateFormat("MMM d, yyyy");
int submittal_id=Integer.parseInt(request.getParameter("subID"));
String submittal_status, submittal_type,acc;
String date_received="", date_to_architect="", date_from_architect="", date_to_sub="", date_created="";
String contract_id = null;
String fullId = null;
int attempt, architect_id=0, userId;
String query="select * from submittals where submittal_id=" + submittal_id;
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
if(rs.next()){
	architect_id = rs.getInt("architect_id");
	contract_id = rs.getString("contract_id");
	fullId = rs.getString("cost_code_id") + (contract_id != null && !"0".equals(contract_id) ? "c" + contract_id : "");
	attempt=rs.getInt("attempt");
	userId = rs.getInt("user_id");
	submittal_status=rs.getString("submittal_status");;
	acc = rs.getString("alt_cost_code");
	if (submittal_status == null) submittal_status = "";
	submittal_type=rs.getString("submittal_type");
	if (submittal_type == null) submittal_type ="";
	date_created = rs.getString("date_created");
	if (date_created==null) date_created = "N/A";
	else date_created = df.format(rs.getDate("date_created"));
	Date d = rs.getDate("date_received");
	if(d != null) date_received = sdf.format(d);
	date_received = cDate(date_received);
	d = rs.getDate("date_to_architect");
	if(d != null) date_to_architect = sdf.format(d);
	date_to_architect = cDate(date_to_architect);
	d = rs.getDate("date_from_architect");
	if(d != null) date_from_architect = sdf.format(d);
	date_from_architect = cDate(date_from_architect);
	d = rs.getDate("date_to_sub");
	if(d != null) date_to_sub = sdf.format(d);
	date_to_sub = cDate(date_to_sub);

	
	query = "select job_contact_id, company_name, contacts.name, isDefault from job_contacts join company "
		+ "on job_contacts.company_id = company.company_id left join contacts using (contact_id) where "
		+ "job_id = " + attr.getJobId() + " and type='Architect' order by company_name";
	ResultSet rs3 = db.dbQuery(query);
	
	
	query = "select left(company_name, 30) as company_name, name, contract_id, job_cost_detail.cost_code_id, division, phase_code, cost_code, "
		+ "code_description from job_cost_detail left join contracts using(cost_code_id) left join company using(company_id) "
		+ "left join contacts using(contact_id) where job_cost_detail.job_id = " + attr.getJobId() 
		+ " order by costorder(division), costorder(cost_code), phase_code";
	ResultSet rs4 = db.dbQuery(query);
%>

<html>
<head>
<title>Modify Submittal</title>
<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<script language="javascript" src="../utils/verify.js"></script>
		<script language="javascript" src="../utils/spell.js"></script>
	<script language="javascript">
			parent.left.location="modifySubmittalLeft.jsp?subID=<%= submittal_id %>";
			function spell() {
				spellCheck(f);
			}
			function save() {
				if(checkForm(f)) f.submit();
			}
			
		</script>
		<script language="javascript" src="../utils/calendar.js"></script>
</head>
<body>
<form name="modifySubmittal" action="processModifySubmittal.jsp" method="POST">
<font size="+1">Modify Submittal</font><hr>
<%
if (request.getParameter("save") != null) {
%>
<font color="red"><b>Saved</b></font><hr>
<% } %>
<table valign="top">
	<tr>
		<td align="right"><b>ID:</b><input type="hidden" name="submittal_id" value="<%=submittal_id%>"></td>
		<td><%= com.sinkluge.utilities.Widgets.logLinkWithId(Integer.toString(submittal_id), 
					com.sinkluge.Type.SUBMITTAL, "parent", request) %></td>
	</tr>
						<tr><td align="right"><b>Subcontract/Code:</b></td><td>
								<select name="id">
									<%
									String conId = null;
									while (rs4.next()){
										conId = rs4.getString("contract_id");
										conId = rs4.getString("cost_code_id") + (conId != null ? "c" + conId : "");
									%>
									<option value="<%= conId %>" 
									<%= FormHelper.sel(conId, fullId) %>><%= rs4.getString("division") %> 
									<%= rs4.getString("cost_code")%>-<%=rs4.getString("phase_code") + " "  
									+ rs4.getString("code_description")
									+ (rs4.getString("company_name") != null ? " - " + rs4.getString("company_name") : "")
									+ (rs4.getString("name")!=null?", " + rs4.getString("name"):"") %>
									</option>
									<%}
									rs4.getStatement().close();
									%>
								</select>
							</td></tr>


<tr><td align="right"><b>Submittal Number:</b></td>
	<td align="left"><input type="text" name="submittal_num" value="<%=rs.getString("submittal_num")%>"></td></tr>

	<tr><td align="right"><b>Date Created:</td>
	<td align="left"><%=date_created%></td></tr>

		<tr><td align="right"><b>Alt Spec Num:</td>
		<td><input type="text" name="acc" value="<%=acc%>" maxlength="100"> <i>Leave blank to use phase code</i></td></tr>

<tr><td align="right"><b>Attempt: </td><td align="left"><select name="attempt">
<option value = "1" <% if (attempt==1) out.print("selected"); %>>1</option>
<option value = "2" <% if (attempt==2) out.print("selected"); %>>2</option>
<option value = "3" <% if (attempt==3) out.print("selected"); %>>3</option>
<option value = "4" <% if (attempt==4) out.print("selected"); %>>4</option>
<option value = "5" <% if (attempt==5) out.print("selected"); %>>5</option>
<option value = "6" <% if (attempt==6) out.print("selected"); %>>6</option>
<option value = "7" <% if (attempt==7) out.print("selected"); %>>7</option>
<option value = "8" <% if (attempt==8) out.print("selected"); %>>8</option>
</select></td></tr>

					<tr><td align="right"><b>Architect:</b></td>
						 <td><select name="architect_id">
<%
int job_contact_id =0;
while(rs3.next()){
	job_contact_id = rs3.getInt("job_contact_id");
%>
								<option value = "<%= job_contact_id %>" <%= FormHelper.sel(job_contact_id, architect_id)%>>
								<%= rs3.getString("company_name") + (rs3.getString("name")!=null?" - "+rs3.getString("name"):"") %></option>
<% }
	rs3.getStatement().close();
%>
						</select></td></tr>

	<tr><td align="right"><b><a href="javascript:insertDate('received')">Date from Sub:</a></td>
			<td><input type="text" id="received" name="received" maxlength=10 size=8 value="<%= date_received %>">
			<img id="calreceived" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>


	<tr><td align="right"><b><a href="javascript:insertDate('toArchitect')">Date to Architect:</a></td>
			<td><input type="text" id="toArchitect" name="toArchitect" maxlength=10 size=8 value="<%=date_to_architect%>">
			<img id="caltoArchitect" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>

	<tr><td align="right"><b><a href="javascript:insertDate('fromArchitect')">Date from Architect:</a></td>
			<td><input type="text" id="fromArchitect" name="fromArchitect" maxlength=10 size=8 value="<%=date_from_architect%>">
			<img id="calfromArchitect" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>
	<tr><td align="right"><b><a href="javascript:insertDate('toSub')">Date to Sub:</a></td>
			<td><input type="text" id="toSub" name="toSub" maxlength=10 size=8 value="<%=date_to_sub%>">
			<img id="caltoSub" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
			</td></tr>
				<tr><td align="right"><b>From:</td>
				<td><%= com.sinkluge.utilities.Widgets.userList(rs.getInt("user_id"), "user_id") %></td></tr>



<tr><td class="lbl">Submittal Status:</td><td align="left">
<%= Widgets.list("submittal_status", submittal_status, db) %>
</td></tr>

<tr><td class="lbl">Submittal Type:</td><td align="left">
<%= Widgets.list("submittal_type", submittal_type, db) %>
</td></tr>

<tr>
	<td class="lbl">Stamp</td>
	<td><select name="stamp">
		<option value="" <%= FormHelper.sel(rs.getString("contractor_stamp"), null) %>>---</option>
<%
	ResultSet rs2 = db.dbQuery("select val from lists where id = 'submittal_stamp' order by val");
	while (rs2.next()) out.println("<option " + FormHelper.sel(rs.getString("contractor_stamp"),
			rs2.getString(1)) + ">" + rs2.getString(1) + "</option>");
	rs2.getStatement().close();
%>
	</select></td>
</tr>

		<tr><td align="right"><b>Description:</td>

    <td align="left"><textarea name="description" rows=5 cols=55><%=rs.getString("description")%></textarea></td></tr>

		<tr><td align="right"><b>Comment From Subcontractor:</td>
    <td align="left"><%= FormHelper.stringTable(rs.getString("comment_from_sub")) %></td></tr>

		<tr><td align="right"><b>Comment To Architect:</td>
    <td align="left"><textarea name="comment_to_architect" rows=5 cols=55><%=rs.getString("comment_to_architect")%></textarea></td></tr>
    
    	<tr><td align="right"><b>eStamped by Architect:</b></td>
    	<td><%= Widgets.checkmark(rs.getBoolean("architect_stamp"), request) %></td>
		<tr><td align="right"><b>Comment From Architect:</td>
    <td align="left"><%= FormHelper.stringTable(rs.getString("comment_from_architect")) %></td></tr>
		<tr><td align="right"><b>Comment To Subcontractor:</td>

    <td align="left"><textarea name="comment_to_sub" rows=5 cols=55><%=rs.getString("comment_to_sub")%></textarea></td></tr>

<tr><td align="right"><b>Printed Exceptions:</td>
<td align="left"><textarea name="printed_exceptions" rows=5 cols=55><%=rs.getString("printed_exceptions")%></textarea></td></tr>


</table>

</form>
<%
	rs.updateBoolean("e_update", false);
	rs.updateRow();
%>
<script language="javascript">
	var f = document.modifySubmittal;
	var d = f.received;
	d.isDate = true;
	d.eName = "Date from Sub";
	
	d = f.toArchitect;
	d.isDate = true;
	d.eName = "Date to Architect";
	
	d = f.fromArchitect;
	d.isDate = true;
	d.eName = "Date from Architect";
	
	d = f.toSub;
	d.isDate = true;
	d.eName = "Date to Sub";
	
	f.description.spell = true;
	f.comment_to_sub.spell = true;
	f.comment_to_architect.spell = true;
	f.printed_exceptions.spell = true;
	
	parent.opener.location.reload();
</script>
<%
}
rs.getStatement().close();
db.disconnect();
%>
</body></html>

