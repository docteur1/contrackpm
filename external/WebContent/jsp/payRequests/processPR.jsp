<%@page contentType="text/plain"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet, java.sql.Statement, java.util.Date, java.sql.Timestamp" %>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<%
int id = 0;
boolean fp = request.getParameter("final") != null;
String query = "select * from pay_requests";
db.connect();
int requestNum = Integer.parseInt(request.getParameter("request_num"));
Statement stmt = db.getStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
ResultSet rs = stmt.executeQuery(query);
rs.moveToInsertRow();
rs.updateString("opr_id", request.getParameter("opr_id"));
rs.updateInt("contract_id", db.contract_id);
rs.updateString("lien_waiver", request.getParameter("lien_waiver"));
rs.updateString("invoice_num", request.getParameter("inv_num"));
rs.updateString("co", request.getParameter("co"));
rs.updateString("value_of_work", request.getParameter("vwctd"));
rs.updateString("adj_value_of_work", request.getParameter("vwctd"));
rs.updateString("previous_billings", request.getParameter("ptd"));
rs.updateString("adj_previous_billings", request.getParameter("ptd"));
rs.updateString("retention", request.getParameter("ret"));
rs.updateString("adj_retention", request.getParameter("ret"));
rs.updateString("ext_mod_by", db.contact_name);
rs.updateTimestamp("ext_modified", new Timestamp(new Date().getTime()));
rs.updateDate("date_created", new java.sql.Date(new Date().getTime()));
rs.updateInt("request_num", requestNum);
rs.updateString("external_comments", request.getParameter("external_comments"));
rs.updateBoolean("ext_created", true);
rs.updateBoolean("e_update", true);
rs.updateString("lien_waiver", (requestNum!=1?"Requested":"Not Required"));
rs.updateBoolean("final", fp);
rs.insertRow();
if (rs.last()) id = rs.getInt("pr_id");
if (fp) {
	System.out.println(request.getParameter("period"));
	// Create Retention
	rs.moveToInsertRow();
	query = "select * from owner_pay_requests where period = 'Retention' and"
		+ " job_id = " + db.job_id;
	Statement ret = db.getStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
	ResultSet retId = ret.executeQuery(query);
	if (!retId.isBeforeFirst()) {
		retId.moveToInsertRow();
		retId.updateString("period", "Retention");
		retId.updateInt("job_id", db.job_id);
		retId.insertRow();
		retId.last();
	} else retId.first();
	if (retId.first()) {
		rs.updateString("opr_id", retId.getString(1));
		rs.updateInt("contract_id", db.contract_id);
		rs.updateString("lien_waiver", "Requested");
		rs.updateString("ext_mod_by", db.contact_name);
		rs.updateTimestamp("ext_modified", new Timestamp(new Date().getTime()));
		rs.updateDate("date_created", new java.sql.Date(new Date().getTime()));
		rs.updateInt("request_num", Integer.parseInt(request.getParameter("request_num")) + 1);
		rs.updateBoolean("ext_created", true);
		rs.updateBoolean("e_update", true);
		rs.insertRow();
	}
	if (retId != null) retId.close();
	retId = null;
	ret.close();
	ret = null;
}
rs.close();
rs = null;
stmt.close();
stmt = null;
db.disconnect();
db.msg = "Saved";
response.sendRedirect("modifyPR.jsp?pr_id=" + id);
%>