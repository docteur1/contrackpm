<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="gnu.hylafax.HylaFAXClient"%>
<%@page import="gnu.hylafax.HylaFAXClientProtocol"%>
<%@page import="gnu.hylafax.Job"%>
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%@page import="com.sinkluge.database.Database" %>
<html>
<script>
<%
boolean admin = request.getParameter("admin") != null;
String job_id = request.getParameter("job");
HylaFAXClient c = new HylaFAXClient();

Database db = new Database();
try{
	db.dbInsert("update fax_log set status = 'Canceling' where job_id = " + job_id);

	c.open(in.fax_host);

	c.user(in.fax_user);
	if (in.fax_pass != null) c.pass(in.fax_pass);

	c.tzone(HylaFAXClientProtocol.TZONE_LOCAL);

	Job job = c.getJob(Long.parseLong(job_id));
	c.kill(job);

	c.quit();
	
	db.disconnect();
	response.sendRedirect("faxLog.jsp" + (admin ? "?admin=t" : ""));

} catch(Exception e) {
	db.dbInsert("update fax_log set status = 'Error: " + e.toString() + "' where job_id = " + job_id);
	db.disconnect();
%>
	window.alert("Unable to cancel fax job <%= job_id %>\n--------------------------------------\n<%= 
		e.toString() %>");
	window.location = "faxLog.jsp<%= admin ? "?admin=t" : "" %>";
<%
}
%>
</script>
</html>

