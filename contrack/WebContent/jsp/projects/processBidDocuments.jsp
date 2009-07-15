<%@page session="true" %>
<%@page contentType="text/plain"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if(!sec.ok(Security.SUBCONTRACT, Security.WRITE)) response.sendRedirect("../accessDenied.html");
String insert = "update job set bid_documents=? where job_id = " + attr.getJobId();
Database db = new Database();
PreparedStatement ps = db.preStmt(insert);
ps.setString(1, request.getParameter("bid_documents"));
ps.executeUpdate();
com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.PROJECT, 
		Integer.toString(attr.getJobId()), "Updated Bid Documents", session);
if (ps != null) ps.close();
ps = null;
db.disconnect();
response.sendRedirect("bidDocuments.jsp?save=true");
%>


