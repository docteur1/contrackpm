<%@page session="true"%>
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<jsp:useBean id="in" scope="application" class="com.sinkluge.Info" />
<html>
<head>
	<link rel="stylesheet" href="stylesheets/v2.css" type="text/css">
	<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
</head>
<body>
<div class="title">About</div><hr>
Report bug / Request Feature: <a href="http://code.google.com/p/contrackpm/issues/list" target="issuetracker">Issue Tracker</a><br>
<br/>
Contrack - Project Management Build: <%= in.build %><br>
Accessed From: <%= request.getRemoteHost() %><br>
</body>
</html>
