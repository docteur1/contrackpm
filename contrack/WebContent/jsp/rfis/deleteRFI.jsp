<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.RFI,1)) response.sendRedirect("../accessDenied.html");
String delete = "delete from rfi where rfi_id ="+ request.getParameter("id");
Database db = new Database();
db.dbInsert(delete);
com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.RFI,
	request.getParameter("id"), session);
delete = "delete from files where id = " + request.getParameter("id") + " and type = 'RF'";
db.dbInsert(delete);
db.disconnect();
response.sendRedirect("reviewRFIs.jsp");
%>
