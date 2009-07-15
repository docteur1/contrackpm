<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.Verify, java.sql.SQLException"%>
<%@page import="java.sql.ResultSet, java.sql.PreparedStatement"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
Verify v = new Verify();

String email = request.getParameter("email");
db.connect();
String contact_id = request.getParameter("contact_id");
String query = "select email from contacts where contact_id = " + contact_id;
String oldEmail = null;
PreparedStatement ps = db.preStmt(query);
ResultSet rs = ps.executeQuery(query);
if (rs.first()) oldEmail = rs.getString(1);
if (rs != null) rs.close();
if (ps != null) ps.close();

boolean isNew = request.getParameter("isNew") != null;

if (isNew) query = "insert into contacts (name, email, phone, extension, fax, mobile_phone, pager, radio_num, address, city, state, "
	+ "zip, company_id) values (?,?,?,?,?,?,?,?,?,?,?,?," + db.company_id + ")";
else query = "update contacts set name=?, email=?, phone=?, extension=?, fax=?, mobile_phone=?, pager=?, radio_num=?, address=?, city=?, state=?, "
	+ "zip=? where contact_id = " + request.getParameter("contact_id");
ps = db.preStmt(query);
boolean validEmail = false;
if (v.blank(email)) {
	v.msg("Email address is required");
	ps.setString(2, "");
} else if (v.email(email)) {
	ps.setString(2, email);
	validEmail = true;
}
else {
	ps.setString(2, "");
	v.msg("Email/Username is not a valid email address");
}

String t = request.getParameter("full_name");
if (v.blank(t)) {
	v.msg("Full Name is required");
	ps.setString(1, "");
} else ps.setString(1, t);

t = request.getParameter("phone");
if (v.phone(t)) ps.setString(3, t);
else {
	v.msg("Office Phone is not a valid phone number: (000) 000-0000");
	ps.setString(3, "");
}

t = request.getParameter("ext");
if (v.integer(t)) ps.setString(4, t);
else {
	v.msg("Office Phone Ext is not a valid integer number");
	ps.setString(4, "");
}

t = request.getParameter("fax");
if (v.blank(t)) {
	v.msg("Fax is required");
	ps.setString(5, "");
} else if (v.phone(t)) ps.setString(5, t);
else {
	ps.setString(5, "");
	v.msg("Fax is not a valid phone number: (000) 000-0000");
}

t = request.getParameter("mobile");
if (v.phone(t)) ps.setString(6, t);
else {
	ps.setString(6, "");
	v.msg("Mobile Phone is not a valid phone number: (000) 000-0000");
}

t = request.getParameter("pager");
if (v.phone(t)) ps.setString(7, t);
else {
	ps.setString(7, "");
	v.msg("Pager is not a valid phone number: (000) 000-0000");
}

t = request.getParameter("radio");
if (v.integer(t)) ps.setString(8, t);
else {
	ps.setString(8, "");
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
	ps.setString(12, "");
	v.msg("Zip code is not valid: 00000-####");
}
try {
	ps.executeUpdate();
	db.msg = "Saved.";
} catch (SQLException e) { 
	db.msg = "NOT SAVED. Contact name must be unique for a given company";
}

if (!v.message.equals("")) db.msg += " " + v.message;

if (isNew) {
	rs = ps.getGeneratedKeys();
	if (rs.next()) contact_id = rs.getString(1);
	if (rs != null) rs.close();
	rs = null;
	if (ps != null) ps.close();
	ps = null;
} else if (validEmail) {
	if (ps != null) ps.close();
	ps = null;
	query = "update ignore contact_roles set email=? where email=?";
	ps = db.preStmt(query);
	ps.setString(1, email);
	ps.setString(2, oldEmail);
	ps.executeUpdate();
	if (ps != null) ps.close();
	ps = null;
	query = "update ignore contact_users set email=? where email=?";
	ps = db.preStmt(query);
	ps.setString(1, email);
	ps.setString(2, oldEmail);
	ps.executeUpdate();
	if (ps != null) ps.close();
	ps = null;
}
	

db.disconnect();

response.sendRedirect("contact.jsp?id=" + contact_id);
%>