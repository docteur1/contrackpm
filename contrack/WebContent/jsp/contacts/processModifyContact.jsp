<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.PreparedStatement, com.sinkluge.utilities.SimpleMailer, com.sinkluge.utilities.Verify"%>
<%@page import="java.sql.ResultSet, java.sql.SQLException, org.apache.commons.lang.RandomStringUtils, com.sinkluge.utilities.Digest"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<script language="javascript">
<%
String email = request.getParameter("email");
boolean hasValidEmail = false;
hasValidEmail = Verify.email(email);
int contact_id = Integer.parseInt(request.getParameter("contact_id"));
ResultSet rs = null;
String oldEmail = null;
Database db = new Database();
rs = db.dbQuery("select email from contacts where contact_id = " + contact_id);
if (rs.first()) oldEmail = rs.getString(1);
rs.getStatement().close();
rs = null;
String insert = "update contacts set title = ?, address = ?, city = ?, state = ?, zip = ?, radio_num = ?, " +
	"phone = ?, extension = ?, fax = ?, mobile_phone = ?, email = ?, pager = ?, name=?, comment=? where contact_id = " + 
	contact_id;
db.connect();
PreparedStatement ps = db.preStmt(insert);
ps.setString(1, request.getParameter("title"));
ps.setString(2, request.getParameter("address"));
ps.setString(3, request.getParameter("city"));
ps.setString(4, request.getParameter("state"));
ps.setString(5, request.getParameter("zip"));
ps.setString(6, request.getParameter("radio_num"));
ps.setString(7, request.getParameter("phone"));
ps.setString(8, request.getParameter("extension"));
ps.setString(9, request.getParameter("fax"));
ps.setString(10, request.getParameter("mobile_phone"));
ps.setString(11, email);
ps.setString(12, request.getParameter("pager"));
ps.setString(13, request.getParameter("contact_name"));
ps.setString(14, request.getParameter("comment"));
try {
	ps.executeUpdate();
	long logId = com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.CONTACT,
		request.getParameter("contact_id"), session);
	if (request.getParameter("allow_ext") != null && hasValidEmail) {
		// Need to fix this!!!!! then log the email...
		if (oldEmail != null && !email.equals(oldEmail)) {
			db.dbInsert("update contact_users set email='" + email + "' where email='" + oldEmail + "'");
			db.dbInsert("update contact_roles set email='" + email + "' where email='" + oldEmail + "'");
		}
		// Generate, set, and email a password
		if (request.getParameter("has_pass") == null) {
			db.dbInsert("insert ignore into contact_roles (email, role_name) values ('" + email + "','valid')");
			db.dbInsert("insert ignore into contact_users (email, password) values ('" + email + "','password')");
			String pass = RandomStringUtils.randomAlphanumeric(8);
			db.dbInsert("update contact_users set password = '" + Digest.digest(pass) + "', has_temp_password = 1 where email = '" + email + "'");
			String body = "Congratulations!\n\nYour " + attr.get("short_name") + " - Contrack account has successfully been activated! "
				+ "A seperate email has been sent informing you of your initial password. The email address to which this email was sent will serve "
				+ "as your username. Click (or copy and paste) the address below to browse to the Contrack site.\n\n"
				+ in.external_url + "\n\nIf you experience difficultly, please request help by replying to this email.";
			SimpleMailer.sendMessage(attr.getEmail(), attr.getFullName(), email, null, "Contrack - " + attr.get("short_name") + " Account", body, "text/plain", in);
			body = "Congratulations!\n\nYour " + attr.get("short_name") + " - Contrack account has successfully been activated! "
				+ "Below you will find a temporary password.\n\nPassword: " + pass
				+ "\n\nNOTE: Passwords are case sensitive.\n\nAfter logging on you will be prompted to set a permanent password.";
			SimpleMailer.sendMessage(attr.getEmail(), attr.getFullName(), email, null, "Contrack - " + attr.get("short_name") + " Information", body, "text/plain", in);
			// Reenable account
			com.sinkluge.utilities.ItemLogger.setComment(logId, "Ext. account created");
		} else {
			db.dbInsert("insert ignore into contact_roles (email, role_name) values ('" + email + "','valid')");
			com.sinkluge.utilities.ItemLogger.setComment(logId, "Reenabled ext. account.");
		}
	} else {
		db.dbInsert("delete from contact_roles where email = '" + email + "'");
		com.sinkluge.utilities.ItemLogger.setComment(logId, "Disabled ext. account.");
	}
%>
		opener.location.reload();
		window.focus();
		window.location = "modifyContact.jsp?save=1&contact_id=<%=contact_id%>";
<%
} catch (SQLException e) {
	System.err.println(e.getMessage());
%>
	window.alert("A contact named \"<%= request.getParameter("contact_name") %>\" already exists for this company!");
	window.location = "modifyContact.jsp?contact_id=<%= contact_id %>";
<%
} finally {
	ps.close();
	db.disconnect();
}
%>
</script>