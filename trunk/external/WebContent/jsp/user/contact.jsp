<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.FormHelper"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
String contact_id = request.getParameter("id");
boolean isNew = contact_id == null;
%>
<jsp:include page="../workspace.jsp">
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="action" value="processContact.jsp"/>
	</jsp:include>
<font size="+1"><% if (isNew) out.print("Add New User"); else out.print("Edit User"); %></font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">My Company</a> &gt; <% if (isNew) out.print("Add New User"); else out.print("Edit User"); %><hr>
<%
if (contact_id == null) contact_id = Integer.toString(db.contact_id);
String query = "";
if (!isNew) query = "select * from contacts left join contact_roles on contacts.email = contact_roles.email where "
	+ "contact_id = " + contact_id;
else query = "select *, null as role_name from company where company_id = " + db.company_id;
db.connect();
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
String full_name = "";
String email = "";
String phone = "";
String ext = "";
String fax = "";
String mobile = "";
String radio = "";
String address = "";
String city = "";
String state = "";
String zip = "";
String pager = "";
boolean online = false;
if (rs.next()) {
	if (!isNew) {
		full_name = rs.getString("name");
		email = rs.getString("email");
		radio = rs.getString("radio_num");
		pager = rs.getString("pager");
		online = rs.getString("role_name") != null;
		mobile =rs.getString("mobile_phone");
		ext = rs.getString("extension");
	}
	phone = rs.getString("phone");
	fax = rs.getString("fax");
	address = rs.getString("address");
	city = rs.getString("city");
	state = rs.getString("state");
	zip = rs.getString("zip");
}
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.disconnect();
if (isNew) out.print("<input type=\"hidden\" name=\"isNew\" value=\"true\">");
%>
<input type="hidden" name="contact_id" value="<%= request.getParameter("id") %>">
<table>
	<tr>
		<td class="lbl">Full Name</td>
		<td><input type="text" name="full_name" value="<%= FormHelper.string(full_name) %>"> *</td>
	</tr>
	<tr>
		<td class="lbl">Email/Username</td>
		<td><input type="text" name="email" value="<%= FormHelper.string(email) %>" maxlength="50"> *</td>
	</tr>
	<tr>
		<td class="lbl">Office Phone</td>
		<td><input type="text" name="phone" value="<%= FormHelper.string(phone) %>" maxlength="14"> <b>Ext</b> 
			<input type="text" name="ext" value="<%= FormHelper.string(ext) %>" size="5"></td>
	</tr>
	<tr>
		<td class="lbl">Fax</td>
		<td><input type="text" name="fax" value="<%= FormHelper.string(fax) %>" maxlength="14"> *</td>
	</tr>
	<tr>
		<td class="lbl">Mobile Phone</td>
		<td><input type="text" name="mobile" value="<%= FormHelper.string(mobile) %>" maxlength="14"></td>
	</tr>
	<tr>
		<td class="lbl">Pager</td>
		<td><input type="text" name="pager" value="<%= FormHelper.string(pager) %>" maxlength="14"></td>
	</tr>
	<tr>
		<td class="lbl">Nextel Radio</td>
		<td><input type="text" name="radio" value="<%= FormHelper.string(radio) %>" size="5"></td>
	</tr>
	<tr>
		<td class="lbl">Mailing Address</td>
		<td><input type="text" name="address" value="<%= FormHelper.string(address) %>"></td>
	</tr>
	<tr>
		<td class="lbl">City</td>
		<td><input type="text" name="city" value="<%= FormHelper.string(city) %>"></td>
	</tr>
	<tr>
		<td class="lbl">State</td>
		<td><input type="text" name="state" value="<%= FormHelper.string(state) %>"></td>
	</tr>
	<tr>
		<td class="lbl">Zipcode</td>
		<td><input type="text" name="zip" value="<%= FormHelper.string(zip) %>" size="8"></td>
	</tr>
	<tr>
		<td colspan="2"><i>* required fields</td>
	</tr>
	</table>
<%
if (!isNew && !online) {
%>
<p><b>Note:</b> This user does not currently have online access. Please contact Ellsworth Paulsen personnel to allow this user online access.
<%
}
%>

</td>
</tr>
</table>
</form>
<script language="javascript">
	var m = document.main;
	var f = m.full_name;
	f.select();
	f.focus();
	f.required = true;
	f.eName = "Full Name";
	
	f = m.email;
	f.required = true;
	f.isEmail = true;
	f.eName = "Email/Username";
	
	f = m.phone;
	f.isPhone = true;
	f.eName = "Office Phone";
	
	f = m.ext;
	f.isInt = true;
	f.eName = "Office Phone Ext";
	
	f = m.fax;
	f.required = true;
	f.isPhone = true;
	f.eName = "Fax";
	
	f = m.mobile;
	f.isPhone = true;
	f.eName = "Mobile Phone";
	
	f = m.zip;
	f.isZip = true;
	f.eName = "Zipcode";
	
	f = m.radio;
	f.isInt = true;
	f.eName = "Nextel Radio";
	
	f = m.pager;
	f.isPhone = true;
	f.eName = "Pager";
</script>
</body>
</html>