<%@ page language="java" contentType="text/plain; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.DateUtils" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
String aname;
String avalue;
String oname;
String ovalue;
if (request.getParameter("ocontact_id") != null) {
	oname = "ocontact_id";
	ovalue = request.getParameter("ocontact_id");
} else {
	oname = "ocompany_id";
	ovalue = request.getParameter("ocompany_id");
}
if (request.getParameter("acontact_id") != null) {
	aname = "acontact_id";
	avalue = request.getParameter("acontact_id");
} else {
	aname = "acompany_id";
	avalue = request.getParameter("acompany_id");
}
String query = "select * from job where job_id = 0";
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
rs.moveToInsertRow();
rs.updateString("job_num", request.getParameter("job_num"));
rs.updateString("job_name", request.getParameter("job_name"));
rs.updateString("address", request.getParameter("address"));
rs.updateString("city", request.getParameter("city"));
rs.updateString("zip", request.getParameter("zip"));
rs.updateString("phone_one", request.getParameter("phone_one"));
rs.updateString("phone_two", request.getParameter("phone_two"));
rs.updateString("fax", request.getParameter("fax"));
rs.updateString("submittal_copies", request.getParameter("submittals"));
rs.updateDate("start_date", DateUtils.getSQLShort(request.getParameter("start_date")));
rs.updateDate("end_date", DateUtils.getSQLShort(request.getParameter("end_date")));
rs.updateString("contract_amount_start", request.getParameter("startContract"));
rs.updateDate("builders_risk_ins_expire", DateUtils.getSQLShort(request.getParameter("exp_date")));
String t = request.getParameter("xSupport");
t = t == null?"n":"y";
rs.updateString("extended_support", t);
rs.updateString("project_category", request.getParameter("category"));
rs.updateString("contract_method", request.getParameter("contractMethod"));
rs.updateString("site_size", request.getParameter("siteSize"));
rs.updateString("building_size", request.getParameter("buildingSize"));
rs.updateDate("substantial_completion_date", DateUtils.getSQLShort(request.getParameter("sub_date")));
rs.updateString("description", request.getParameter("description"));
rs.updateString("active", "y");
rs.updateString("site_id", request.getParameter("site_id"));
ResultSet settings = db.dbQuery("select * from settings where id = 'job'");
String name;
while (settings.next()) {
	name = settings.getString("name");
	rs.updateString(name, settings.getString("val"));
}
if (settings != null) settings.getStatement().close();
settings = null;
rs.insertRow();
String id = null;
if (rs.last()) id = rs.getString("job_id");
if (rs != null) rs.getStatement().close();
rs = null;
if (id != null) {
	com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.PROJECT, id, session);
	query = "insert into job_divisions (job_id, division, description) select " + id +
		", division, description from divisions where site_id = " + request.getParameter("site_id");
	db.dbInsert(query);
	query = "select * from job_contacts where job_contact_id = 0";
	rs = db.dbQuery(query, true);
	rs.moveToInsertRow();
	rs.updateString("job_id", id);
	rs.updateString(oname.substring(1), ovalue);
	rs.updateBoolean("isDefault", true);
	rs.updateString("type", "Owner");
	rs.insertRow();
	rs.moveToInsertRow();
	rs.updateString("job_id", id);
	rs.updateString(aname.substring(1), avalue);
	rs.updateBoolean("isDefault", true);
	rs.updateString("type", "Architect");
	rs.insertRow();
	if (rs != null) rs.getStatement().close();
	rs = null;
	query = "insert ignore into user_jobs (job_id, user_id) values (" + id + ", " + attr.getUserId() + ")";
	db.dbInsert(query);
	query = "update job_contacts, contacts set job_contacts.company_id = contacts.company_id where "
		+ "job_contacts.company_id is null and job_contacts.contact_id = contacts.contact_id";
	db.dbInsert(query);
	// guarantee that no rows are returned
	query = "select * from job_permissions where job_id = " + id;
	rs = db.dbQuery(query, true);
	rs.moveToInsertRow();
	rs.updateString("job_id", id);
	rs.updateInt("user_id", attr.getUserId());
	rs.updateString("name", Name.PROJECT.toString());
	rs.updateString("val", "READ,WRITE,DELETE,PRINT");
	rs.insertRow();
	rs.moveToInsertRow();
	rs.updateString("job_id", id);
	rs.updateInt("user_id", attr.getUserId());
	rs.updateString("name", Name.PERMISSIONS.toString());
	rs.updateString("val", "READ,WRITE,DELETE,PRINT");
	rs.insertRow();
	rs.getStatement().close();
	com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.PROJECT, id,
		"Permissions: Added " + Name.PROJECT.getName() + ", " 
		+ Name.PERMISSIONS.getName() + " for user " + attr.getFullName(), session);
	sec.setJob(Integer.parseInt(id), request);
	attr.setJobId(Integer.parseInt(id));
	attr.setJobNum(request.getParameter("job_num"));
	attr.setJobName(request.getParameter("job_name"));
}
db.disconnect();
response.sendRedirect("../");
%>