<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.SimpleDateFormat, com.sinkluge.utilities.Widgets" %>
<%@page import="java.util.Date, com.sinkluge.utilities.FormHelper" %>
<%@page import="java.util.GregorianCalendar, java.util.Calendar" %>
<%@page import="java.text.DecimalFormat, com.sinkluge.Type" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (attr.getJobNum() != null) {
%>
<html>
<head>
	<LINK REL="stylesheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript">
		function subInfo(){
			msgWindow=open('jobContacts.jsp','Twindow','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=600,height=490,left=25,top=25');
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function navTo(link) {
			parent.logout = false;
			window.open(link.href, link.target);
		}
		function changeButton() {
			parent.manage_top.document.manage.section.value = "ba";
			parent.manage_top.document.manage.submit();
		}
		function del() {
			if(confirm("Delete this project?")) window.location = "deleteJob.jsp";
		}
    </script>
</head>
<body>

<%
DecimalFormat df = new DecimalFormat("0.0");
SimpleDateFormat formatter = new SimpleDateFormat("MMM d, yyyy");
String query = "select job.*, site_name from job join sites using(site_id) where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
query = "select sum(days_added) from change_requests where job_id = " + attr.getJobId() + " and status = 'Approved'";
ResultSet days = db.dbQuery(query);
days.next();
float days_added = days.getFloat(1);
days.close();
days = null;
String start_date, end_date, sub_comp_date, exp_date;
Date date = null;
if (rs.next()){
	date = rs.getDate("start_date");
	if (date != null) start_date = formatter.format(date);
	else start_date = "";
	date = rs.getDate("end_date");
	GregorianCalendar cal = new GregorianCalendar ();
	if (date != null) {
		if (days_added != 0) {
	cal.setTime(date);
	cal.add(Calendar.DAY_OF_YEAR, (int) Math.round(days_added - 0.5));
	end_date = formatter.format(date) + " + " + df.format(days_added) + " days = " + formatter.format(cal.getTime());
		} else end_date = formatter.format(date);
	} else end_date = "";
	date = rs.getDate("substantial_completion_date");
	if (date != null) {
		if (days_added != 0) {
	cal.setTime(date);
	cal.add(Calendar.DAY_OF_YEAR, (int) Math.round(days_added - 0.5));
	sub_comp_date = formatter.format(date) + " + " + df.format(days_added) + " days = " + formatter.format(cal.getTime());
		} else sub_comp_date = formatter.format(date);
	} else sub_comp_date = "";
	df.applyPattern("#,###");
	date = rs.getDate("builders_risk_ins_expire");
	if (date != null) exp_date = formatter.format(date);
	else exp_date = "";
%>
<font size="+1"><%= rs.getString("job_num") + ": " + rs.getString("job_name") %></font><hr>
<a href="newProject.jsp" target="_top" onclick="navTo(this); return false;">New</a> &nbsp;
<%
df.applyPattern("#,##0");
if (sec.ok(Security.JOB, Security.WRITE)) out.print("<a href=\"modifyJob.jsp\">Modify</a> &nbsp; ");
if (sec.ok(Security.ADMIN, Security.DELETE)) out.print("<a href=\"javascript: del();\">Delete</a> &nbsp; ");
%>
<%= sec.ok(Security.JOB, Security.PRINT)
	? Widgets.docsLink(Integer.toString(attr.getJobId()), Type.PROJECT, request) :
	"" %>
<hr>
<%
if (request.getParameter("save") != null) {
%>
	<span class="red bold">Saved</span>
<%
}
%>
<table>
<%
int companyId = 0;
String cName = "Not Found";
query = "select name, company_name, company.company_id from company join job_contacts on company.company_id = "
	+ "job_contacts.company_id left join contacts on contacts.contact_id = job_contacts.contact_id "
	+ "where job_id = " + attr.getJobId() + " and isDefault = 1 and type = 'Owner'";
ResultSet temp = db.dbQuery(query);
if (temp.first()) {
	companyId = temp.getInt("company_id");
	cName = temp.getString("company_name");
	if (temp.getString("name") != null) cName += "- " + temp.getString("name");
}
temp.getStatement().close();
temp = null;
%>
<tr>
	<td class="lbl">Owner:</td>
	<td><div class="link" onclick="window.location='../contacts/modifyCompany.jsp?id=<%= companyId 
		%>';"><%= cName %></div></td>
<%
query = "select name, company_name, company.company_id from company join job_contacts on company.company_id = "
	+ "job_contacts.company_id left join contacts on contacts.contact_id = job_contacts.contact_id "
	+ "where job_id = " + attr.getJobId() + " and isDefault = 1 and type = 'Architect'";
temp = db.dbQuery(query);
if (temp.first()) {
	companyId = temp.getInt("company_id");
	cName = temp.getString("company_name");
	if (temp.getString("name") != null) cName += "- " + temp.getString("name");
}
temp.getStatement().close();
temp = null;
%>
	<td class="lbl">Architect:</td>
	<td><div class="link" onclick="window.location='../contacts/modifyCompany.jsp?id=<%= companyId 
		%>';"><%= cName %></div></td>
</tr>
<tr>
	<td class="lbl"><%= Widgets.map(rs.getString("address"), rs.getString("city"), rs.getString("state"),
		rs.getString("zip")) %></td>
	<td><%= FormHelper.string(rs.getString("address")) %>
	<td class="lbl">Start Date:</td>
	<td><%= start_date %></td>
</tr>
<tr>
	<td>&nbsp;
	<td><%= FormHelper.string(rs.getString("city")) + ", " + FormHelper.string(rs.getString("state")) + " " + FormHelper.string(rs.getString("zip")) %></td>
	<td class="lbl">End Date:</td>
	<td><%= end_date %></td>
</tr>
<tr>
	<td class="lbl">Phones:</td>
	<td><%= FormHelper.string(rs.getString("phone_one")) %></td>
	<td class="lbl">Substan'l Comp Date:</td>
	<td><%= sub_comp_date %></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><%= FormHelper.string(rs.getString("phone_two")) %></td>
	<td align="center" colspan=2><b>Builder's Risk Insurance</b></td>
</tr>
<tr>
	<td class="lbl">Fax:</td>
	<td><%= rs.getString("fax") %></td>
	<td class="lbl">Exp Date:</td>
<%
	if(date != null) {
		Date currDate = new Date();
		if (currDate.compareTo(date) > 0 ) out.print("<td><font color=\"red\"><b>EXPIRED: " + exp_date + "</font></td>");
		else out.print("<td>" + exp_date + "</td>");
	} else out.print("<td><font color=\"red\"><b>No Insurance Recorded!</td>");
%>
</tr>
<tr>
	<td class="lbl"># Sub Req'd:</td>
	<td><%= rs.getString("submittal_copies") %></td>
	<td class="lbl">Building Size:</td>
	<td><%= rs.getString("building_size") %></td>
</tr>
<tr>
	<td class="lbl">COs Submitted to:</td>
	<td><%= rs.getString("submit_co_to") %></td>
	<td class="lbl">Site Size:</td>
	<td><%= rs.getString("site_size") %></td>
</tr>
<tr>
	<td class="lbl">Category:</td>
	<td><%= rs.getString("project_category") %></td>
<%
	df.applyPattern("0.0#");
%>
	<td class="lbl">Retention:</td>
	<td><%= df.format(rs.getFloat("retention_rate")*100) %> %</td>
</tr>
<%
df.applyPattern("#,##0");
%>
<tr>
	<td class="lbl">Start Contract Amount:</td>
	<td>$<%= df.format(rs.getFloat("contract_amount_start")) %></td>
	<td class="lbl">Contract Method:</td>
	<td><%= rs.getString("contract_method")%></td>
</tr>
<tr>
	<td class="lbl">Final Contract Amount:</td>
	<td>$<%= df.format(rs.getFloat("contract_amount_end")) %></td>	
	<td class="lbl">Company:</td>
	<td><%= rs.getString("site_name") %></td>
</tr>
<tr>
	<td class="lbl">ID:</td>
	<td colspan="3"><%= Widgets.logLinkWithId(Integer.toString(attr.getJobId()), 
		com.sinkluge.Type.PROJECT, "window", request) %></td>
</tr>
</table>
<table>
<tr>
	<td class="lbl">Description:</td>
	<td colspan="3"><%= rs.getString("description") %></td>
</tr>
</table>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
} else {
%>
<script>
	parent.location = "newProject.jsp";
</script>
<%
}
%>
</body>
</html>























