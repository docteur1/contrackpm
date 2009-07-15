<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(sec.SUBCONTRACT, sec.PRINT)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
		<title>Blank Lien Waiver</title>
		<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
		<script language="javascript" src="../utils/verify.js"></script>
	</head>
<body>
	<form name="lien" method="POST" action="blankLienWaiver.jsp">
	<font size="+1">Search for a Company</font><hr>
	<b>Company Name: </b><input type="text" name="comp" value=""><p>
	<input type="submit" value="Search">
	</form>
<%
if (request.getParameter("comp") != null) {
%>
	<hr><font size="+1">Select a Company</font><hr>
<%
	String query = "select company_id, company_name from company where company_name like ? order by "
		+ "company_name limit 25";
	Database db = new Database();
	PreparedStatement ps = db.preStmt(query);
	ps.setString(1, request.getParameter("comp") + "%");
	ResultSet rs = ps.executeQuery();
	while (rs.next()) {
%>
	<a href="getLienAmount.jsp?company_id=<%= rs.getInt("company_id") %>"><%= rs.getString("company_name") %></a><br>
<%
	}
	rs.close();
	db.disconnect();
%>
<p>
<input type="button" value="Start Over" onClick="location='blankLienWaiver.jsp'">
<%
} else {
%><hr><font size="+1">Or Enter Information</font><hr>
<table>
<form name="blank" method="POST" action="customLienWaiver.jsp" onSubmit="return checkForm(this);">
<tr>
	<td align="right"><b>Company:</b></td>
	<td><input type="text" name="company" value=""></td>
</tr>
<tr>
	<td align="right"><b>Address:</b></td>
	<td><input type="text" name="address" value=""></td>
</tr>
<tr>
	<td align="right"><b>City:</b></td>
	<td><input type="text" name="city" value=""></td>
</tr>
<tr>
	<td align="right"><b>State:</b></td>
	<td><input type="text" name="state" value=""></td>
</tr>
<tr>
	<td align="right"><b>Zip Code:</b></td>
	<td><input type="text" name="zip" value=""></td>
</tr>
<tr>
	<td align="right"><b>Phone:</b></td>
	<td><input type="text" name="phone" value=""></td>
</tr>
<tr>
	<td align="right"><b>Fax:</b></td>
	<td><input type="text" name="fax" value=""></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Next"></td>
</table>
</form>

	<script language="javascript">
		document.lien.comp.focus();
		var d = document.blank;
		var f = d.company;
		f.required = true;
		f.eName = "Company";
		f = d.zip;
		f.isZip = true;
		f.eName = "Zip Code";
		f = d.phone;
		f.isPhone = true;
		f.eName = "Phone";
		f = d.fax;
		f.isPhone = true;
		f.eName = "Fax";
	</script>
	<%
}
%>
</body>
</html>
