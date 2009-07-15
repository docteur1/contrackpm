<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
int siteId = Integer.parseInt(request.getParameter("site_id"));
String query = "select * from cost_codes where site_id = " + siteId + " order by "
	+ "costorder(division), costorder(cost_code), cost_type";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String cost, phase, division, id;
boolean color = true;
%>
<html>
	<head>
		<LINK REL="stylesheet" HREF="../../stylesheets/v2.css" TYPE="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
		<script src="../../utils/table.js"></script>
		<script language="javascript">
			function deleteCode(id) {
				if(confirm("Delete this code?")) location="deleteGenericCode.jsp?site_id=<%= siteId %>&id=" + id;
			}
		function editwin(id) {
			msgWindow=open('','newCode','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=350,height=200,left=25,top=25');
			msgWindow.location.href = "editGenericCode.jsp?site_id=<%= siteId %>&id=" + id;
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		function addCode() {
			msgWindow=open('','newCode','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=350,height=200,left=25,top=25');
			msgWindow.location.href = "addGenericCode.jsp?site_id=<%= siteId %>";
			if (msgWindow.opener == null) msgWindow.opener = self;
			msgWindow.focus();
		}
		</script>
	</head>
	<body>
	<font size="+1">Phase Codes</font><hr>
	<a href="../superAdmin.jsp">Administration</a> &gt; Phase Codes&nbsp;&nbsp;<a href="javascript:addCode()">Add Code</a><hr>
<table style="margin-bottom: 8px;">
<tr>
	<td class="lbl">Site</td>
	<td><select name="site_id" onChange="window.location='genericCodes.jsp?site_id=' + this.value;">
<%
ResultSet sites = db.dbQuery("select site_id, site_name from sites");
while (sites.next()) out.println("<option value=\"" + sites.getString(1) + "\" " + 
		FormHelper.sel(sites.getInt(1), siteId) + ">" + sites.getString(2) + "</option>");
if (sites != null) sites.getStatement().close();
%>
		</select></td>
</tr>
</table>
<table cellspacing="0" cellpadding="3" id="tableHead">
	<tr>
				<td class="head left nosort">Delete</td>
				<td class="head nosort">Edit</td>
				<td class="head nosort aright">Div</td>
				<td class="head nosort aright">Code</td>
				<td class="head nosort">Description</td>
				<td class="head nosort">Delete</td>
				<td class="head nosort">Edit</td>
				<td class="head nosort aright">Div</td>
				<td class="head nosort aright">Code</td>
				<td class="head nosort right">Description</td>
			</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%			while (rs.next()) {
				color = !color;
				id = rs.getString("code_id");
				cost = rs.getString("cost_code");
				phase = rs.getString("cost_type");
				division = rs.getString("division");
				%>
	<tr onMouseOver="b(this);" onMouseOut="n(this);" class="<%= color?"gray":"" %>">
				<td class="left"><a href="javascript:deleteCode(<%= id %>);">Delete</a>
				<td class="right"><a href="javascript:editwin(<%= id %>);">Edit</a>
				<td class="it aright"><%=division%></td>
				<td class="it aright"><%= cost + "-" + phase%></td>
				<td class="it"><%=rs.getString("description")%></td>
<%
				if (rs.next()) {
					cost = rs.getString("cost_code");
					phase = rs.getString("cost_type");
					division = rs.getString("division");
					id = rs.getString("code_id");

						%>
				<td class="left"><a href="javascript:deleteCode(<%= id %>);">Delete</a>
				<td class="right"><a href="javascript:editwin(<%= id %>);">Edit</a>
				<td class="it aright"><%=division%></td>
				<td class="it aright"><%= cost + "-" + phase%></td>
				<td class="right"><%=rs.getString("description")%></td>
<%				} else {// End second column if
				%>
				<td colspan="2" class="left right">&nbsp;</td>
				<td colspan="3" class="right">&nbsp;</td>
			</tr>
<%			} //End If
		}
		rs.close();
		db.disconnect();

		// End while
			%>
		</table>
	</body>
</html>
