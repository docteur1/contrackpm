<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.ResultSet, com.sinkluge.attributes.LienWaiver, com.sinkluge.utilities.DateUtils" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script>
<%
if (!sec.ok(sec.SUBCONTRACT, sec.PRINT)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String query = "select company_name, company.address, company.city, company.state, company.zip, company.phone, "
	+ "company.fax, contacts.name, contacts.address, contacts.city, contacts.state, contacts.zip, contacts.phone, "
	+ "contacts.fax, j.city as job_city, j.state as job_state from company left join contacts "
	+ "using(company_id) join job as j where company.company_id = " + request.getParameter("company_id")
	+ " and job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
LienWaiver lw = null;
if (rs.next()) {
	lw = new LienWaiver();
	String t = rs.getString("name");
	if (request.getParameter("contract_id") != null) {
		lw.setDocType(com.sinkluge.Type.SUBCONTRACT);
		lw.setId(request.getParameter("contract_id"));
	} else {
		lw.setDocType(com.sinkluge.Type.COMPANY);
		lw.setId(request.getParameter("company_id"));
	}
	lw.setCompanyName(rs.getString("company_name"));
	lw.setJobCity(rs.getString("job_city"));
	lw.setJobState(rs.getString("job_state"));
	lw.setAmount(Double.parseDouble(request.getParameter("amount")));
	lw.setDate(DateUtils.getSQLShort(request.getParameter("date")));
	lw.setType(request.getParameter("type"));
	if (t != null) {
		lw.setAddress(rs.getString("contacts.address"));
		lw.setCity(rs.getString("contacts.city"));
		lw.setState(rs.getString("contacts.state"));
		lw.setZip(rs.getString("contacts.zip"));
		lw.setPhone(rs.getString("contacts.phone"));
		lw.setFax(rs.getString("contacts.fax"));
	} else {
		lw.setAddress(rs.getString("company.address"));
		lw.setCity(rs.getString("company.city"));
		lw.setState(rs.getString("company.state"));
		lw.setZip(rs.getString("company.zip"));
		lw.setPhone(rs.getString("company.phone"));
		lw.setFax(rs.getString("company.fax"));
	}
}
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
if (lw != null) {
	attr.setLienWaiver(lw);
%>
	msgWin = window.open("", "print");
	var url = "../utils/print.jsp?doc=subLienWaiver.pdf";
	msgWin.location = url;
	msgWin.focus();
	window.close();
<%
} else {
%>
	window.alert("There was an error");
	history.back();
<%
}
%>
</script>