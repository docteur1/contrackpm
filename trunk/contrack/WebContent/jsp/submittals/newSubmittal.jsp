<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.Widgets" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.SUBMITTALS, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String contract_id = request.getParameter("contract_id");
String submittal_num="";
String query = "select left(company_name, 30) as company_name, name, contract_id, job_cost_detail.cost_code_id, division, phase_code, cost_code, "
	+ "code_description from job_cost_detail left join contracts using(cost_code_id) left join company using(company_id) "
	+ "left join contacts using(contact_id) where job_cost_detail.job_id = " + attr.getJobId() 
	+ " order by costorder(division), costorder(cost_code), phase_code";
Database db = new Database();
ResultSet rs4 = db.dbQuery(query);

query = "select job_contact_id, company_name, contacts.name, isDefault from job_contacts join company "
	+ "on job_contacts.company_id = company.company_id left join contacts using (contact_id) where "
	+ "job_id = " + attr.getJobId() + " and type='Architect' order by company_name";
ResultSet rs3 = db.dbQuery(query);
%>

<html>
	<head>
		<title>New Submittal</title>
		<link rel=stylesheet href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<script language="javascript" src="../utils/verify.js"></script>
		<script language="javascript" src="../utils/spell.js"></script>
		<script language="javascript">
			function spell() {
				spellCheck(f);
			}
			function save() {
				if(checkForm(f)) f.submit();
			}
<%
if (!rs4.isBeforeFirst()) {
%>
			window.alert("No contracts exist!\nPlease create a contract first!");
			parent.close();
<%
}
%>
		</script>
		<script language="javascript" src="../utils/calendar.js"></script>
	</head>
	<body>
	<form name="newSubmittal" action="processSubmittal.jsp" method="POST">
	<font size="+1">New Submittal</font><hr>
		<table valign="top">
						<tr><td align="right"><b>Subcontract/Code:</b></td><td>
								<select name="id">
									<%
									String conId = null;
									while (rs4.next()){
										conId = rs4.getString("contract_id");
									%>
									<option value="<%= rs4.getString("cost_code_id") + (conId != null ? "c" + conId : "") %>" 
									<%= FormHelper.sel(conId, contract_id) %>><%= rs4.getString("division") %> 
									<%= rs4.getString("cost_code")%>-<%=rs4.getString("phase_code") + " "  
									+ rs4.getString("code_description")
									+ (rs4.getString("company_name") != null ? " - " + rs4.getString("company_name") : "")
									+ (rs4.getString("name")!=null?", " + rs4.getString("name"):"") %>
									</option>
									<%}
									%>
								</select>
							</td></tr>
							<tr>
			<tr><td align="right"><b>Submittal Number:</td>
			    <td><input type="text" name="submittal_num" maxlength="15" size="4" value="<%=submittal_num%>"></td>
			</tr>
					<tr><td align="right"><b>Alt Spec Num:</td><td><input type="text" name="altCostCode" maxlength="100"> <i>Leave blank to use phase code</i></td></tr>

				<tr><td align="right"><b>Attempt: </td><td align="left"><select name="attempt">
								<option value = "1">1</option>
								<option value = "2">2</option>
								<option value = "3">3</option>
								<option value = "4">4</option>
								<option value = "5">5</option>
								<option value = "6">6</option>
								<option value = "7">7</option>
								<option value = "8">8</option>
							</select></td></tr>
					<tr><td align="right"><b>Architect:</b></td>
						 <td><select name="architect_id">
<%
while(rs3.next()){
%>
						<option value = "<%=rs3.getInt("job_contact_id")%>" 
							<%= FormHelper.sel(rs3.getBoolean("isDefault")) %>>
							<%= rs3.getString("company_name") + (rs3.getString("name")!=null?" - " + rs3.getString("name"):"") %></option>
<% } %>
						</select></td></tr>
					<tr><td align="right"><b><a href="javascript:insertDate('received')">Date from Sub:</a></td>
							<td><input type="text" id="received" name="received" maxlength=10 size=8 value="">
							<img id="calreceived" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
							</td></tr>

					<tr><td align="right"><b><a href="javascript:insertDate('toArchitect')">Date to Architect:</a></td>
							<td><input type="text" id="toArchitect" name="toArchitect" maxlength=10 size=8 value="">
							<img id="caltoArchitect" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
						</td></tr>

					<tr><td align="right"><b><a href="javascript:insertDate('fromArchitect')">Date from Architect:</a></td>
							<td><input type="text" id="fromArchitect" name="fromArchitect" maxlength=10 size=8 value="">
							<img id="calfromArchitect" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
							</td></tr>

					<tr><td align="right"><b><a href="javascript:insertDate('toSub')">Date to Sub:</a></td>
							<td><input type="text" id="toSub" name="toSub" maxlength=10 size=8 value="">
							<img id="caltoSub" src="../images/calendar.gif" border="0"> - mm/dd/yyyy
							</td></tr>
				<tr><td align="right"><b>From:</td>
				<td><%= com.sinkluge.utilities.Widgets.userList(attr.getUserId(), "user_id") %></td></tr>

		<tr><td align="right"><b>Submittal Status: </td><td align="left">
			<%= Widgets.list("submittal_status", "Pending", db) %>
		</td></tr>

		<tr><td align="right"><b>Submittal Type:</td><td align="left">
			<%= Widgets.list("submittal_type", "Shop Drawing", db) %>
		</td></tr>

												<tr><td align="right"><b>Description:</td>

														<td align="left"><textarea name="description" rows=5 cols=55></textarea></td></tr>

													<tr><td align="right"><b>Comment To Architect:</td>
															<td align="left"><textarea name="comment_to_architect" rows=5 cols=55></textarea></td></tr>



														<tr><td align="right"><b>Comment To Subcontractor:</td>

																<td align="left"><textarea name="comment_to_sub" rows=5 cols=55></textarea></td></tr>
															<tr><td align="right"><b>Printed Exceptions:</td>

																	<td align="left"><textarea name="printed_exceptions" rows=5 cols=55></textarea></td></tr>


															</table>

														</form>
<script language="javascript">
	var f = document.newSubmittal;
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
	
</script>
	</body>
</html>
<%
rs4.close();
rs3.close();
db.disconnect();
%>
