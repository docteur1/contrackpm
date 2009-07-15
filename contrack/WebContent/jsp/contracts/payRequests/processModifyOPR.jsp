<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.PreparedStatement, com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.utilities.DateUtils"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<script language="javascript">
<%
if (!sec.ok(Security.SUBCONTRACT,Security.WRITE)) response.sendRedirect("../,,/accessDenied.html");

String id = request.getParameter("id");
PreparedStatement ps;
Database db = new Database();
int update = 0;
if (sec.ok(Security.APPROVE_PAYMENT, Security.WRITE)) {
	String query = "update owner_pay_requests set paid_by_owner=?, locked=? where opr_id = " + id;
	ps = db.preStmt(query);
	ps.setDate(1, DateUtils.getSQLShort(request.getParameter("paid_by_owner")));
	ps.setBoolean(2, request.getParameter("locked") != null);
	update = ps.executeUpdate();
} else {
	String query = "update owner_pay_requests set paid_by_owner=? where opr_id = " + id;
	ps = db.preStmt(query);
	ps.setDate(1, DateUtils.getSQLShort(request.getParameter("paid_by_owner")));
	update = ps.executeUpdate();
}
if (update > 0) com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.OPR, id, session);
if (ps != null) ps.close();
ps = null;
db.disconnect();

%>
opener.document.location.reload();
location = "modifyOPR.jsp?saved=true&id=<%= id %>";
</script>