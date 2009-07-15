<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.sinkluge.UserData, com.sinkluge.utilities.DateUtils" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
<%
if (!sec.ok(Security.RFI, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String rfi_id = request.getParameter("id");
String insert = "update rfi set user_id = ?, contact_id = ?, request = ?, urgency = ?, reply = ?, respond_by = ?, "
		+ "date_received = ?, rfi_num = ?, contact_id=? where rfi_id = " + rfi_id;
Database db = new Database();
PreparedStatement ps = db.preStmt(insert);
ps.setString(1, request.getParameter("user_id"));
ps.setString(2, request.getParameter("contact_id"));
ps.setString(3, request.getParameter("request"));
ps.setString(4, request.getParameter("urgency"));
ps.setString(5, request.getParameter("reply"));
ps.setDate(6, DateUtils.getSQLShort(request.getParameter("respond_by")));
ps.setDate(7, DateUtils.getSQLShort(request.getParameter("date_received")));
ps.setString(8, request.getParameter("rfi_num"));
ps.setString(9, request.getParameter("contact_id"));
ps.executeUpdate();
com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.RFI,
	rfi_id, session);
ps.close();
db.disconnect();
%>
<script language="javascript">
	parent.opener.location.reload();
	parent.location="modifyRFIFrameset.jsp?id=<%=rfi_id%>&save=true";
</script>
</head>
</html>

