<%@page session="true" %>
<%@page contentType="text/plain"%>
<%@page import="com.sinkluge.utilities.SimpleMailer"%>
<%@page import="java.sql.ResultSet, org.apache.commons.lang.RandomStringUtils, com.sinkluge.utilities.Digest"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
String contact_id = request.getParameter("id");
String pass = RandomStringUtils.randomAscii(8);
Database db = new Database();
db.dbInsert("update contact_users, contacts set password = '" + Digest.digest(pass) + "', has_temp_password = 1 "
	+ "where contacts.email = contact_users.email and contact_id = " + contact_id);
String contact_email = "";
ResultSet rs = db.dbQuery("select email from contacts where contact_id = " + contact_id);
if (rs.next()) contact_email = rs.getString(1);
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
String body = "At your request your Contrack - Project Management password has been reset. "
	+ "The program will prompt you to change your password when you log on with the provided temporary password."
	+ "\n\nTemporary Password: " + pass
	+ "\n\nIf you need further assistance, please reply to this email.";
SimpleMailer.sendMessage(attr.getEmail(), attr.getFullName(), contact_email, null, "Contrack - Project Management Account Reset", body, "text/plain", in);
long logId = com.sinkluge.utilities.ItemLogger.Emailed.update(com.sinkluge.Type.CONTACT,
	contact_id, session);
com.sinkluge.utilities.ItemLogger.setComment(logId, "Password reset");
response.sendRedirect("modifyContact.jsp?reset=t&contact_id=" + contact_id);
%>



