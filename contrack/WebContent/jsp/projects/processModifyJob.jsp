<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.utilities.DateUtils" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<html>
<script>
<%
if (!sec.ok(Security.JOB, Security.WRITE)) response.sendRedirect("../accessDenied.html");
else {
String query = "select * from job where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
if (rs.first()) {
	rs.updateString("job_num", request.getParameter("job_num"));
	attr.setJobNum(request.getParameter("job_num"));
	rs.updateString("job_name", request.getParameter("job_name"));
	attr.setJobName(request.getParameter("job_name"));
	rs.updateString("address", request.getParameter("address"));
	rs.updateString("city", request.getParameter("city"));
	rs.updateString("state", request.getParameter("state"));
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
	rs.updateString("submit_co_to", request.getParameter("submitCO"));
	rs.updateString("contract_method", request.getParameter("contractMethod"));
	rs.updateString("site_size", request.getParameter("siteSize"));
	rs.updateString("building_size", request.getParameter("buildingSize"));
	rs.updateDate("substantial_completion_date", DateUtils.getSQLShort(request.getParameter("sub_date")));
	rs.updateString("description", request.getParameter("description"));
	t = request.getParameter("active");
	t = t == null?"n":"y";
	rs.updateString("active", t);
	rs.updateDouble("retention_rate", Double.parseDouble(request.getParameter("retention"))/100);
	rs.updateString("site_id", request.getParameter("site_id"));
	attr.setSiteId(Integer.parseInt(request.getParameter("site_id")));
	rs.updateRow();
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT, 
		Integer.toString(attr.getJobId()), session);
}
if (rs != null) rs.getStatement().close();
rs = null;
attr.load();
db.disconnect();
}
%>
	window.parent.loadProjectList();
	window.location = "modifyJob.jsp?saved=t";
</script>
</html>
