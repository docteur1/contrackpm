<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.FormHelper"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="action" value="processContactInfo.jsp"/>
	</jsp:include>
<font size="+1">Update My Info</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">My Company</a> &gt; My Info &nbsp; <a href="changePassword.jsp">Change Password</a><hr>
<%
String query = "select contacts.*, contact_users.font_size from contacts join contact_users using(email) where contact_id = " + db.contact_id;
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
int font_size = 10;
if (rs.next()) {
	full_name = rs.getString("name");
	email = rs.getString("email");
	phone = rs.getString("phone");
	ext = rs.getString("extension");
	fax = rs.getString("fax");
	mobile = rs.getString("mobile_phone");
	radio = rs.getString("radio_num");
	address = rs.getString("address");
	city = rs.getString("city");
	state = rs.getString("state");
	zip = rs.getString("zip");
	pager = rs.getString("pager");
	font_size = rs.getInt("font_size");
}
if (rs != null) rs.close();
rs = null;
%>
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
		<td class="lbl">Font Size</td>
		<td><select name="font_size">
			<option <% if (font_size == 8) out.print("selected"); %>>8</option>
			<option <% if (font_size == 9) out.print("selected"); %>>9</option>
			<option <% if (font_size == 10) out.print("selected"); %>>10</option>
			<option <% if (font_size == 11) out.print("selected"); %>>11</option>
			<option <% if (font_size == 12) out.print("selected"); %>>12</option>
			</select> pt</td>
	</tr>
	<tr>
		<td colspan="2"><i>* required fields</td>
	</tr>
</table>
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