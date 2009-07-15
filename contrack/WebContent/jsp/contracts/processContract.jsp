<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.utilities.DateUtils, com.sinkluge.utilities.DataUtils" %>
<%@page import="com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Subcontract, accounting.Code, accounting.Result" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script>
<%
if (!sec.ok(Name.SUBCONTRACTS, Permission.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String query = "select * from contracts where contact_id = 0";
Database db = new Database();
ResultSet rs = db.dbQuery(query, true);
rs.moveToInsertRow();
rs.updateInt("job_id", attr.getJobId());
rs.updateString("company_id", request.getParameter("company_id"));
rs.updateString("contact_id", request.getParameter("contact_id"));
rs.updateString("cost_code_id", request.getParameter("cost_code_id"));
rs.updateDate("agreement_date", DateUtils.getSQLShort(request.getParameter("agreementDate")));
rs.updateDate("date_sent", DateUtils.getSQLShort(request.getParameter("dateSent")));
rs.updateDate("date_received", DateUtils.getSQLShort(request.getParameter("dateReceived")));
rs.updateString("amount", request.getParameter("amount"));
rs.updateString("description", request.getParameter("description"));
rs.updateString("submittal_required", DataUtils.oldBoolean(request.getParameter("submittal_required")));
rs.updateString("insurance_proof", DataUtils.oldBoolean(request.getParameter("insurance_proof")));
rs.updateString("workers_comp_proof", DataUtils.oldBoolean(request.getParameter("workers_comp_proof")));
rs.updateDate("gen_insurance_expire", DateUtils.getSQLShort(request.getParameter("insExpire")));
rs.updateDate("workers_comp_expire", DateUtils.getSQLShort(request.getParameter("wkComp")));
rs.updateString("req_tech_submittals", DataUtils.oldBoolean(request.getParameter("req_tech_submittals")));
rs.updateString("have_tech_submittals", DataUtils.oldBoolean(request.getParameter("have_tech_submittals")));
rs.updateString("req_warranty", DataUtils.oldBoolean(request.getParameter("req_warranty")));
rs.updateString("have_warranty", DataUtils.oldBoolean(request.getParameter("have_warranty")));
rs.updateString("req_owner_training", DataUtils.oldBoolean(request.getParameter("req_owner_training")));
rs.updateString("have_owner_training", DataUtils.oldBoolean(request.getParameter("have_owner_training")));
rs.updateString("have_lien_release", DataUtils.oldBoolean(request.getParameter("have_lien_release")));
rs.updateDouble("retention_rate", Double.parseDouble(DataUtils.decimal(request.getParameter("retention_rate")))/100);
rs.updateString("req_specialty", request.getParameter("req_specialty"));
rs.updateString("have_specialty", DataUtils.oldBoolean(request.getParameter("have_specialty")));
rs.updateString("tracking_notes", request.getParameter("tracking_notes"));
rs.updateString("completed", "n");
rs.insertRow();
int max = 0;
if (rs.last()) {
	max = rs.getInt("contract_id");
	com.sinkluge.utilities.ItemLogger.Created.update(com.sinkluge.Type.SUBCONTRACT, 
		rs.getString("contract_id"), session);
	if (attr.hasAccounting()) {
		query = "select * from company_account_ids where company_id = " + rs.getString("company_id") +
			" and site_id = " + attr.getSiteId();
		ResultSet comp = db.dbQuery(query);
		Subcontract data = AccountingUtils.getSubcontract(max);
		Result result = AccountingUtils.getAccounting(session).updateSubcontract(data);
		if (result.getId("altContractId") != null) {
			if (comp.first()) {
				rs.updateString("altContractId", result.getId("altContractId"));
				rs.updateRow();
			} else {
				comp.moveToInsertRow();
				rs.updateString("altContractId", result.getId("altContractId"));
				rs.updateRow();
				comp.updateString("company_id", rs.getString("company_id"));
				comp.insertRow();
			}
		}
		if (comp != null) comp.getStatement().close();
	}
}
if (rs != null) rs.getStatement().close();
rs = null;
if (request.getParameter("safety_manual") != null) 
	db.dbInsert("update company set safety_manual ='y' where company_id = " + request.getParameter("company_id"));
else db.dbInsert("update company set safety_manual ='n' where company_id = " + request.getParameter("company_id"));
db.disconnect();
%>
	parent.opener.location.reload();
	parent.location = "modifyContractFrameset.jsp?id=<%= max %>";
</script>