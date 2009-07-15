<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.FormHelper"%>
<%@page import="java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="action" value="processCompanyInfo.jsp"/>
	</jsp:include>
<font size="+1">My Company</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; My Company &nbsp; 
<a href="myInfo.jsp">My Info</a> &nbsp;
<a href="contact.jsp">Add New User</a><hr>
<%
db.connect();
String query = "select * from company where company_id = " + db.company_id;
ResultSet rs = db.getStatement().executeQuery(query);
if (rs.next()) {
%>
<table>
<tr>
	<td class="lbl">Name:</td>
	<td colspan="3"><input type="text" size="70" name="company_name" 
		value="<%= FormHelper.string(rs.getString("company_name")) %>">*</td>
</tr>
<tr>
	<td class="lbl">Address:</td>
	<td><input type="text" name="address" 
		value="<%= FormHelper.string(rs.getString("address")) %>"></td>
	<td class="lbl">Description:</td>
	<td align="left"><%= FormHelper.string(rs.getString("description")) %></td>
</tr>
<tr>
	<td class="lbl">City:</td>
	<td><input type="text" name="city" value="<%= FormHelper.string(rs.getString("city")) %>"></td>
	<td class="lbl">Website:</td>
	<td align="left"><input type="text" name="website" 
		value="<%= FormHelper.string(rs.getString("website")) %>"></td>
</tr>
<tr>
	<td class="lbl">State:</td>
	<td><input type="text" name="state" value="<%= FormHelper.string(rs.getString("state")) %>"></td>
	<td class="lbl">Federal ID:</td>
	<td align="left"><input type="text" name="federal_id" 
		value="<%= FormHelper.string(rs.getString("federal_id")) %>"></td>
</tr>
<tr>
	<td class="lbl">Zip Code:</td>
	<td><input type="text" name="zip" value="<%= FormHelper.string(rs.getString("zip")) %>"
		maxlength="10"></td>
	<td class="lbl">License Number:</td>
	<td align="left"><input type="text" name="license_number" 
		value="<%= FormHelper.string(rs.getString("license_number")) %>"></td>
</tr>
<tr>
	<td class="lbl">Phone:</td>
	<td><input type="text" name="phone" value="<%= FormHelper.string(rs.getString("phone")) %>"
		maxlength="14"></td>
	<td class="lbl">Safety Manual:</td>
	<td>
<%
if (FormHelper.oldBoolean(rs.getString("safety_manual"))) 
	out.println("<img src=\"../images/checkmark.gif\">");
else out.println("&nbsp;");
%>
</td>
</tr>
<tr>
	<td class="lbl">Fax:</td>
	<td><input type="text" name="fax" value="<%= FormHelper.string(rs.getString("fax")) %>"
		maxlength="14">*</td>
</tr>
</table>
<div class="bold" style="margin-top: 10px;">Other company contacts:</div>
<table cellspacing="0" cellpadding="3" style="margin-top: 10px; margin-bottom: 10px;">
<tr>
	<td class="left head">Open</td>
	<td class="head">Name</td>
	<td class="head right">Online Access</td>
</tr>
<%
	query = "select contact_id, name, role_name from contacts left join contact_roles "
		+ "using (email) where company_id = " + db.company_id + " and contact_id != " + db.contact_id 
		+ " order by name";
	ResultSet contact = db.getStatement().executeQuery(query);
	boolean color = false;
	while (contact.next()) {
%>
<tr <% if (color) out.print("class=\"gray\""); %> onMouseOver="rC(this);" onMouseOut="rCl(this);">
	<td class="left right"><a href="contact.jsp?id=<%= contact.getString("contact_id") %>">Open</a></td>
	<td class="it"><%= FormHelper.stringTable(contact.getString("name")) %></td>
	<td class="input right acenter"><% if (contact.getString("role_name") != null) 
		out.print("<img src=\"../images/checkmark.gif\">"); else out.print("&nbsp;"); %></td>
</tr>
<%
		color = !color;
	}
	if (contact != null) contact.getStatement().close();

%>
</table>
<% 
}
db.disconnect();
%>
</form>
<script language="javascript">
	var m = document.main;
	var f = m.company_name;
	f.focus();
	f.select();
	f.required = true;
	f.eName = "Name";
	
	f = m.zip;
	f.isZip = true;
	f.eName = "Zip Code";
	
	f = m.phone;
	f.isPhone = true;
	f.eName = "Phone";
	
	f = m.fax;
	f.isPhone = true;
	f.eName = "Fax";
	f.required = true;
</script>
</td>
</tr>
</table>
</body>
</html>