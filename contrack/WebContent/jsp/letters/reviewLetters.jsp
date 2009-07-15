<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="com.sinkluge.security.Security" %>
<%@page import="com.sinkluge.database.Database" %>
<jsp:useBean id="sec" scope="session" class="com.sinkluge.security.Security" />
<jsp:useBean id="attr" scope="session" class="com.sinkluge.attributes.Attributes" />
<%
if (!sec.ok(Security.LETTERS, Security.READ)) response.sendRedirect("../accessDenied.html");
boolean sd = sec.ok(Security.LETTERS, Security.DELETE);
%>
<html>
	<head>
		<link rel="stylesheet" href="../stylesheets/v2.css" type="text/css">
		<%= com.sinkluge.utilities.Widgets.fontSizeStyle(attr) %>
		<script src="../utils/table.js"></script>
		<script type="text/javascript">
			function newWin(loc) {
				msgWindow=open('','letter','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=515,left=25,top=25');
				msgWindow.location.href = loc;
				if (msgWindow.opener == null) msgWindow.opener = self;
				msgWindow.focus()
			}
			function delLetter(id){
				if(confirm("Delete this letter?")) location = "deleteLetter.jsp?letterID=" + id;
			}
	</script>
	</head>
	<body>
		<div class="title">Letters</div><hr/>
		<div class="link" onclick="newWin('newLetterFrameset.jsp');">New</div>
		<hr/>
<%
SimpleDateFormat formatter = new SimpleDateFormat("d MMM yy");
String query = "select * from letters join users on user_id = users.id "
	+ "where letters.job_id = " + attr.getJobId() + " order by date_created desc";
Database db = new Database();
ResultSet rs = db.dbQuery(query);
int letter_id=0;
String subject = "";
String company = "";
%>
<table cellspacing="0" cellpadding="3" id="tableHead">
<tr>
<%
if (sd) out.print("<td class=\"left head nosort\">Delete</td>");
%>
				<td class="head nosort">Edit</td>
				<td class="head">Date</td>
				<td class="head">Company</td>
				<td class="head">From</td>
				<td class="head">Subject</td>
				<td class="right head">ID</td>
			</tr>
</table>
<div class="table" id="tableDiv">
<table cellspacing="0" cellpadding="3" id="tableMain">
<%
ResultSet t = null;
boolean color = true;
while (rs.next()){
	color = !color;
	company = "None";
	letter_id=rs.getInt("letter_id");
	subject = rs.getString("subject");
	if (subject != null && subject.length()>40) subject = subject.substring(0,40) + "...";
	else {
		t = db.dbQuery("select count(*) from letter_contacts where letter_id = " + letter_id);
		if (t.next()) {
			if (t.getInt(1) > 1) company = "Many";
			else {
				t = db.dbQuery("select company_name from letter_contacts join company on company.company_id = "
						+ "letter_contacts.company_id left join contacts using(contact_id) where "
						+ "letter_contacts.letter_id = " +letter_id);
				if (t.next()) company = t.getString(1);
			}
		}
	}
%>
<tr onMouseOver="b(this);" onMouseOut="n(this);" <% if (color) out.print("class=\"gray\""); %>>
<%
	if (sd) out.print("<td class=\"left\"><a href=\"javascript: delLetter(" + letter_id + ");\">Delete</a></td>");
%>
		<td class="right"><a href="javascript: newWin('modifyLetterFrameset.jsp?letter_id=<%= letter_id %>');">Edit</a></td>
		<td class="it aright"><% try {out.print(formatter.format(rs.getDate("date_created")));}catch(Exception e){out.print("----");} %></td>
		<td class="it"><%= company %></td>
		<td class="it"><%= rs.getString("last_name") + ", " + rs.getString("first_name") %></td>
		<td class="it"><%= subject%></td>
		<td class="right"><%= com.sinkluge.utilities.Widgets.logLinkWithId(rs.getString("letter_id"),
				com.sinkluge.Type.LETTER, request) %></td>
	</tr>
	<%
}
if (t != null) t.close();
rs.close();
db.disconnect();
%>
</table>
</div>
	</body>
</html>
