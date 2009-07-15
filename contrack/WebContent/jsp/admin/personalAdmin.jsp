<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.UserData, com.sinkluge.User" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
User u = User.getUser(attr.getUserId());
UserData user = UserData.getInstance(in, u);
if (request.getParameter("clearPhoto") != null) {
	user.setPhoto(in, null);
}
%>
<html>
<head>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript" src="../utils/verify.js"></script>
</head>
<body>
<form id="main" action="processPersonalInfo.jsp" method="POST" onSubmit="return checkForm(this)">
	<font size="+1">My Settings</font><hr>
	<a href="modifyJobList.jsp">Project List</a> &nbsp; 
	<a href="changePassword.jsp">Change Password</a>
	<hr>
<% if (request.getParameter("saved") != null) out.print("<div class=\"red bold\">Saved</div><hr>"); %>
		<table>
			<tr>
				<td>&nbsp;</td>
				<td class="bold"><%= attr.getFullName() %></td>
			</tr>
			<tr>
				<td class="lbl">Title:</td>
				<td><input type="text" name="title" value="<%= user.getSafe("title") %>"></td>
			<tr>
				<td class="lbl">Email:</td>
				<td><input type="text" name="email" value="<%= user.getSafe("email") %>"></td>
				<td class="lbl">Phone:</td>
<%
String temp = user.get("phone");
if (temp == null || temp.equals("")) temp = attr.get("phone");
%>
				<td><input type="text" maxlength="14" name="phone" value="<%= temp %>"> 
				<b>Ext:</b> <input type="text" name="ext" size=4 value="<%= user.getSafe("ext") %>"></td>
			</tr>
			<tr>
<%
temp = user.get("address");
if (temp == null || temp.equals("")) temp = attr.get("address");
%>
				<td class="lbl">Address:</td>
				<td><input type="text" name="address" width="15" value="<%= temp %>"></td>
<%
temp = user.get("fax");
if (temp == null || temp.equals("")) temp = attr.get("fax");
%>
						<td class="lbl">Fax:</td>
						<td><input type="text" maxlength="14" name="fax" value="<%= temp %>"></td>
			</tr>
<%
temp = user.get("city");
if (temp == null || temp.equals("")) temp = attr.get("city");
%>
			<tr>
				<td class="lbl">City:</td>
				<td><input type="text" name="city" value="<%= temp %>"></td>
						<td class="lbl">Mobile:</td>
						<td><input type="text" maxlength="14" name="mobile" value="<%= user.getSafe("mobile") %>"></td>
			</tr>
