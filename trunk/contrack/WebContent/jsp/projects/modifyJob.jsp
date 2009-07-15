<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.JOB, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String query = "select * from job where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String method, cat, submit_co_to, submittals;
if (rs.next()) {
	submittals = rs.getString("submittal_copies");
	submit_co_to = FormHelper.string(rs.getString("submit_co_to"));
	method = FormHelper.string(rs.getString("contract_method"));
	cat = FormHelper.string(rs.getString("project_category"));
%>

<html>
<head>
 	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
 	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
 	<script language="javascript" src="../utils/spell.js"></script>
	<script language="javascript" src="../utils/calendar.js"></script>
	<script language="javascript" src="../utils/verify.js"></script>
</head>
<body>
<form name="editJob" action="processModifyJob.jsp" method="POST" onSubmit="return checkForm(this);">
<font size="+1">Modify Project</font><hr>
<a href="reviewJobInfo.jsp">Project</a> &gt; Modify Project<hr>
<%
if (request.getParameter("saved") != null) out.print("<div class=\"red bold\">Saved</div><hr>");
%>

<table>
	<tr>
		<td class="lbl">Project Number:</td>
		<td><input type="text" name="job_num" maxlength="15" value="<%= attr.getJobNum() %>"></td>
	</tr>
  <tr>
    <td class="lbl">Name:</td>
    <td colspan="3"><input type="text" name="job_name" size="50" value="<%= attr.getJobName() %>"></td>
  </tr>
  <tr>
    <td class="lbl">Address:</td>
    <td><input type="text" name="address" value="<%= FormHelper.string(rs.getString("address")) %>"></td>
    <td class="lbl">Start Date:</td>
	<td><input type="text" id="start_date" name="start_date" maxlength=10 size=8 value="<%= FormHelper.date(rs.getDate("start_date")) %>">
		<img id="calstart_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
  </tr>
  <tr>
    <td class="lbl">City:</td>
    <td><input type="text" name="city" value="<%= FormHelper.string(rs.getString("city")) %>"></td>
    <td class="lbl">End Date:</td>
	<td><input type="text" id="end_date" name="end_date" maxlength=10 size=8 value="<%= FormHelper.date(rs.getDate("end_date")) %>">
		<img id="calend_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
  </tr>
  <tr>
    <td class="lbl">State:</td>
    <td><input type="text" name="state" value="<%= FormHelper.string(rs.getString("state")) %>"></td>
	<td class="lbl">Submit COs to:</td>
	<td><select name="submitCO">
		<option value="Architect" <%= FormHelper.sel(submit_co_to, "Architect") %>>Architect</option>
		<option value="Owner" <%= FormHelper.sel(submit_co_to, "Owner")  %>>Owner</option>
	</select></td>
  </tr>
  <tr>
    <td class="lbl">Zip Code:</td>
    <td><input type="text" name="zip" value="<%= rs.getString("zip") %>"></td>
       <td class="lbl">Builder's Risk Exp:</td>
    <td><input type="text" id="exp_date" name="exp_date" maxlength=10 size=8 value="<%= FormHelper.date(rs.getDate("builders_risk_ins_expire")) %>">
		<img id="calexp_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
  </tr>
  <tr>
    <td class="lbl">Phone #1:</td>
    <td><input type="text" name="phone_one" value="<%= FormHelper.string(rs.getString("phone_one")) %>" maxlength="14">
    <td class="lbl">Extended Support</td>
    <td><input type="checkbox" name="xSupport" value="y" <%= FormHelper.chk(rs.getString("extended_support").equals("y")) %>> &nbsp;
    	<b>Active:</b> &nbsp;<input type="checkbox" name="active" value="y" <%= FormHelper.chk(rs.getString("active").equals("y")) %>>
    	</td>
  </tr>
  <tr>
    <td class="lbl">Phone #2:</td>
    <td><input type="text" name="phone_two" value="<%= FormHelper.string(rs.getString("phone_one")) %>" maxlength="14"></td>
    <td class="lbl">Contract Method:</td>
    <td><select name="contractMethod">
<%
	query = "select val from lists where id = 'project_contract'";
	ResultSet rs2 = db.dbQuery(query);
	while (rs2.next()) out.print("<option " + FormHelper.sel(method, rs2.getString(1)) + ">" 
			+ rs2.getString(1) + "</option>");
	if (rs2 != null) rs2.getStatement().close();
	rs2 = null;
%>
    </select>
    </td>
  </tr>
  <tr>
    <td class="lbl">Fax:</td>
    <td><input type="text" name="fax" maxlength="14" value="<%= FormHelper.string(rs.getString("fax")) %>"></td>
        <td class="lbl">Category:</td>
    <td><select name="category">
<%
	query = "select val from lists where id = 'project_category'";
	rs2 = db.dbQuery(query);
	while (rs2.next()) out.print("<option " + FormHelper.sel(cat, rs2.getString(1)) + ">" 
		+ rs2.getString(1) + "</option>");
	if (rs2 != null) rs2.getStatement().close();
	rs2 = null;
%>
	</select>
	</td>
  </tr>
  <tr>

  </tr>
  <tr>
  	<td class="lbl">Start Contract $:</td>
  	<td><input type="text" name="startContract" value="<%= FormHelper.cur(rs.getFloat("contract_amount_start")) %>"></td>
  	<td class="lbl">Final Contract $:</td>
  	<td><input type="text" name="finalContract" value="<%= FormHelper.cur(rs.getFloat("contract_amount_end")) %>"></td>
  </tr>
  <tr>
  	<td class="lbl">Site Size:</td>
  	<td><input type="text" name="siteSize" value="<%= FormHelper.string(rs.getString("site_size")) %>"></td>
  	<td class="lbl">Building Size:</td>
  	<td><input type="text" name="buildingSize" value="<%= FormHelper.string(rs.getString("building_size")) %>"></td>
  </tr>
		<tr>
		<td class="lbl"># Sub Reqd:</td>
		<td><select name="submittals">
			<option value="1" <% if (submittals.equals("1")) out.print("selected");%>>1</option>
			<option value="2" <% if (submittals.equals("2")) out.print("selected");%>>2</option>
			<option value="3" <% if (submittals.equals("3")) out.print("selected");%>>3</option>
			<option value="4" <% if (submittals.equals("4")) out.print("selected");%>>4</option>
			<option value="5" <% if (submittals.equals("5")) out.print("selected");%>>5</option>
			<option value="6" <% if (submittals.equals("6")) out.print("selected");%>>6</option>
			<option value="7" <% if (submittals.equals("7")) out.print("selected");%>>7</option>
			<option value="8" <% if (submittals.equals("8")) out.print("selected");%>>8</option>
			<option value="9" <% if (submittals.equals("9")) out.print("selected");%>>9</option>
			<option value="10" <% if (submittals.equals("10")) out.print("selected");%>>10</option>
		</select></td>
		<td class="lbl">Retention Rate:</td>
		<td><input type="text" name="retention" size="10" value="<%= rs.getFloat("retention_rate")*100 %>"></td>
	</tr>
	<tr>
	<td class="lbl">Substantial Completion Date:</td>
    <td><input type="text" id="sub_date" name="sub_date" maxlength=10 size=8 value="<%= FormHelper.date(rs.getDate("substantial_completion_date")) %>">
		<img id="calsub_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		<td class="lbl">Company:</td>
		<td><select name="site_id">
<%
query = "select site_id, site_name from sites order by site_id";
rs2 = db.dbQuery(query);
while (rs2.next()) out.println("<option value=\"" + rs2.getString(1) + "\" " + FormHelper.sel(rs2.getInt(1), attr.getSiteId())
		+ ">" + rs2.getString(2) + "</option>");
if (rs2 != null) rs2.getStatement().close();
rs2 = null;
%>
		</select>
		</td>
	</tr>
  <tr>
  	<td align="right" valign="top"><b>Description:</td>
  	<td colspan="3"><textarea name="description" cols="85" rows="5" ><%= rs.getString("description")%></textarea></td>
  </tr>
  <tr>
  	<td>&nbsp;</td>
  	<td colspan="3"><input type="submit" value="Save" accesskey="s"> &nbsp; <input type="button" value="Spelling" onClick="spellCheck(this.form);">
  </tr>
<% 
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</table>
</form>
<script language="javascript">
	f = document.editJob;
	d = f.job_name;
	d.required = true;
	d.eName = "Project Name";
	
	d = f.job_num;
	d.required = true;
	d.eName = "Project Number";
	
	d = f.start_date;
	d.eName = "Start Date";
	d.isDate = true;
	
	d = f.end_date;
	d.required = true;
	d.eName = "End Date";
	d.isDate = true;
	
	d = f.zip;
	d.eName = "Zip Code";
	d.isZip = true;
	
	d = f.sub_date;
	d.eName = "Substantial Comp";
	d.isDate = true;
	d.required = true;
	
	d = f.phone_one;
	d.eName = "Phone #1";
	d.isPhone = true;
	
	d = f.phone_two;
	d.eName = "Phone #2";
	d.isPhone = true;

	d = f.fax;
	d.eName = "Fax";
	d.isPhone = true;
	
	d = f.exp_date;
	d.eName = "Builder's Rick Exp";
	d.isDate = true;
	
	d = f.startContract;
	d.eName = "Start Contract";
	d.isFloat = true;
	d.required = true;
	
	d = f.finalContract;
	d.eName = "Final Contract";
	d.isFloat = true;
	
	d = f.description;
	d.spell = true;
	
	d = f.retention;
	d.required = true;
	d.isFloat = true;
	d.eName = "Retention";
	
</script>
</body>
</html>
