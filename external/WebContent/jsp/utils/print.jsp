<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="stylesheet" type="text/css" href="../stylesheets/style.css">
	<title>Loading Document</title>
</head>
<body>
<body>
<font size="+1">Loading Document<span id="wait"></span></font>
<script>
function wait(wait) {
	w = document.getElementById("wait").innerHTML += " .";
}
window.setInterval(wait, 1000);
window.location = "../reports/<%=request.getParameter("doc")%>";
</script>
</body>
</html>