<%
String state = user.getSafe("state");
%>
			<tr>
				<td class="lbl">State:</td>
				<td><select name="state">
						<option  value="AK" <% if (state.equals("AK")) out.println("selected"); %>>Alaska</option>
						<option  value="AL" <% if (state.equals("AL")) out.println("selected"); %>>Alabama</option>
						<option  value="AR" <% if (state.equals("AR")) out.println("selected"); %>>Arkansas</option>
						<option  value="AZ" <% if (state.equals("AZ")) out.println("selected"); %>>Arizona</option>
						<option  value="CA" <% if (state.equals("CA")) out.println("selected"); %>>California</option>
						<option  value="CO" <% if (state.equals("CO")) out.println("selected"); %>>Colorado </option>
						<option  value="CT" <% if (state.equals("CT")) out.println("selected"); %>>Connecticut </option>
						<option  value="DE" <% if (state.equals("DE")) out.println("selected"); %>>Delaware </option>
						<option  value="FL" <% if (state.equals("FL")) out.println("selected"); %>>Florida</option>
						<option  value="GA" <% if (state.equals("GA")) out.println("selected"); %>>Georgia </option>
						<option  value="HI" <% if (state.equals("HI")) out.println("selected"); %>>Hawaii</option>
						<option  value="IA" <% if (state.equals("IA")) out.println("selected"); %>>Iowa </option>
						<option  value="ID" <% if (state.equals("ID")) out.println("selected"); %>>Idaho</option>
						<option  value="IL" <% if (state.equals("IL")) out.println("selected"); %>>Illinois</option>
						<option  value="IN" <% if (state.equals("IN")) out.println("selected"); %>>Indiana</option>
						<option  value="KS" <% if (state.equals("KS")) out.println("selected"); %>>Kansas </option>
						<option  value="KY" <% if (state.equals("KY")) out.println("selected"); %>>Kentucky</option>
						<option  value="LA" <% if (state.equals("LA")) out.println("selected"); %>>Louisiana</option>
						<option  value="MA" <% if (state.equals("MA")) out.println("selected"); %>>Massachusetts</option>
						<option  value="MD" <% if (state.equals("MD")) out.println("selected"); %>>Maryland</option>
						<option  value="ME" <% if (state.equals("ME")) out.println("selected"); %>>Maine</option>
						<option  value="MI" <% if (state.equals("MI")) out.println("selected"); %>>Michigan</option>
						<option  value="MN" <% if (state.equals("MN")) out.println("selected"); %>>Minnesota</option>
						<option  value="MO" <% if (state.equals("MO")) out.println("selected"); %>>Missouri </option>
						<option  value="MS" <% if (state.equals("MS")) out.println("selected"); %>>Mississippi </option>
						<option  value="MT" <% if (state.equals("MT")) out.println("selected"); %>>Montana</option>
						<option  value="NC" <% if (state.equals("NC")) out.println("selected"); %>>North Carolina</option>
						<option  value="ND" <% if (state.equals("ND")) out.println("selected"); %>>North Dakota</option>
						<option  value="NE" <% if (state.equals("NE")) out.println("selected"); %>>Nebraska </option>
						<option  value="NH" <% if (state.equals("NH")) out.println("selected"); %>>New Hampshire</option>
						<option  value="NJ" <% if (state.equals("NJ")) out.println("selected"); %>>New Jersey</option>
						<option  value="NM" <% if (state.equals("NM")) out.println("selected"); %>>New Mexico</option>
						<option  value="NV" <% if (state.equals("NV")) out.println("selected"); %>>Nevada</option>
						<option  value="NY" <% if (state.equals("NY")) out.println("selected"); %>>New York </option>
						<option  value="OH" <% if (state.equals("OH")) out.println("selected"); %>>Ohio</option>
						<option  value="OK" <% if (state.equals("OK")) out.println("selected"); %>>Oklahoma</option>
						<option  value="OR" <% if (state.equals("OR")) out.println("selected"); %>>Oregon</option>
						<option  value="PA" <% if (state.equals("PA")) out.println("selected"); %>>Pennsylvania</option>
						<option  value="RI" <% if (state.equals("RI")) out.println("selected"); %>>Rhode Island </option>
						<option  value="SC" <% if (state.equals("SC")) out.println("selected"); %>>South Carolina</option>
						<option  value="SD" <% if (state.equals("SD")) out.println("selected"); %>>South Dakota </option>
						<option  value="TN" <% if (state.equals("TN")) out.println("selected"); %>>Tennessee</option>
						<option  value="TX" <% if (state.equals("TX")) out.println("selected"); %>>Texas</option>
						<option  value="UT" <% if ((state.equals("UT")) || (state.equals(""))) out.println("selected"); %>>Utah</option>
						<option  value="VA" <% if (state.equals("VA")) out.println("selected"); %>>Virginia </option>
						<option  value="VT" <% if (state.equals("VT")) out.println("selected"); %>>Vermont</option>
						<option  value="WA" <% if (state.equals("WA")) out.println("selected"); %>>Washington </option>
						<option  value="WI" <% if (state.equals("WI")) out.println("selected"); %>>Wisconsin</option>
						<option  value="WV" <% if (state.equals("WV")) out.println("selected"); %>>West Virginia</option>
						<option  value="WY" <% if (state.equals("WY")) out.println("selected"); %>>Wyoming </option>
					</select></td>
						<td class="lbl">Radio:</td>
						<td><input type="text" name="radio" size=5 value="<%= user.getSafe("radio") %>"></td>
				</tr>
				<tr>
<%
temp = user.get("zip");
if (temp == null || temp.equals("")) temp = attr.get("zip");
%>
					<td class="lbl">Zip Code:</td>
					<td><input type="text" name="zip" size=10 maxlength="10" value="<%= temp %>"></td>
					<td class="lbl">Font Size:</td>
					<td><select name="font_size">
<%
int font = u.getFontSize();
for (int i = 7; i < 13; i++) {
	out.print("<option ");
	if (i == font) out.print("selected");
	out.print(">" + i + "</option>");
}
%>						</select> pt</td>
				</tr>
			<tr>
				<td>&nbsp;</td>
				<td colspan="3"><input type="submit" value="Save"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td colspan="3"><hr></td>
			</tr>
</form>
<form id="main2" action="../servlets/userphoto" enctype="multipart/form-data" method="POST" 
	onsubmit="return checkForm(this);">
			<tr>
				<td class="lbl">Photo</td>
				<td><input type="file" name="photo"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td colspan="3"><input type="submit" value="Upload"> &nbsp; 
					<input type="button" value="Clear" 
					onclick="window.location='personalAdmin.jsp?clearPhoto=true';"></td>
			</tr>
<%
if (user.get("photo") != null) {
%>
			<tr>
			<td>&nbsp;</td>
			<td colspan="3"><img src="../servlets/userphoto"></td>
			</tr>
<%
}
%>
			</table>
			</form>
<script>
	var d = document.getElementById("main");
	var f = d.title;
	f.select();
	f.focus();
	
	f = d.phone;
	f.isPhone = true;
	f.eName = "Phone";
	
	f = d.fax;
	f.isPhone = true;
	f.eName = "Fax";
	
	f = d.mobile;
	f.isPhone = true;
	f.eName = "Mobile";
	
	f = d.zip;
	f.isZip = true;
	f.eName = "Zip Code";
	
	f = d.email;
	f.isEmail = true;
	f.required = true;
	f.eName = "Email";
	
	d = document.getElementById("main2");
	f = d.photo;
	f.required = true;
	f.eName = "Photo";
	
</script>

<%
user.close();
%>
</body>
</html>

