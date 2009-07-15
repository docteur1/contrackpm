<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="java.sql.PreparedStatement, java.sql.ResultSet"%>
<%@page import="com.sinkluge.utilities.DateUtils, com.sinkluge.UserData" %>
<%@page import="com.sinkluge.database.Database" %>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
<script>
<%
if (!sec.ok(Security.SUBMITTALS, Security.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String id = request.getParameter("id");
String costCodeID;
String contractID = "0";
if (id.indexOf("c") != -1) {
	costCodeID = id.substring(0, id.indexOf("c"));
	contractID = id.substring(id.indexOf("c") + 1);
} else costCodeID = id;
String architect_id = request.getParameter("architect_id");
String acc = request.getParameter("altCostCode");
if(acc==null) acc = "";
String submittal_num = request.getParameter("submittal_num");
if (submittal_num == null) submittal_num = "";
String date_received = request.getParameter("received");
String date_to_architect = request.getParameter("toArchitect");
String date_from_architect = request.getParameter("fromArchitect");
String date_to_sub = request.getParameter("toSub");
String insert = "insert into submittals (job_id, contract_id, architect_id, " +
	"attempt, description, date_received, date_to_architect, date_from_architect, date_to_sub, submittal_status, " +
	"submittal_type, user_id, comment_to_architect, comment_to_sub, printed_exceptions, " +
	"alt_cost_code, submittal_num, date_created, cost_code_id) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,curdate(),?)";
Database db = new Database();
PreparedStatement ps = db.preStmt(insert);
ps.setInt(1,attr.getJobId());
ps.setString(2,contractID);
ps.setString(3,architect_id);
ps.setString(4,request.getParameter("attempt"));
ps.setString(5,request.getParameter("description"));
ps.setDate(6,DateUtils.getSQLShort(date_received));
ps.setDate(7,DateUtils.getSQLShort(date_to_architect));
ps.setDate(8,DateUtils.getSQLShort(date_from_architect));
ps.setDate(9,DateUtils.getSQLShort(date_to_sub));
ps.setString(10,request.getParameter("submittal_status"));
ps.setString(11,request.getParameter("submittal_type"));
ps.setString(12,request.getParameter("user_id"));
ps.setString(13,request.getParameter("comment_to_architect"));
ps.setString(14,request.getParameter("comment_to_sub"));
ps.setString(15,request.getParameter("printed_exceptions"));
ps.setString(16,acc);
ps.setString(17,submittal_num);
ps.setString(18, costCodeID);
ps.executeUpdate();
ResultSet rs = ps.getGeneratedKeys();
if (rs.first()) {
	com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.SUBMITTAL,
		rs.getString(1), session);
%>
	parent.opener.location = "reviewSubmittals.jsp?sort=num";
	parent.location = "modifySubmittalFrameset.jsp?subID=<%= rs.getString(1) %>";
<%
}
rs.close();
rs = null;
ps.close();
ps = null;
db.disconnect();
%>
</script>
</head>
</html>



