<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="com.sinkluge.reports.ReportContact, java.sql.ResultSet,
	com.sinkluge.security.*,
	kf.KF, java.util.List, java.util.Iterator, com.sinkluge.utilities.FormHelper,
	org.apache.log4j.Logger, com.sinkluge.attributes.Attributes,
	kf.client.Document, accounting.VoucherAttachment, accounting.Accounting,
	com.sinkluge.accounting.AccountingUtils" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="JSONRPCBridge" scope="session" class="org.jabsorb.JSONRPCBridge" />
<html>
<head>
	<link rel="SHORTCUT ICON" href="../../images/ct64.ico">
	<title>Document</title>
	<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
	<script>
		var curDoc = 0;
		var path = "";
		var id = null;
		var add = null;
		function encryptDoc(obj) {
			load(obj.checked);
		}
		function load(enc) {
			print.style.visibility = "hidden";
			if (print.readyState) print.onreadystatechange = clear;
			else print.onload = clear;
			var loc = "../servlets/reports/" + getDocPath();
			print.src = loc + (enc ? "&encrypt=true" : "") 
				+ "#view=FitV&statusbar=1&navpanes=0";
			document.getElementById("load").style.display = "block";
		}
		function getDocPath() {
			return path + (id != null ? "?id=" + id : "")
				+ (add != null ? "&add=" + add : "");
		}
		function clear(e) {
			document.getElementById("load").style.display = "none";
			print.style.height = (document.body.clientHeight - print.offsetTop) + "px";
			print.style.visibility = "visible";
		}
	</script>
</head>
<%
/*
 * What if there isn't a document to show? Let's be graceful!
 */
Logger log = Logger.getLogger(this.getClass());
String path = request.getParameter("doc");
log.debug("got path: " + path);
String docURL;
if (path.indexOf("?") != -1) docURL = path.substring(0, path.indexOf("?"));
else docURL = path;
String id = null;
if (path.indexOf("id=") != -1) id = path.substring(path.indexOf("id=") + 3);
String add = request.getParameter("add");
com.sinkluge.reports.Report r = null;
log.debug("docURL: " + docURL);
Database db = new Database();
if (docURL.indexOf("image") == -1) r = com.sinkluge.servlets.PDFReport.getReport(
		request, path, id, null, db, attr, in);
ReportContact rp = null;
if (r != null) rp = r.getReportContact(id, db);
%>
<body style="margin-top: 0px; margin-right: 0px; margin-left: 0px; margin-bottom: 0px; background-color: #A0B8C8">
<div style="padding: 7px;">
<input id="emailButton" type="button" value="Email" onClick="window.location='email.jsp?doc=' + getDocPath() + '<%=
	rp != null &&  rp.getContactId() != 0 
	?"&contact_id=" + rp.getContactId() : "" %>'">
