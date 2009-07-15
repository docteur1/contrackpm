<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.security.Security"%>
<%
if (!sec.ok(Security.SUBMITTALS, Security.DELETE)) response.sendRedirect("../accessDenied.html");
String delete = "delete from submittals where submittal_id="+ request.getParameter("subID");
Database db = new Database();
db.dbInsert(delete);
com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.SUBMITTAL,
	request.getParameter("subID"), session);
delete = "delete from files where id = " + request.getParameter("subID") + " and type = 'SL'";
db.dbInsert(delete);
db.disconnect();
response.sendRedirect("reviewSubmittals.jsp");
%>
