<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.database.Database" %>
<%
String id = request.getParameter("id");
String query="select * from company where company_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if(rs.next()) {
%>
<html>
<head>
	<title>New Contact</title>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" />
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
	<script language="javascript" src="../utils/verify.js"></script>
	<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
</head>
<body>
<form name="main" method="post" action="processContact.jsp" onSubmit="return checkForm(this)">
	<input type = "hidden" name="id" value="<%= id %>">
<font size="+1">New Contact - <%=rs.getString("company_name") %>
</font><hr>

<table>
<tr><td align="right"><b>Name</b></td>
	<td align="left"><input type="text" size="20" name="name"></td></tr>
<tr><td align="right"><b>Title:</b></td>
    <td align="left"><input type="text" size="20" name="title"></td></tr>
<tr><td align="right"><b>Address:</b></td>
    <td align="left"><input type="text" size="20" name="address" value="<%=rs.getString("address")%>" maxlength="100"></td></tr>
<tr><td align="right"><b>City:</b></td>
    <td align="left"><input type="text" size="20" name="city" value="<%=rs.getString("city")%>"></td></tr>
<tr><td align="right"><b>State:</b></td>
    <td align="left"><input type="text" size="20" name="state" value="<%=rs.getString("state")%>"></td></tr>
<tr><td align="right"><b>Zip:</b></td>
    <td align="left"><input type="text" size="20" maxlength="10" name="zip" value="<%=rs.getString("zip")%>" ></td></tr>
<tr><td align="right"><b>Radio Number:</b></td>
    <td align="left"><input type="text" size="20" name="radio_num"></td></tr>
<tr><td align="right"><b>Phone:</b></td>
    <td align="left"><input type="text" size="20" maxlength="16" name="phone" value="<%=rs.getString("phone")%>" > <b>Ext: </b><input type="text" size=4 name="extension" ></td></tr>
<tr><td align="right"><b>Fax:</b></td>
    <td align="left"><input type="text" size="20" maxlength="16" name="fax" value="<%=rs.getString("fax")%>" ></td></tr>
<tr><td align="right"><b>Mobile:</b></td>
    <td align="left"><input type="text" size="20" maxlength="16" name="mobile_phone"></td></tr>
<tr><td align="right"><b>Email:</b></td>
    <td align="left"><input type="text" size="25" name="email"></td></tr>
<tr><td align="right"><b>Pager:</b></td>
    <td align="left"><input type="text" size="25" maxlength="16" name="pager" ></td></tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" value="Save">
		&nbsp; <input type="button" value="Close" onClick="window.close()"></td>
</tr>
</table>
</form>
<script>
	var d = document.main;
	var f = d.name;
	f.required = true;
	f.eName = "Name";
	f.focus();
	
	f = d.zip;
	f.isZip = true;
	f.eName = "Zip";

	f = d.radio_num;
	f.isInt = true;
	f.eName = "Radio Number";

	f = d.phone;
	f.isPhone = true;
	f.eName = "Phone";
	
	f = d.fax;
	f.isPhone = true;
	f.eName = "Fax";
	
	f = d.mobile_phone;
	f.isPhone = true;
	f.eName = "Mobile";
	
	f = d.email;
	f.isEmail = true;
	f.eName = "Email";
	
	f = d.pager;
	f.isPhone = true;
	f.eName = "Pager";	
	
</script>
<%
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
</body>
</html>
