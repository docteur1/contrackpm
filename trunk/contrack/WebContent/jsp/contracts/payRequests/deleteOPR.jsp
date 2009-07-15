<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<script language="javascript">
<%
if (!sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
	response.sendRedirect("../../accessDenied.jsp");
	return;
}
String id = request.getParameter("id");
String query = "select pr_id from pay_requests where opr_id = " + id;
Database db = new Database();
ResultSet rs = db.dbQuery(query);
if (rs.next()) {
%>
	alert("ERROR!\n--------------------------\nThis period contains pay requests, unable to delete.");
<%
} else {
	query = "delete from owner_pay_requests where opr_id = " + id;
	db.dbInsert(query);
	com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.OPR, id, session);
}
if (rs != null) rs.close();
rs = null;
db.disconnect();
%>
	window.location.href = "reviewOwnerPayRequests.jsp";
</script>