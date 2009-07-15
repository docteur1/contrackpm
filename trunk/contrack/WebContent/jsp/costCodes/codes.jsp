<%@page session="true"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.sinkluge.security.Security" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.ACCOUNT, Security.READ)) response.sendRedirect("../accessDenied.html");
boolean add = request.getParameter("add") != null;
String ccid = request.getParameter("id");
String div = request.getParameter("div");
if (div == null) div = attr.getDiv();
if (ccid != null) ccid = "#" + ccid;
else ccid = "";
if (div != null) div = "div=" + div;
%>
<html>
<head>
</head>
<frameset rows="41,0,*,16" frameborder="0" framespacing="0" border="0" id="fs">
	<frame src="codesTop.jsp?<%= div %><% if (add) out.print("&add=true"); %>" name="header" scrolling="no">
	<frame src="blank.html" name="edit" scrolling="no">
   <frame src="codesMain.jsp?<%= div + ccid %>" name="main">
   <frame src="codesBottom.jsp" name="footer" scrolling="no">
</frameset>
</html>