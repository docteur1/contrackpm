<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.sinkluge.security.Name, com.sinkluge.security.Permission" %>
<%@page import="com.sinkluge.utilities.DateUtils, com.sinkluge.utilities.DataUtils" %>
<%@page import="accounting.Accounting,com.sinkluge.accounting.AccountingUtils" %>
<%@page import="accounting.Subcontract, accounting.Code, accounting.Result" %>
<%@page import="org.apache.log4j.Logger" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Name.SUBCONTRACTS, Permission.WRITE)) {
	response.sendRedirect("../accessDenied.html");
	return;
}
String msg = null;
Logger log = Logger.getLogger(this.getClass());
String query = "select * from contracts where contract_id = " + request.getParameter("contract_id");
Database db = new Database();
ResultSet rs = db.dbQuery(query, true), rs2 = null;
boolean changed = false;
if (rs.first()) {
	Accounting acc = AccountingUtils.getAccounting(session);
	Subcontract old = AccountingUtils.getSubcontract(rs, attr.getSiteId());
	String ccId = request.getParameter("cost_code_id");
	// Is there a cost code change?
	if (!ccId.equals(rs.getString("cost_code_id"))) {
		ResultSet temp = db.dbQuery("select count(*) from change_request_detail where contract_id = "
			+ request.getParameter("contract_id"));
		if (temp.first() && temp.getInt(1) > 0) {
%>
<script>
	window.alert("WARNING!\n-------------------\nUnable to change cost code on contract!\n"
		+ "<%= temp.getInt(1) %> contract change(s) exist!");
</script>
<%
		} else {
			temp = db.dbQuery("select count(*) from submittals where contract_id = "
					+ request.getParameter("contract_id"));
				if (temp.first() && temp.getInt(1) > 0) {
%>
<script>
	window.alert("WARNING!\n-------------------\nUnable to change cost code on contract!\n"
		+ "<%= temp.getInt(1) %> associated submittals(s) exist!");
</script>
<%
			} else {
				rs.updateString("cost_code_id", ccId);
				changed = true;
			}
		}
	}
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
	rs.updateString("req_specialty", request.getParameter("req_specialty"));
	rs.updateDouble("retention_rate", Double.parseDouble(DataUtils.decimal(request.getParameter("retention_rate")))/100);
	rs.updateString("have_specialty", DataUtils.oldBoolean(request.getParameter("have_specialty")));
	rs.updateString("tracking_notes", request.getParameter("tracking_notes"));
	rs.updateString("completed", DataUtils.oldBoolean(request.getParameter("completed")));
	rs.updateRow();
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.SUBCONTRACT, 
		request.getParameter("contract_id"), session);
%>
<script>
	parent.opener.location.reload();
</script>
<%
	Subcontract updated = null;
	if (changed) {
		query = "select account_id from company_account_ids where company_id = " + rs.getString("company_id") +
	" and site_id = " + attr.getSiteId();
		rs2 = db.dbQuery(query);
		if (rs2.first() && old != null) {
			Code code = AccountingUtils.getCode(rs.getInt("cost_code_id"));
			updated = AccountingUtils.getSubcontract(rs, attr.getSiteId());
			updated.setOld(old);
			Result result = acc.updateSubcontract(updated);
			
			rs.updateString("altContractId", result.getId("altContractId"));
			rs.updateRow();
		}
		if (rs2 != null) rs2.getStatement().close();
		rs2 = null;
	}
	if (request.getParameter("safety_manual") != null) 
		db.dbInsert("update company set safety_manual ='y' where company_id = " + rs.getString("company_id"));
	else db.dbInsert("update company set safety_manual ='n' where company_id = " + rs.getString("company_id"));
	if (attr.hasAccounting()) {
		// Get the updated contract info
		updated = AccountingUtils.getSubcontract(rs, attr.getSiteId());
		updated.setOld(old);
		// Does it have account_id then save it...
		if (updated.getAltCompanyId() != null) {
			log.debug("Updating subcontract in accounting");
			Result result = acc.updateSubcontract(updated);
			rs.updateString("altContractId", result.getId("altContractId"));
			rs.updateRow();
			msg = result.getMessage();
%>
<script>
	window.location = "modifyContract.jsp?id=<%=request.getParameter("contract_id")%>&msg=<%= msg != null ? msg : "Saved"%>";
</script>
<%
		} else response.sendRedirect("processModifyContract2.jsp?id=" + request.getParameter("contract_id"));
	}
} // rs.first();
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>