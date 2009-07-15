<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.Verify"%>
<%@page import="com.sinkluge.util.Digest"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
Verify v = new Verify();

String t = request.getParameter("old_password");

String query = "select password from contact_users where email = '" + db.email + "'";
db.connect();
Statement stmt = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
String contact_pass = "";
if (rs.next()) {
	contact_pass = rs.getString("password");
}
if (rs != null) rs.close();
rs = null;

String tt = request.getParameter("new_password");
// Check the password against the old one to prevent malicious use (unattended terminal)
if (Digest.digest(t).equals(contact_pass) && !v.blank(tt)) {
	if (v.password(tt, request.getParameter("verify_password"))) contact_pass = Digest.digest(tt);//We need the digest stuff here.
	// No need to send error messages this is done in v.password()
} else if (!v.blank(tt)) v.msg("Invalid current password- Passwords not changed");

int update = 0;
if (v.message.equals("")) {
	query = "update contact_users set password = '" + contact_pass + "' where email = '" + db.email + "'";
	update = stmt.executeUpdate(query);
	if (update != 0) db.msg = "Password Changed";
	else db.msg = "Error changing passwords";
} else db.msg = v.message;
if (stmt != null) stmt.close();
stmt = null;

db.disconnect();

response.sendRedirect("index.jsp");

%>