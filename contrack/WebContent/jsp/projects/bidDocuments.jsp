<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if(!sec.ok(Security.SUBCONTRACT, Security.READ)) response.sendRedirect("../accessDenied.html");
String query = "select bid_documents from job where job_id = " + attr.getJobId();
Database db = new Database();
ResultSet rs = db.dbQuery(query);
String bid_documents = "";
if (rs.next()) bid_documents = rs.getString("bid_documents");
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
if (bid_documents == null) bid_documents = "";
%>

<html>
<head>
	<LINK REL="StyleSheet" HREF="../stylesheets/v2.css" TYPE="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script language="javascript" src="../utils/spell.js"></script>
	<title>Bid Documents</title>
	<script src="<%= request.getContextPath() %>/jsp/utils/popup.js"></script>
</head>
<body>
<form name="bidDocuments" action="processBidDocuments.jsp" method="POST">
<font size="+1">Bid Documents</font><hr>
<%
if (request.getParameter("save") != null) out.print("<div class=\"red bold\">Saved</div><hr>");
%>
<div class="bold" style="margin-bottom: 7px;"><%= attr.getJobName() %></div>
<div>Enter/modify the list of Bid Documents to be printed in all Subcontract Agreements of this job.</div>
<textarea rows=20 cols=90 name="bid_documents"><%= bid_documents %></textarea>
<p>
<%
if (sec.ok(Security.SUBCONTRACT, Security.WRITE)) {
%>
<input type="submit" value="Save" accesskey="s"> &nbsp;
 <input type="button" value="Close" onClick="window.close();" accesskey="c"> &nbsp;
<%
}
%>
 <input type="button" value="Spelling" onClick="spellCheck(this.form);" accesskey="k"> 
</form>
<script language="javascript">
	var body = document.firstChild;
	document.bidDocuments.bid_documents.focus();
	document.bidDocuments.bid_documents.spell = true;
</script>
</body></html>
