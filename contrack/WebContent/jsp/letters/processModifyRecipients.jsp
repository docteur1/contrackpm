<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.util.StringTokenizer" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.LETTERS, Security.WRITE)) response.sendRedirect("../accessDenied.html");

/* First save the data */
String id = request.getParameter("letter_id");
String sql = "delete from letter_contacts where letter_id = " + id;
Database db = new Database();
db.dbInsert(sql);
String ids = request.getParameter("ids");
String email = "";
String fax = "";
String print = "";
StringTokenizer st = new StringTokenizer(ids, ",");
String type, temp;
while (st.hasMoreTokens()) {
	temp = st.nextToken();
	type = temp.substring(0,1);
	if (type.equals("E")) {
		if (!email.equals("")) email += ",";
		email += temp.substring(1);
	} else if (type.equals("F")) {
		if (!fax.equals("")) fax += ",";
		fax += temp.substring(1);
	} else {
		if (!print.equals("")) print += ",";
		print += temp.substring(1);
	}
}
StringTokenizer list = new StringTokenizer(email,",");
boolean emailError = false;
String val = "", obj = "", companyId;
ResultSet rs;
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
		rs.close();
	} else {
		companyId = val;
		val = "0";
		obj = null;
	}
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
list = new StringTokenizer(fax,",");
boolean faxError = false;
while (list.hasMoreTokens()) {
	val = list.nextToken();
	System.out.println("here " + val);
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
list = new StringTokenizer(print,",");
while (list.hasMoreTokens()) {
	val = list.nextToken();
	isCompany = val.indexOf("C") != -1;
	val = val.substring(1);
	if (!isCompany) {
		sql = "select company_id from contacts where contact_id = " + val;
		rs = db.dbQuery(sql);
		rs.next();
		companyId = rs.getString(1);
		rs.close();
	} else {
		companyId = val;
		val = "0";
	}
	sql = "insert ignore into letter_contacts (letter_id, contact_id, company_id, method) values (" + id 
	+ "," + val + "," + companyId + ",'Print')";
	db.dbInsert(sql);
}
com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.LETTER,
	id, "Updated recipients", session);
db.disconnect();
%>
<script>
<%
if (emailError) out.print("\talert(\"One or more email address are invalid!\\n\\nThese were added to print list.\");");
if (faxError) out.print("\talert(\"One or more fax numbers are invalid!\\n\\nThese were added to print list.\");");
%>
	parent.opener.location.reload();
	parent.location = "modifyLetterFrameset.jsp?letter_id=<%= id %>";
</script>