<%
if (in.hasFax) {
%>
<input id="faxButton" type="button" value="Fax" onClick="window.location='fax.jsp?doc=' + getDocPath() + '<%= 
	rp != null && rp.getContactId() != 0 
	?"&contact_id=" + rp.getContactId() :  rp != null &&
	rp.getCompanyId() != 0?"&company_id=" + rp.getCompanyId():"" %>'">
<%
}
if (path.indexOf("Transmittal") == -1) {
%>
<input id="tranButton" type="button" value="Add To Transmittal" 
	onclick="window.location = '../transmittals/newTransmittal.jsp?docPath='+ getDocPath();"/>
<%	
}
%>
<input type="button" value="Close" onClick="window.close();"> &nbsp;
<%
// The image parameter will specify if it's a scan or not 
if (docURL.indexOf("image") != -1) {
	boolean accImage = path.indexOf("Acc") != -1;
	if (log.isDebugEnabled()) log.debug("image is acc ? " + accImage);
	/* If sc_id is passed we may be on another site --> the session attr is WRONG!!! */
	String sql;
	ResultSet rs;
	Attributes at = attr;
	String job = null;
	Security s = sec;
	if (request.getParameter("sc_id") != null) {
		sql = "select job_num, job_name, site_id, job.job_id from suspense_cache join job using(job_id) where sc_id = " +
			request.getParameter("sc_id");
		rs = db.dbQuery(sql);
		if (rs.first()) {
			at = new Attributes();
			at.setSiteId(rs.getInt(3));
			at.load();
			job = rs.getString(1) + ": " + rs.getString(2);
			s = new Security();
			s.isAdmin(sec.ok(Name.ADMIN, Permission.READ));
			s.setJob(rs.getInt("job_id"), request);
			rs.getStatement().close();
			if (!s.ok(Name.ACCOUNTING_DATA, Permission.READ)) {
				response.sendRedirect("../accessDenied.jsp");
				db.disconnect();
				return;
			}
		}
	}
	KF kf = KF.getKF(application, at);
	List<Document> kfdocs = null;
	List<VoucherAttachment> accdocs = null;
	add = id;
	Accounting acc = null;
	if (accImage) {
		kfdocs = kf.getAccountDocuments(id, s.ok(Name.ACCOUNTING, Permission.READ));
		if (at.hasAccounting()) {
			acc = AccountingUtils.getAccounting(application, at);
			if (acc.hasDocuments())	accdocs = acc.getVoucherAttachments(id);
		}
		add = "AC" + id;
	} else kfdocs = kf.getProjectDocuments(id);
	int count = 0;
	if (kfdocs != null) count = kfdocs.size();
	if (accdocs != null) count += accdocs.size();
	boolean foundFirst = false;
	if (count > 0) {
		if (accImage) JSONRPCBridge.registerClass("home", com.sinkluge.JSON.Home.class);
%>
<script src="jsonrpc.js"></script>
<script>
	var jsonrpc = new JSONRpcClient("../JSON-RPC");
	var docs = new Array(<%= count %>);
	var accImage = <%= accImage %>;
	function doc(id, kfw) {
		this.id = id;
		this.kfw = kfw;
	}
<%
		int curcount = 0;
		String voucherId = id;
		if (kfdocs != null && kfdocs.size() > 0) {
			Document doc = null;	
			// What document exactly are we loading?
			long curDocumentID = 0;
			try { 
				curDocumentID = Long.parseLong(request.getParameter("document_id"));
				id = request.getParameter("document_id");
				foundFirst = true;
			} catch (NumberFormatException e) {}
			for (Iterator<Document> i = kfdocs.iterator(); i.hasNext(); ) {
				doc = i.next();
				out.println("docs[" + curcount + "] = new doc(" + doc.getDocumentID() + ", true);");
				if (curDocumentID == doc.getDocumentID()) out.println("curDoc = " + curcount + ";");
				curcount++;
			}
			docURL = "imageKFW" + (accImage ? "Acc" : "") + ".pdf";
			if (!foundFirst) {
				id = doc.getDocumentID().toString();
				foundFirst = true;
			}
			kfdocs.clear();
		} // kfdocs
		if (accdocs != null && accdocs.size() > 0) {
			VoucherAttachment va = null;
			for (Iterator<VoucherAttachment> i = accdocs.iterator(); i.hasNext(); ) {
				va = i.next();
				out.println("docs[" + curcount + "] = new doc(" + va.getId() + ", false);");
				curcount++;
			}
			if (!foundFirst) { 
				id = va.getId();
				foundFirst = true;
			}
			accdocs.clear();
		} //accdocs
%>
	function disable() {
		if (curDoc == 0) document.getElementById("bBack").disabled = true;
		else document.getElementById("bBack").disabled = false;
		if (curDoc == docs.length - 2) document.getElementById("bForward").disabled = false;
		else if (curDoc == docs.length - 1) document.getElementById("bForward").disabled = true;
	}
	function backDoc() {
		curDoc--;
		getWorkflow();
		path = "image" + (docs[curDoc].kfw ? "KFW" : "") + (accImage ? "Acc" : "") + ".pdf";
		id = docs[curDoc].id;
		load();
		disable();
		document.getElementById("curDoc").innerHTML = (curDoc + 1) + "";
	}
	function forwardDoc() {
		curDoc++;
		getWorkflow();
		path = "image" + (docs[curDoc].kfw ? "KFW" : "") + (accImage ? "Acc" : "") + ".pdf";
		id = docs[curDoc].id;
		load();
		disable();
		document.getElementById("curDoc").innerHTML = (curDoc + 1) + "";
	}
	function openWorkflow() {
		var win = window.open("route.jsp?<%= request.getParameter("sc_id") != null ?
				"sc_id=" + request.getParameter("sc_id") + "&" : "" %>id=" + escape(routeId), "workflow", 
			"toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=400,height=400,left=25,top=25");
		win.focus();
		if (!win.opener) win.opener = this;
	}
	function getWorkflow() {
<%
		if (acc != null && acc.hasRouting()) {
			if (s.ok(Name.APPROVE_PAYMENT, Permission.READ)) {
%>
		if (accImage) {
		 	wbutton.style.display = "none";
			try {
				jsonrpc.home.getRoute(getWorkflowCallback, <%= at.getSiteId() %>, <%= voucherId %>);
			} catch (e) {
				alert(e);
			}
		}
<%		
			} // has appropriate security
		} // has routable accounting
%>
	}
	var routeId;
	function getWorkflowCallback(result, e) {
		if (result != null) {
			routeId = result;
			wbutton.style.display = "inline";
		}
	}
</script>
	<input class="bold" type="button" value="<" id="bBack" style="width: 15px;" onClick="backDoc();">
	<span id="curDoc">1</span> of <%= count %> 
	<input class="bold" type="button" id="bForward" value=">" style="width: 15px;" onClick="forwardDoc();">
	&nbsp; 
<%
	if (request.getParameter("sc_id") != null) {
		if (!sec.ok(Name.ADMIN, Permission.READ)) sql = "select sc_id, voucher_id from "
			+ "suspense_cache as sc join job on sc.job_id = job.job_id join job_permissions as jp on "
			+ "job.job_id = jp.job_id where protected = 0 and job.active = 'y' and jp.user_id = " 
			+ attr.getUserId() + " and jp.name = '" + Name.APPROVE_PAYMENT + "' and jp.val like '%" 
			+ Permission.READ + "%' and sc_id > " + request.getParameter("sc_id") 
			+ " order by costorder(job_num) desc, voucher_date limit 1";
		else sql = "select sc_id, voucher_id from suspense_cache as sc join "
			+ "job on sc.job_id = job.job_id "
			+ "where job.active = 'y' and sc_id > " + request.getParameter("sc_id") + " order by sc_id limit 1";
		rs = db.dbQuery(sql);
		if (rs.first()) {
%>	
	<input id="scButton" type="button" value="Next Invoice" 
		onclick="window.location='print.jsp?doc=imageAcc.pdf?id=<%= rs.getString("voucher_id") %>&sc_id=<%= rs.getString("sc_id") %>';"> &nbsp;
<%
		}
		rs.getStatement().close();
	}
%>
	<input type="button" value="Process" id="workButton" 
		style="display: none;" class="red bold" onclick="openWorkflow();"> &nbsp;
	<%= job != null ? "<span class=\"bold\">" + job + "</span> &nbsp;" : "" %>
<script>
	document.getElementById("curDoc").innerHTML = (curDoc + 1);
	disable();
	var wbutton = document.getElementById("workButton");
	getWorkflow();
</script>
<%
	} else { // count == 0
		/*
		 * There is NOT a single document to load, let's get out of here!
		 */
		response.sendRedirect("documentNotFound.html");
		return;
	}
} // not an image document
%>
	<label class="bold" for="encrypt">Encrypt</label> <input type="checkbox" id="encrypt" checked onclick="encryptDoc(this);">
	</div>
<img id="load" src="<%= request.getContextPath() %>/images/loading.gif">
<iframe style="visibility: hidden; display: block; width: 100%;" frameborder="0" id="print"
	src="../blank.html"></iframe>
<%
log.debug("final docURL: " + path + " id: " + id);
%>
<script>
	path = "<%= docURL %>";
	add = <%= add != null ? "'" + add + "'" : null %>;
	id = <%= id != null ? "'" + id + "'" : null %>;
	var print = document.getElementById("print");
	var encrypt = document.getElementById("encrypt");
	load(true);
	window.onresize = clear;
</script>
</body>
</html>
<%
db.disconnect();
%>
