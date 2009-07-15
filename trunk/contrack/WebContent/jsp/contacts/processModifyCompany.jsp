<%@page session="true" %>
<%@page contentType="text/html"%>
<%@page import="com.sinkluge.utilities.FormHelper, com.sinkluge.accounting.AccountingUtils" %>
<%@page import="java.sql.PreparedStatement, java.sql.SQLException, com.sinkluge.database.Database"%>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<script>
<%
String id = request.getParameter("id");

String query = "update company set company_name=?, address=?, city=?, state=?, zip=?, federal_id=?, " +
	"license_number=?, website=?, description=?, safety_manual=?, phone=?, fax=?, ext_trained=?";
query += " where company_id = "	+ id;
Database db = new Database();
PreparedStatement ps = db.preStmt(query);
ps.setString(1, request.getParameter("company_name"));
ps.setString(2, request.getParameter("address"));
ps.setString(3, request.getParameter("city"));
ps.setString(4, request.getParameter("state"));
ps.setString(5, request.getParameter("zip"));
ps.setString(6, request.getParameter("federal_id"));
ps.setString(7, request.getParameter("license_number"));
ps.setString(8, request.getParameter("website"));
ps.setString(9, request.getParameter("description"));
ps.setString(10, request.getParameter("safety_manual")!=null?"y":"n");
ps.setString(11, request.getParameter("phone"));
ps.setString(12, request.getParameter("fax"));
ps.setBoolean(13, request.getParameter("ext_trained") != null);
try { 
	ps.executeUpdate();
	com.sinkluge.utilities.ItemLogger.Updated.update(com.sinkluge.Type.COMPANY_COMMENT, id, session);
	if (attr.hasAccounting()) {
		if (FormHelper.stringNull(request.getParameter("account_id")) != null) {
			AccountingUtils.setCompanyId(Integer.parseInt(id), request.getParameter("account_id"),
					attr.getSiteId());
		} else db.dbInsert("delete from company_account_ids where company_id = " + id + " and site_id = "
				+ attr.getSiteId());
	}
%>
	window.location = "modifyCompany.jsp?id=<%= id %>&save=true";
<%
} catch (SQLException e) {
%>
	window.alert("A company named \"<%= request.getParameter("company_name") %>\" already exists!");
	window.location = "modifyCompany.jsp?id=<%= id %>";
<%
} finally {
	if (ps != null) ps.close();
	ps = null;
	db.disconnect();
}
%>
</script>

