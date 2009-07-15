<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.PreparedStatement, java.sql.ResultSet"%>
<%@page import="com.sinkluge.UserData, com.sinkluge.utilities.DateUtils" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
<%
if (!sec.ok(Security.RFI, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String insert = "insert into rfi (date_created, user_id, company_id, job_id, contact_id, request, urgency, reply, respond_by, rfi_num) values (curdate(),?,?,?,?,?,?,?,?,?)";
Database db = new Database();
PreparedStatement ps = db.preStmt(insert);
ps.setString(1, request.getParameter("user_id"));
ps.setString(2, request.getParameter("company_id"));
ps.setInt(3, attr.getJobId());
ps.setString(4, request.getParameter("contact_id"));
ps.setString(5, request.getParameter("request"));
ps.setString(6, request.getParameter("urgency"));
ps.setString(7, request.getParameter("reply"));
ps.setDate(8, DateUtils.getSQLShort(request.getParameter("respond_by")));
ps.setString(9, request.getParameter("rfi_num"));
ps.executeUpdate();
ResultSet rs = ps.getGeneratedKeys();
rs.next();
com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.RFI,
	rs.getString(1), session);
%>
<script language="javascript">
	parent.opener.location.reload();
	parent.location="modifyRFIFrameset.jsp?id=<%= rs.getInt(1) %>";
</script>
<%
rs.close();
ps.close();
db.disconnect();
%>
</head>
</html>



