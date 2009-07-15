<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.util.HashMap" %>
<%@page import="kf.KF, java.util.Iterator, java.util.List" %>
<%@page import="kf.client.Projectfield, kf.client.Project, kf.client.User, kf.config.client.*"%>
<%@page import="com.sinkluge.database.Database"%>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<%@page import="com.sinkluge.security.Security, com.sinkluge.utilities.FormHelper" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<%
String site_id = request.getParameter("site_id");
if (site_id == null) site_id = "1";
if (!sec.ok(Security.ADMIN, Security.READ)) {
	response.sendRedirect("../accessDenied.jsp");
	return;
}
boolean saved = false;
ResultSet rs;
Database db = new Database();
if (request.getParameter("kf_proj_field_id") != null) {
	rs = db.dbQuery("select * from settings where id = 'site" + site_id + "' "
			+ "and name like 'kf_%'", true);
	while (rs.next()) {
		rs.updateString("val", request.getParameter(rs.getString("name")));
		rs.updateRow();
	}
	if (rs != null) rs.getStatement().close();
	rs = null;
	saved = true;
	attr.load();
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css" >
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<font size="+1">KlickFileWeb Integration</font><hr>
<a href="superAdmin.jsp">Administration</a> &gt; KlickFileWeb Integration<hr/>
<%
if (saved) out.print("<font color=\"red\"><b>Settings Saved</b></font><hr>");
%>
<form method="POST">
<table>
	<tr>
		<td class="lbl">Site</td>
		<td><select name="site_id" onChange="window.location = 'updateKFsettings.jsp?site_id=' + this.value;">
<%
rs = db.dbQuery("select site_id, site_name from sites order by site_id");
while (rs.next()) out.println("<option value=\"" + rs.getString(1) + "\" " + FormHelper.sel(rs.getString(1),
	site_id) + ">" + rs.getString(2) + "</option>");
if (rs != null) rs.getStatement().close();
HashMap<String, String> hm = new HashMap<String, String>();	
rs = db.dbQuery("select name, val from settings where id = 'site" + site_id + "' and name like 'kf_%'");
while (rs.next()) hm.put(rs.getString("name"), rs.getString("val"));
if (rs != null) rs.getStatement().close();
rs = null;
db.disconnect();
%>
		</select></td>
	</tr>
	<tr>
		<td class="lbl">Project Doc ID Field</td>
		<td><select name="kf_proj_field_id">
<%
KF kf = KF.getKF(session);
Projectfield pf;
Project p;
List l = kf.getList(Projectfield.class);
for (Iterator i = l.iterator(); i.hasNext(); ) {
	pf = (Projectfield) i.next();
	p = pf.getProject();
	if (!p.getDeleted()) {
		out.println("<option value=\"" + pf.getFieldID() + "\" " + FormHelper.sel(pf.getFieldID().toString(), 
				hm.get("kf_proj_field_id")) + ">" + p.getProjectName() + ": " 
				+ pf.getFieldName() + "</option>");
	}
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">Accounting Voucher Field</td>
		<td><select name="kf_acc_field_id">
<%
for (Iterator i = l.iterator(); i.hasNext(); ) {
	pf = (Projectfield) i.next();
	if (pf != null) {
		p = pf.getProject();
		if (!p.getDeleted()) {
			out.println("<option value=\"" + pf.getFieldID() + "\" " + FormHelper.sel(pf.getFieldID().toString(), 
					hm.get("kf_acc_field_id")) + ">" + p.getProjectName() + ": " 
					+ pf.getFieldName() + "</option>");
		}
	}
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">Accounting Vendor Field</td>
		<td><select name="kf_acc_field_vendor_id">
<%
for (Iterator i = l.iterator(); i.hasNext(); ) {
	pf = (Projectfield) i.next();
	if (pf != null) {
		p = pf.getProject();
		if (!p.getDeleted()) {
			out.println("<option value=\"" + pf.getFieldID() + "\" " + FormHelper.sel(pf.getFieldID().toString(), 
					hm.get("kf_acc_field_vendor_id")) + ">" + p.getProjectName() + ": " 
					+ pf.getFieldName() + "</option>");
		}
	}
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">Accounting Check Field</td>
		<td><select name="kf_acc_field_check_id">
<%
for (Iterator i = l.iterator(); i.hasNext(); ) {
	pf = (Projectfield) i.next();
	if (pf != null) {
		p = pf.getProject();
		if (!p.getDeleted()) {
			out.println("<option value=\"" + pf.getFieldID() + "\" " + FormHelper.sel(pf.getFieldID().toString(), 
					hm.get("kf_acc_field_check_id")) + ">" + p.getProjectName() + ": " 
					+ pf.getFieldName() + "</option>");
		}
	}
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">Accounting PO Field</td>
		<td><select name="kf_acc_field_po_id">
<%
for (Iterator i = l.iterator(); i.hasNext(); ) {
	pf = (Projectfield) i.next();
	if (pf != null) {
		p = pf.getProject();
		if (!p.getDeleted()) {
			out.println("<option value=\"" + pf.getFieldID() + "\" " + FormHelper.sel(pf.getFieldID().toString(), 
					hm.get("kf_acc_field_po_id")) + ">" + p.getProjectName() + ": " 
					+ pf.getFieldName() + "</option>");
		}
	}
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">Accounting Protected Field</td>
		<td><select name="kf_acc_pro_field_id">
<%
for (Iterator i = l.iterator(); i.hasNext(); ) {
	pf = (Projectfield) i.next();
	if (pf != null) {
		p = pf.getProject();
		if (!p.getDeleted()) {
			out.println("<option value=\"" + pf.getFieldID() + "\" " + FormHelper.sel(pf.getFieldID().toString(), 
					hm.get("kf_acc_pro_field_id")) + ">" + p.getProjectName() + ": " 
					+ pf.getFieldName() + "</option>");
		}
	}
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">Configuration</td>
		<td><select name="kf_config_id">
<%
Customerconfig cc;
for (Iterator i = kf.getIterator(Customerconfig.class); i.hasNext(); ) {
	cc = (Customerconfig) i.next();
	out.println("<option value=\"" + cc.getId() + "\" " + FormHelper.sel(cc.getId().toString(), 
			hm.get("kf_config_id")) + ">" + cc.getCustomerName() + ": " + cc.getProjectRoot() 
			+ "</option>");
}
%>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">KFW Company</td>
		<td><select name="kf_company_id">
<%
Company comp;
for (Iterator i = kf.getIterator(Company.class); i.hasNext(); ) {
	comp = (Company) i.next();
	out.println("<option value=\"" + comp.getCompanyId() + "\" " + FormHelper.sel(
			comp.getCompanyId().toString(), hm.get("kf_config_id")) + ">" + comp.getCompanyName()
			+ "</option>");
}
%>
			</select>
		</td>
	</tr>
<%
kf.close();
%>
	<tr>
		<td class="lbl">Update</td>
		<td>On <input type="radio" name="kf_update_index" value="1" 
			<%= FormHelper.chk("1".equals(hm.get("kf_update_index"))) %>> Off
			<input type="radio" name="kf_update_index" value="0"
			<%= FormHelper.chk("0".equals(hm.get("kf_update_index"))) %>></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Save"></td>
	</tr>
</table>
</form>
</body>
</html>