<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.PreparedStatement,java.sql.ResultSet" %>
<%@page import="java.util.StringTokenizer, com.sinkluge.UserData" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Name.LETTERS, Permission.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String sql = "insert into letters (job_id, date_created, cc, salutation, subject, body_text, user_id) values ("
	+ attr.getJobId() + ",curdate(),?,?,?,?,?)";
Database db = new Database();
PreparedStatement ps = db.preStmt(sql);
ps.setString(1, request.getParameter("cc"));
ps.setString(2, request.getParameter("salutation"));
ps.setString(3, request.getParameter("subject"));
ps.setString(4, request.getParameter("body_text"));
ps.setString(5, request.getParameter("user_id"));
ps.executeUpdate();
ResultSet rs = ps.getGeneratedKeys();
rs.next();
int id = rs.getInt(1);
com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.LETTER,
		rs.getString(1), session);
rs.close();
StringTokenizer list = new StringTokenizer(request.getParameter("email"),",");
boolean emailError = false;
String val = "", obj = "", companyId;
boolean isCompany;
while (list.hasMoreTokens()) {
	val = list.nextToken();
	isCompany = val.indexOf("C") != -1;
	val = val.substring(1);
	if (!isCompany) {
		sql = "select company_id, email from contacts where contact_id = " + val;
		rs = db.dbQuery(sql);
		rs.next();
		obj = rs.getString(2);
		companyId = rs.getString(1);
	} else {
		companyId = val;
		val = "0";
		obj = null;
	}
	rs.close();
	if (obj != null && !obj.equals("")) {
		sql = "insert ignore into letter_contacts (letter_id, contact_id, company_id, method) values (" + id 
			+ "," + val + "," + companyId + ",'Email')";
		db.dbInsert(sql);
	} else {
		emailError = true;
		sql = "insert ignore into letter_contacts (letter_id, contact_id, company_id, method) values (" + id 
			+ "," + val + "," + companyId + ",'Print')";
		db.dbInsert(sql);
	}
}
list = new StringTokenizer(request.getParameter("fax"),",");
boolean faxError = false;
while (list.hasMoreTokens()) {
	val = list.nextToken();
	isCompany = val.indexOf("C") != -1;
	val = val.substring(1);
	if (!isCompany) {
		sql = "select company_id, fax from contacts where contact_id = " + val;
		rs = db.dbQuery(sql);
		rs.next();
		obj = rs.getString(2);
		companyId = rs.getString(1);
	} else {
		sql = "select fax from company where company_id = " + val;
		rs = db.dbQuery(sql);
		rs.next();
		obj = rs.getString(1);
		companyId = val;
		val = "0";
	}
	rs.close();
	if (obj == null) obj = "";
	//Remove all non-numeric digits
	obj = obj.replaceAll("\\D","");
	//Does it have 7 or 10 digits?
	if ((obj.length() == 7) || (obj.length() == 10)) {
		sql = "insert ignore into letter_contacts (letter_id, contact_id, company_id, method) values (" + id 
		+ "," + val + "," + companyId + ",'Fax')";
	db.dbInsert(sql);
	} else {
		faxError = true;
		sql = "insert ignore into letter_contacts (letter_id, contact_id, company_id, method) values (" + id 
			+ "," + val + "," + companyId + ",'Print')";
		db.dbInsert(sql);
	}
}
list = new StringTokenizer(request.getParameter("print"),",");
while (list.hasMoreTokens()) {
	val = list.nextToken();
	isCompany = val.indexOf("C") != -1;
	val = val.substring(1);
	if (!isCompany) {
		sql = "select company_id from contacts where contact_id = " + val;
		rs = db.dbQuery(sql);
		rs.next();
		companyId = rs.getString(1);
	} else {
		companyId = val;
		val = "0";
	}
	rs.close();
	sql = "insert ignore into letter_contacts (letter_id, contact_id, company_id, method) values (" + id 
	+ "," + val + "," + companyId + ",'Print')";
	db.dbInsert(sql);
}
db.disconnect();
%>
<script>
<%
if (emailError) out.print("\talert(\"One or more email address are invalid!\\n\\nThese were added to print list.\");");
if (faxError) out.print("\talert(\"One or more fax numbers are invalid!\\n\\nThese were added to print list.\");");
%>
	parent.opener.location.reload();
	window.parent.location = "modifyLetterFrameset.jsp?letter_id=<%= id %>";
</script>


