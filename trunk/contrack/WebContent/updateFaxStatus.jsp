<%@page session="false" contentType="text/plain ; charset=ISO-8859-1" 
	import="com.sinkluge.fax.Fax" 
%><jsp:useBean id="in" scope="application" class="com.sinkluge.Info" 
/><jsp:useBean id="st" scope="application" class="java.util.HashMap" /><%
if (!in.key.equals(request.getParameter("key"))) {
	out.println("Unauthorized must supply the correct shared key");
	return;
}
Fax.updateStatus(request.getParameter("job_id"), request.getParameter("status"),
	request.getParameter("ss"), st);
out.println("Job " + request.getParameter("job_id") + " status updated to \"" 
	+ request.getParameter("status") + "\"");
%>