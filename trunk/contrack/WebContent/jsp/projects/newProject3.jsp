<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.text.DecimalFormat" %>
<%@page import="com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
String aname;
String avalue;
String oname;
String ovalue;
if (request.getParameter("ocontact_id") != null) {
	oname = "ocontact_id";
	ovalue = request.getParameter("ocontact_id");
} else {
	oname = "ocompany_id";
	ovalue = request.getParameter("ocompany_id");
}
if (request.getParameter("acontact_id") != null) {
	aname = "acontact_id";
	avalue = request.getParameter("acontact_id");
} else {
	aname = "acompany_id";
	avalue = request.getParameter("acompany_id");
}
String query = null;
ResultSet rs = null;
String job_nums = "";
query = "select job_num from job";
Database db = new Database();
rs = db.dbQuery(query);
while (rs.next()) {
	if (!rs.isLast()) job_nums += "'" + rs.getString(1) + "',";
	else job_nums += "'" + rs.getString(1) + "'";
}
if (rs != null) rs.getStatement().close();
rs = null;
%>
<html>
<head>
	<title>Contrack - New Project (3 of 3)</title>
	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script src="../utils/verify.js"></script>
	<script src="../utils/spell.js"></script>
	<script>
		var job_nums = new Array(<%= job_nums %>);
		if (job_nums.length == 1) job_nums[0] = <%= job_nums.length()>0?job_nums:"0" %>;
		function verifyNums() {
			var f = document.newJob.job_num;
			f.style.backgroundColor = "#FFFFFF";
			var error = false;
			for(var i = 0; i < job_nums.length; i++) {
				if (f.value == job_nums[i]) error = true;
			}
			if (error) {
				alert("Error\n-------------\nProject Numbers must be unique.");
				f.style.backgroundColor = "#FFFFCC";
				return false;
			} else return true;
		}
		function save(obj) {
			return checkForm(obj) && verifyNums();
		}
	</script>
	<script src="../utils/calendar.js"></script>
</head>
<body>
<form name="newJob" action="newProject4.jsp" method="POST" onSubmit="return save(this);">
<font size="+1">New Project (3 of 3)</font><hr>
<a href="../">Contrack</a> &gt; 
<a href="newProject.jsp">New Project (Owner Contact)</a> &gt; 
<a href="newProject2.jsp?<%= oname %>=<%= ovalue %>">New Project (Architect Contact)</a> &gt; New Project
<hr>
<%
out.print(FormHelper.hidden(oname, ovalue));
out.print(FormHelper.hidden(aname, avalue));
%>
<table>
  <tr>
    <td class="lbl">Project Number:</td>
    <td><input type="text" name="job_num" size="25" maxlength="15" onChange="verifyNums();"></td>
   	<td align="right"><b><a href="javascript:insertDate('start_date');">Start Date:</a></td>
	<td><input type="text" id="start_date" name="start_date" maxlength=10 size=8>
		<img id="calstart_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
    </tr>
    <tr>
    <td class="lbl">Project Name:</td>
    <td><input type="text" name="job_name" size="25"></td>
	<td class="lbl">End Date:</td>
	<td><input type="text" id="end_date" name="end_date" maxlength=10 size=8>
		<img id="calend_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
    </tr>
  <tr>
    <td align="right" width=100><b>Address:</td>
    <td><input type="text" name="address" size="25"></td>
    <td class="lbl">Start Contract $:</td>
  	<td><input type="text" name="startContract" size="10"></td>
  </tr>
  <tr>
    <td class="lbl">City:</td>
    <td><input type="text" name="city" size="25"></td>
	   <td colspan="2" class="acenter bold">Builder&#39;s Risk Insurance</td>
  <tr>
    <td class="lbl">State:</td>
    <td><input type="text" name="state" size="25"></td>
    	<td class="lbl">Expiration Date:</td>
	<td><input type="text" id="exp_date" name="exp_date" maxlength=10 size=8>
		<img id="calexp_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
    
  <tr>
    <td class="lbl">Zip Code:</td>
    <td><input type="text" name="zip" size="25" maxlength="10"></td>
    <td class="lbl">Provide Extended Support</td>
    <td><input type="checkbox" name="xSupport" value="y"></td>
  </tr>
  <tr>
    <td class="lbl">Phone #1:</td>
		<td><input type="text" name="phone1" maxlength="14"></td>
        <td class="lbl">Category:</td>
    <td><select name="category">
<%
query = "select * from lists where id = 'project_category' order by val";
rs = db.dbQuery(query);
while (rs.next()) out.print("<option>" + rs.getString("val") + "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
%>
	</select>
	</td>
  </tr>
  <tr>
    <td class="lbl">Phone #2:</td>
		<td><input type="text" name="phone2" maxlength="14"></td>
    <td class="lbl">Contract Method:</td>
    <td><select name="contractMethod">
<%
query = "select * from lists where id = 'project_contract' order by val";
rs = db.dbQuery(query);
while (rs.next()) out.print("<option>" + rs.getString("val") + "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
%>
    </select>
    </td>
  </tr>
  <tr>
    <td class="lbl">Fax:</td>
		<td><input type="text" name="fax" maxlength="14"></td>
  	<td class="lbl">Site Size:</td>
  	<td><input type="text" name="siteSize" size="10"></td>
  </tr>
  <tr>
		<td class="lbl"># Sub Req&#39;d:</td>
		<td><select name="submittals">
			<option value="1" >1</option>
			<option value="2">2</option>
			<option value="3">3</option>
			<option value="4">4</option>
			<option value="5">5</option>
			<option value="6">6</option>
			<option value="7">7</option>
			<option value="8">8</option>
			<option value="9">9</option>
			<option value="10">10</option>
		</select></td>
  	<td class="lbl">Building Size:</td>
  	<td><input type="text" name="buildingSize" size="10"></td>
  </tr>
	<tr>
		<td class="lbl">Company:</td>
		<td><select name="site_id">
<%
query = "select site_id, site_name, def from sites order by site_id";
rs = db.dbQuery(query);
while (rs.next()) out.println("<option value=\"" + rs.getString(1) + "\" " + FormHelper.sel(rs.getBoolean(3))
		+ ">" + rs.getString(2) + "</option>");
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
		</select>
		</td>
		    <td class="lbl">Substantial Comp:</td>
		    <td><input type="text" id="sub_date" name="sub_date" maxlength=10 size=8>
				<img id="calsub_date" src="../images/calendar.gif" border="0"> - mm/dd/yyyy</td>
		</tr>

  <tr>
  	<td class="lbl">Description:</td>
  	<td colspan="3"><textarea name="description" cols="80" rows="5"></textarea></td>
  </tr>
  <tr>
  	<td>&nbsp;</td>
  	<td colspan="3"><input type="submit" value="Next" accesskey="s">
  		<input type="button" value="Spelling" accesskey="k" onClick="spellCheck(this.form);">
  	</td>
  </tr>
</table>
</form>
<script language="javascript">
	f = document.newJob;
	
	d = f.job_num;
	d.required = true;
	d.eName = "Project Number";
	d.select();
	d.focus();
	
	d = f.job_name;
	d.required = true;
	d.eName = "Project Name";
	
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
	
	d = f.phone1;
	d.eName = "Phone #1";
	d.isPhone = true;
	
	d = f.phone2;
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
	
	d = f.description;
	d.spell = true;
</script>
</body>
</html>
