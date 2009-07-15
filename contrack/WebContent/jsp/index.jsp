<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.sql.ResultSet, org.apache.log4j.Logger"%>
<%@page import="com.sinkluge.fax.FaxStatus, com.sinkluge.security.Name"%>
<%@page import="com.sinkluge.UserData, com.sinkluge.User, com.sinkluge.Group,
	com.sinkluge.database.Database"%>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="JSONRPCBridge" scope="session"
     class="org.jabsorb.JSONRPCBridge" />

<%@page import="com.sinkluge.Group"%><html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="SHORTCUT ICON" href="../images/ct64.ico">
	<title><%= in.testMode ? "[TEST] " : "" %>Contrack - </title>
	<link rel="stylesheet" href="stylesheets/v2.css" type="text/css">
	<link rel="stylesheet" href="stylesheets/index.css" type="text/css">
	<script src="utils/jsonrpc.js"></script>
	<script>
<%
Logger log = Logger.getLogger(this.getClass());
try {
JSONRPCBridge.registerClass("home", com.sinkluge.JSON.Home.class); 
int projectId = attr.getJobId();
Database db = new Database();
if (attr.getUserName() == null) {
	log.debug("User not initialized");
	Cookie[] cookies = request.getCookies();
	if (cookies != null) {
		for (Cookie cookie : cookies){
			try {
				if (cookie.getName().equals("lpid")) 
					projectId = Integer.parseInt(cookie.getValue());
			} catch (NumberFormatException e) {}
		}
	}
	String username = request.getRemoteUser();
	Cookie userCookie = new Cookie("EPUSER", username);
	userCookie.setMaxAge(60*60*24*365);
	userCookie.setPath(request.getContextPath());
	response.addCookie(userCookie);
	String query;
	db.connect();
	User user = User.getUserByUsername(username);
	if (user == null) {
		log.debug("No user information found");
		// The user hasn't been sync'd from LDAP yet. this might take awhile.
		Group group = Group.getInstance(in);
		group.run();
		user = User.getUserByUsername(username);
	}
	if (log.isDebugEnabled()) log.debug(attr == null ? "attr is null" : "attr is not null");
	attr.setFontSize(user.getFontSize());
	attr.setFullName(user.getFullName());
	attr.setUserName(username.toLowerCase());
	attr.setUserId(user.getId());
	attr.setEmail(user.getEmail());
	attr.setInfo(request.getRemoteHost());
	attr.setBrowser(request.getHeader("user-agent"));
	// Setup the fax status stuff to track faxes sent before the session was created.
	String sql = "select count(*) from fax_log where (status is null or status like 'Requeued%') "
		+ "and user_id = '" + user.getId() + "'";
	ResultSet rs = db.dbQuery(sql);
	FaxStatus fs = null;
	if (rs.first() && rs.getInt(1) > 0) {
		fs = new FaxStatus("Sending");
		fs.setQueue(rs.getInt(1));
	}
	rs.getStatement().close();
	sql = "select fax_log_id from fax_log where viewed = 0 and status like 'Fail%' "
		+ "and user_id = '" + attr.getUserName() + "' limit 1";
	rs = db.dbQuery(sql);
	if (rs.isBeforeFirst()) {
		if (fs == null) fs = new FaxStatus("Error");
		else fs.setMessage("Error");
		fs.setHasError(true);
	}
	rs.getStatement().close();
	if (fs != null) {
		log.debug("Setting Fax Status with: " + fs.getMessage());
		session.setAttribute("fax_status", fs);
	}
	boolean root = false;
	for (int i = 0; i < in.admin_groups.length; i++) root = root || request.isUserInRole(in.admin_groups[i]);
	sec.isAdmin(root);
} // End if session not initialized
%>
		var path = "<%= request.getContextPath() %>";
		var projectId = <%= projectId %>;
		var testMode = <%= in.testMode %>;
	</script>
	<script src="home.js"></script>
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
</head>
<body style="margin: 0px;">
<div id="doc1" style="position: absolute; top: 0; left: 0px; opacity: 0.5; filter: alpha(opacity=50);
	background-color: black; width: 100%; height: 100%; z-index: 50; color: white;
	vertical-align: middle; text-align: center; display: none;">
	</div>
<div id="doc2" style="position: absolute; text-align: center; background-color: white; z-index: 51;
	width: 40%; top: 35%; left: 30%; padding: 20px; display: none;">
	<div id="doc3" class="title"></div><hr>
	<div id="doc4" style="display: none; margin-bottom: 10px;"></div>
	<div id="doc8" style="display: none; margin-bottom: 10px;">Your session is set to expire in 
		<span id="timeToExpire"></span>.</div>
	<div id="doc5" style="display: none;"><input id="doc7" type="button" value="Return to Session"
		onclick="clearCountdown(); hideMessage"/>
		&nbsp; <input type="button" value="Sign Out" 
		onclick="kick('User Requested due to Browser Timeout');"/></div>
	<div id="doc6" style="display: none;"><input id="doc9" type="button" value="OK"
		onclick="hideMessage();"/></div>
	</div>
<div id="topBar" style="background-color: #C0C0C0; border-bottom: 2px solid black; padding: 3px;">
<div id="leftItem" style="display: inline">
<div style="display: inline;">
	<select id="projectList" style="width: 200px;" onchange="changeProjectId();"></select> &nbsp;
	<select id="limitList" onchange="loadProjectList();">
		<option value="0">My Projects</option>
		<option value="1">Active Projects</option>
		<option value="2">All Projects</option>
	</select>
</div>
<div class="menuHead" onmouseover="openMenu(this, 'main');" onclick="show('main.jsp', true);">Main</div>
<div class="menuHead" onmouseover="openMenu(this, 'contacts');" 
	onclick="show('contacts/reviewCompanies.jsp', true);">Contacts</div>
<div class="menuHead" onmouseover="openMenu(this, 'pr');" id="<%= Name.PROJECT%>" 
	onclick="show('projects/reviewJobInfo.jsp', true);">Project</div>
<div class="menuHead" onmouseover="openMenu(this, 'ct');" id="<%= Name.COSTS %>" 
	onclick="show('costCodes/codes.jsp', true);">Costs</div>
<div class="menuHead" onmouseover="openMenu(this, 'sc');" id="<%= Name.SUBCONTRACTS %>" 
	onclick="show('contracts/reviewContracts.jsp', true);">Subcontracts</div>
<div class="menuHead" onmouseover="openMenu(this, 'docs');"
	onclick="show('documents.jsp', true);">Documents</div>
<div class="red bold" id="faxError" style="cursor: pointer; margin-left: 3px; display: none;"
	onclick="show('utils/faxLog.jsp', true);"></div>
</div>
<div id="rightItem" style="position: absolute; right: 5px; top: 5px; z-index: 1">
	<div id="companyName" style="display: inline;"></div> &nbsp;
	<div class="link bold" onclick="kick('User Requested');"
		>Sign Off (<%= attr.getUserName() %>)</div>
</div>
</div>
<div class="menuBody" id="main">
	<div class="menuItem menuHidden" id="<%= Name.ADMIN %>" 
		onclick="show('admin/superAdmin.jsp', true);">Administration</div>
<%
if (in.hasFax) {
%>
	<div class="menuItem" onclick="show('utils/faxLog.jsp', 'main');">Fax Log</div>
<%
}
%>
	<div class="menuItem" onclick="show('admin/personalAdmin.jsp', 'main');">Settings</div>
	<div class="menuItem" onclick="show('about.jsp', 'main');">About</div>
</div>
<div class="menuBody" id="contacts">
	<div class="menuItem menuHidden" id="<%= Name.PROJECT %>" 
		onclick="pop('projects/jobContacts.jsp', 600, 490, true);">Project Contacts</div>
	<div class="menuItem" onclick="show('contacts/search.html', true);">Search</div>
	<div class="menuItem" onclick="show('contacts/reviewStrikes.jsp', true);">Strike Report</div>
</div>
<div class="menuBody" id="pr">
	<div class="menuItem menuHidden" id="<%= Name.SUBCONTRACTS %>" 
		onclick="pop('projects/bidDocuments.jsp', 600, 490, true);">Bid Documents</div>
	<div class="menuItem menuHidden" id="<%= Name.PERMISSIONS %>" 
		onclick="show('projects/permissions.jsp', true);">Permissions</div>
	<div class="menuItem menuHidden" id="<%= Name.PROJECT %>"
		onclick="show('projects/jobTeam.jsp', true);">Team</div>
</div>
<div class="menuBody" id="ct">
	<div class="menuItem menuHidden" id="<%= Name.CHANGES %>" 
		onclick="show('changeRequests/', true);">Change Requests</div>
	<div class="menuItem menuHidden" id="<%= Name.CHANGES %>" 
		onclick="show('changeRequests/cos.jsp', true);">Change Orders</div>
	<div class="menuItem menuHidden" id="<%= Name.COSTS %>" 
		onclick="show('projects/divisions.jsp', true);">Divisions</div>
</div>
<div class="menuBody" id="sc">
	<div class="menuItem menuHidden" id="<%= Name.CHANGES %>" 
		onclick="show('changeRequests/cas.jsp', true);">Change Authorizations</div>
	<div class="menuItem menuHidden" id="<%= Name.SUBCONTRACTS %>"
		onclick="show('contracts/closeout.jsp', true);">Closeout</div>
	<div class="menuItem menuHidden" id="<%= Name.SUBCONTRACTS %>"
		onclick="show('contracts/lienWaivers.jsp', true);">Lien Waivers</div>
	<div class="menuItem menuHidden" id="<%= Name.SUBCONTRACTS %>"
		onclick="show('contracts/payRequests/reviewOwnerPayRequests.jsp', true);">Pay Requests</div>
</div>
<div class="menuBody" id="docs">
	<div class="menuItem menuHidden" id="<%= Name.LETTERS %>"
		onclick="show('letters/reviewLetters.jsp', true);">Letters</div>
	<div class="menuItem" onclick="show('transmittals/?my=t', true);">My Transmittals</div>
	<div class="menuItem menuHidden" id="<%= Name.RFIS %>"
		onclick="show('rfis/reviewRFIs.jsp', true);">RFIs</div>
	<div class="menuItem menuHidden" id="<%= Name.SUBMITTALS %>"
		onclick="show('submittals/reviewSubmittals.jsp', true);">Submittals</div>
	<div class="menuItem menuHidden" id="<%= Name.TRANSMITTALS %>"
		onclick="show('transmittals/', true);">Transmittals</div>
</div>
<iframe name="mainFrame" style="display: block; width: 100%;" frameborder="0" id="frame" 
	src="blank.html"></iframe>
<script>
	fitFrame();
	window.onresize = fitFrame;
	<%= request.getParameter("loc") != null ? "nextLoc = \"" + request.getParameter("loc") + "\";" : "" %>
	loadProjectList(true);
	poll();
<%
db.disconnect();
} catch (Exception e) {
	log.error("Error on jsp/index.jsp", e);
}
%>
</script>
</body>
</html>