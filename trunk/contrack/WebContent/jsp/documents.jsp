<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@page import="com.sinkluge.security.Security"%>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="stylesheets/v2.css" type="text/css">
<%= com.sinkluge.utilities.Widgets.fontSizeStyle(session) %>
</head>
<body>
<div class="title">Documents</div><hr>
<%= sec.ok(Security.LETTERS, Security.READ) ? "<div class=\"link\" "
		+ "onclick=\"window.location='letters/reviewLetters.jsp';\">Letters</div> &nbsp; " : "" %>
<div class="link" onclick="window.location='transmittals/?my=t';">My Transmittals</div> &nbsp;
<%= sec.ok(Security.RFI, Security.READ) ? "<div class=\"link\" "
		+ "onclick=\"window.location='rfis/reviewRFIs.jsp';\">RFIs</div> &nbsp; " : "" %>
<%= sec.ok(Security.SUBMITTALS, Security.READ) ? "<div class=\"link\" "
		+ "onclick=\"window.location='submittals/reviewSubmittals.jsp';\">Submittals</div> &nbsp;" : "" %>
<%= sec.ok(Security.TRANSMITTALS, Security.READ) ? "<div class=\"link\" "
		+ "onclick=\"window.location='transmittals/';\">Transmittals</div>" : "" %>
<hr>
</body>
</html>