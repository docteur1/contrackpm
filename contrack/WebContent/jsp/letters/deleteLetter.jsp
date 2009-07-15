<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
if (!sec.ok(Security.LETTERS, Security.DELETE)) response.sendRedirect("../accessDenied.html");
String delete = "delete from letters where letter_id=" + request.getParameter("letterID");
Database db = new Database();
db.dbInsert(delete);
com.sinkluge.utilities.ItemLogger.Deleted.update(com.sinkluge.Type.LETTER,
	request.getParameter("letterID"), session);
delete = "delete from letter_contacts where letter_id = " + request.getParameter("letterID");
db.dbInsert(delete);
db.disconnect();
response.sendRedirect("reviewLetters.jsp");
%>

