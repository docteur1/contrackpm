<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@page import="com.sinkluge.utilities.Verify" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script language="javascript">
<%
if (!sec.ok(sec.SUBCONTRACT,sec.WRITE)) {
	response.sendRedirect("../../accessDenied.html");
	return;
}

Verify v = new Verify();

String query = "insert ignore into owner_pay_requests (job_id, period, paid_by_owner) values (?,?,?)";

Database db = new Database();
PreparedStatement ps = db.preStmt(query);

ps.setInt(1, attr.getJobId());

String t = request.getParameter("year");
t = request.getParameter("month") + "/" + t;
ps.setString(2,t);

t = request.getParameter("paid_by_owner");
if (!v.blank(t) && !v.date(t)) v.msg("Date Paid by Owner is invalid");
else {
	if (t != null && t.equals("")) ps.setString(3, null);
	else ps.setString(3, t.substring(6) + "-" + t.substring(0,2) + "-" + t.substring(3,5));
}
boolean saved = false;
String id = null;
if (v.message.equals("")) {
	saved = ps.executeUpdate() != 0;
	ResultSet rs = ps.getGeneratedKeys();
	if (rs.first()) {
		id = rs.getString(1);
		com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.OPR, 
				id, session);
	}
	if (rs != null) rs.close();
} else {
%>
	alert("Unable to create Pay Request Period\n---------------------------------------------------------\n<%= v.message %>");
	history.back();
<%
}
if (ps != null) ps.close();
db.disconnect();
if (v.message.equals("")) response.sendRedirect("reviewPayRequests.jsp?id=" + id);
%>
</script>