<%@page session="true"%>
<%@page contentType="text/html"%>
<%@page import="java.sql.PreparedStatement" %>
<%@page import="com.sinkluge.UserData" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%
if (!sec.ok(Security.LETTERS, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<html>
<body>
<%
Database db = new Database();
String letter_id = request.getParameter("letter_id");

String insert = "update letters set cc=?, salutation=?, subject=?, body_text=?, user_id=? where letter_id = "
		+ letter_id;
PreparedStatement ps = db.preStmt(insert);
ps.setString(1, request.getParameter("cc"));
ps.setString(2, request.getParameter("salutation"));
ps.setString(3, request.getParameter("subject"));
ps.setString(4, request.getParameter("body_text"));
ps.setString(5, request.getParameter("user_id"));
ps.executeUpdate();
com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.LETTER,
		letter_id, session);
ps.close();
db.disconnect();
%>

<script>
parent.opener.location.reload();
window.location = "modifyLetter.jsp?letter_id=<%=letter_id%>&saved=true";
</script>
</body>
</html>


