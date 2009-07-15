<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" %>
<%@page import="kf.KF, kf.client.Document, java.util.List, java.util.Iterator" %>
<%@page import="com.sinkluge.Type, java.sql.ResultSet, com.sinkluge.utilities.FormHelper" %>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%@page import="com.sinkluge.database.Database" %>
<%
Type type = Type.valueOf(request.getParameter("type"));
if (type == null) throw new ServletException("parameter \"type\" cannot be null");
if (!sec.ok(type.getSecurityName(), Permission.READ)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
%>
<script>
	function openKFDoc(docId) {
		var msgWin = window.open("print.jsp?doc=image.pdf?id=<%= type.getCode() + request.getParameter("id") %>&document_id=" + docId, "print");
		msgWin.focus();
	}
	function replace (obj) {
		document.getElementById("i" + obj.id).style.display = "none";
		obj.style.display = "inline";
	}
</script>
<div class="bold">Scanned Documents</div>
<table cellspacing="0" cellpadding="3">
<%
KF kf = KF.getKF(request.getSession());
Database db = new Database();
if (kf != null) {
	List<Document> docs = kf.getProjectDocuments(type.getCode() + 
		request.getParameter("id"));
	if (docs == null || docs.size() == 0) {
%>
	<tr>
		<td class="left head">Image</td>
		<td class="right head">Options</td>
	</tr>
	<tr>
		<td class="left right bold" colspan="2" align="center">No images found!</td>
	</tr>
<%
	} else {
		if (docs.size() > 1) {
%>
	<tr>
		<td class="left head">Image</td>
		<td class="head">Options</td>
		<td class="head">Image</td>
		<td class="right head">Options</td>
	</tr>
<%	
		} else {
%>
	<tr>
		<td class="left head">Image</td>
		<td class="right head">Options</td>
	</tr>
<%		
		}
		Document doc;
		ResultSet rs;
		boolean print, share;
		for (Iterator<Document> i = docs.iterator(); i.hasNext(); ) {
			doc = i.next();
			rs = db.dbQuery("select * from kf_documents where document_id = " + doc.getDocumentID());
			if (rs.first()) {
				print = rs.getBoolean("print");
				share = rs.getBoolean("share");
			} else {
				print = false;
				share = false;
			}
			rs.getStatement().close();
%>
	<tr>
		<td class="acenter left right" style="height: 200px; width: 154px; padding: 0px;"><img id="i<%= doc.getDocumentID() %>" src="../../images/loading_circle.gif"><img style="cursor: pointer; display: none;" id="<%= doc.getDocumentID() %>" src="../servlets/images/image?id=<%= doc.getDocumentID() %>" onload="replace(this);" onclick="openKFDoc(<%= doc.getDocumentID() %>);"></td>
		<td class="right"><input id="pri<%= doc.getDocumentID() %>" type="checkbox" onclick="setImageValue(this, <%= doc.getDocumentID() %>, 'print');" <%= FormHelper.chk(print) %>> 
			<label class="bold" for="pri<%= doc.getDocumentID() %>">Print</label><br/><br/>
			<input id="p<%= doc.getDocumentID() %>" type="checkbox" onclick="setImageValue(this, <%= doc.getDocumentID() %>, 'share');" <%= FormHelper.chk(share) %>> 
			<label class="bold" for="s<%= doc.getDocumentID() %>">Share</label></td>
<%
			if (i.hasNext()) {
				doc = i.next();
				rs = db.dbQuery("select * from kf_documents where document_id = " + doc.getDocumentID());
				if (rs.first()) {
					print = rs.getBoolean("print");
					share = rs.getBoolean("share");
				} else {
					print = false;
					share = false;
				}
				rs.getStatement().close();
%>
		<td class="acenter right" style="height: 200px; width: 154px; padding: 0px;"><img id="i<%= doc.getDocumentID() %>" src="../../images/loading_circle.gif"><img style="cursor: pointer; display: none;" id="<%= doc.getDocumentID() %>" src="../servlets/images/image?id=<%= doc.getDocumentID() %>" onload="replace(this);" onclick="openKFDoc(<%= doc.getDocumentID() %>);"></td>
		<td class="right"><input id="pri<%= doc.getDocumentID() %>" type="checkbox" onclick="setImageValue(this, <%= doc.getDocumentID() %>, 'print');" <%= FormHelper.chk(print) %>> 
			<label class="bold" for="pri<%= doc.getDocumentID() %>">Print</label><br/><br/>
			<input id="s<%= doc.getDocumentID() %>" type="checkbox" onclick="setImageValue(this, <%= doc.getDocumentID() %>, 'share');" <%= FormHelper.chk(share) %>> 
			<label class="bold" for="s<%= doc.getDocumentID() %>">Share</label></td>
<%
			} else if (docs.size() > 1) out.println("<td colspan=\"2\">&nbsp;</td>");
			out.println("</tr>");
		}
	}
	if (docs != null) docs.clear();
}
db.disconnect();
%>
</table>