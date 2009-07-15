<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.Verify, java.sql.SQLException"%>
<%@page import="java.sql.Statement, java.sql.ResultSet, java.sql.PreparedStatement"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
Verify v = new Verify();

String t = request.getParameter("email");

db.connect(); 
String query = "select * from contacts where contact_id = " + db.contact_id;
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
String full_name = "";
String email = "";
String phone = "";
String ext = "";
String fax = "";
String mobile = "";
String radio = "";
String zip = "";
String pager = "";
if (rs.next()) {
	full_name = rs.getString("name");
	email = rs.getString("email");
	phone = rs.getString("phone");
	ext = rs.getString("extension");
	fax = rs.getString("fax");
	mobile = rs.getString("mobile_phone");
	radio = rs.getString("radio_num");
	zip = rs.getString("zip");
	pager = rs.getString("pager");
}
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;

query = "update contacts set name=?, email=?, phone=?, extension=?, fax=?, mobile_phone=?, pager=?, radio_num=?, address=?, city=?, state=?, "
	+ "zip=? where contact_id = " + db.contact_id;
PreparedStatement ps = db.preStmt(query);

String new_email = null;

if (v.blank(t)) {
	v.msg("Email address is required");
	ps.setString(2, email);
} else if (v.email(t)) {
	ps.setString(2, t);
	new_email = t;
} else {
	ps.setString(2, email);
	v.msg("Email/Username is not a valid email address");
}

t = request.getParameter("full_name");
if (v.blank(t)) {
	v.msg("Full Name is required");
	ps.setString(1, full_name);
} else ps.setString(1, t);

t = request.getParameter("phone");
if (v.phone(t)) ps.setString(3, t);
else {
	v.msg("Office Phone is not a valid phone number: (000) 000-0000");
	ps.setString(3, phone);
}

t = request.getParameter("ext");
if (v.integer(t)) ps.setString(4, t);
else {
	v.msg("Office Phone Ext is not a valid integer number");
	ps.setString(4, ext);
}

t = request.getParameter("fax");
if (v.blank(t)) {
	v.msg("Fax is required");
	ps.setString(5, fax);
} else if (v.phone(t)) ps.setString(5, t);
else {
	ps.setString(5, fax);
	v.msg("Fax is not a valid phone number: (000) 000-0000");
}

t = request.getParameter("mobile");
if (v.phone(t)) ps.setString(6, t);
else {
	ps.setString(6, mobile);
	v.msg("Mobile Phone is not a valid phone number: (000) 000-0000");
}

t = request.getParameter("pager");
if (v.phone(t)) ps.setString(7, t);
else {
	ps.setString(7, pager);
	v.msg("Pager is not a valid phone number: (000) 000-0000");
}

t = request.getParameter("radio");
if (v.integer(t)) ps.setString(8, t);
else {
	ps.setString(8, radio);
	v.msg("Nextel Radio is not a valid integer number");
}

t = request.getParameter("address");
ps.setString(9, t);

t = request.getParameter("city");
ps.setString(10, t);

t = request.getParameter("state");
ps.setString(11, t);

t = request.getParameter("zip");
if (v.integer(t)) ps.setString(12, t);
else {
	ps.setString(12, zip);
	v.msg("Zip code is not valid: 00000-####");
}

boolean saved = false;
try {
	saved =	ps.executeUpdate() != 0;
	db.msg = "Saved.";
} catch (SQLException e) { 
	db.msg = "NOT SAVED. Contact name must be unique for a given company";
}

if (ps != null) ps.close();
ps = null;

if (!v.message.equals("")) db.msg += " " + v.message;
else if (saved && new_email != null) {
	query = "update ignore contact_roles set email=? where email=?";
	ps = db.preStmt(query);
	ps.setString(1, new_email);
	ps.setString(2, email);
	ps.executeUpdate();
	if (ps != null) ps.close();
	ps = null;	
	query = "update ignore contact_users set email=?, font_size=? where email=?";
	ps = db.preStmt(query);
	ps.setString(1, new_email);
	t = request.getParameter("font_size");
	db.font_size = Integer.parseInt(t);
	ps.setInt(2, db.font_size);
	ps.setString(3, email);
	ps.executeUpdate();
	if (ps != null) ps.close();
	ps = null;
	db.email = new_email;
}
db.disconnect();

response.sendRedirect("myInfo.jsp");

%>