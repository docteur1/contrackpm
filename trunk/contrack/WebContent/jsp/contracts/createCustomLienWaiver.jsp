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
LienWaiver lw = new LienWaiver();
Database db = new Database();
ResultSet rs = db.dbQuery("select job_id, city, state from job where job_id = " + attr.getJobId());
rs.first();
lw.setDocType(com.sinkluge.Type.PROJECT);
lw.setId(rs.getString("job_id"));
lw.setCompanyName(request.getParameter("company"));
lw.setJobCity(rs.getString("city"));
lw.setJobState(rs.getString("state"));
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
lw.setAmount(Double.parseDouble(request.getParameter("amount")));
lw.setDate(DateUtils.getSQLShort(request.getParameter("date")));
lw.setType(request.getParameter("type"));
lw.setAddress(request.getParameter("address"));
lw.setCity(request.getParameter("city"));
lw.setState(request.getParameter("state"));
lw.setZip(request.getParameter("zip"));
lw.setPhone(request.getParameter("phone"));
lw.setFax(request.getParameter("fax"));
attr.setLienWaiver(lw);
%>
	msgWin = window.open("", "print");
	var url = "../utils/print.jsp?doc=subLienWaiver.pdf";
	msgWin.location = url;
	msgWin.focus();
	window.close();
</script>