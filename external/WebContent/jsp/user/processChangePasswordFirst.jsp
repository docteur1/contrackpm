<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="com.sinkluge.util.Verify"%>
<%@page import="com.sinkluge.util.Digest"%>
<%@page import="java.sql.Statement"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
Verify v = new Verify();

String contact_pass = null;
String tt = request.getParameter("new_password");
// Check the password against the old one to prevent malicious use (unattended terminal)
if (!v.blank(tt)) {
	if (v.password(tt, request.getParameter("verify_password"))) contact_pass = Digest.digest(tt);//We need the digest stuff here.
	// No need to send error messages this is done in v.password()
} else if (!v.blank(tt)) v.msg("Invalid current password- Passwords not changed");

db.connect();
Statement stmt = db.getStatement();

int update = 0;
if (v.message.equals("") && contact_pass != null) {
	String query = "update contact_users set password = '" + contact_pass + "', has_temp_password = 0 where email = '" + db.email + "'";
	update = stmt.executeUpdate(query);
	if (update != 0) db.msg = "Password Changed";
	else db.msg = "Error changing passwords";
} else db.msg = v.message;
if (stmt != null) stmt.close();
stmt = null;

db.disconnect();

response.sendRedirect("../manage/index.jsp");

%>