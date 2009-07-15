<%@page contentType="text/html"%>
<%@page session="true"%>
<%@page import="java.sql.Statement, java.sql.ResultSet"%>
<jsp:useBean id="db" scope="session" class="com.sinkluge.database.Database" />
<jsp:include page="../workspace.jsp">
	<jsp:param name="saveDisable" value="false"/>
	<jsp:param name="printDisable" value="true"/>
	<jsp:param name="action" value="newPR2.jsp"/>
	</jsp:include>
<font size="+1">New Pay Request</font><hr>
<a href="../manage/index.jsp">Home</a> &gt; <a href="index.jsp">Pay Requests</a> &gt; New Pay Request<hr>
&nbsp;<br>
<%
String query = "select opr_id, period from owner_pay_requests where job_id = " + db.job_id + " and (locked = 0 or locked is null) order by period desc";
db.connect();
Statement stmt = db.getStatement();
Statement stmt_sub = db.getStatement();
Statement stmt_ret = db.getStatement();
ResultSet rs = stmt.executeQuery(query);
ResultSet rs_sub = null, rs_ret = null;
int count = 0;
if (!rs.isBeforeFirst()) {
%>
<b>ERROR!</b><p>
No valid pay period was found. Unable to create a new pay request.
<%
} else {
	String output = "<b>Select a pay period</b> &nbsp; <select name=\"opr_id\">";
	int opr_id;
	String period;
	query = "select pr_id from pay_requests, owner_pay_requests where pay_requests.opr_id = " +
		"owner_pay_requests.opr_id and pay_requests.contract_id = " + db.contract_id + " and " +
		"final = 1";
	rs_ret = stmt_ret.executeQuery(query);
	boolean fp = rs_ret.isBeforeFirst();
	if (rs_ret != null) rs_ret.close();
	rs_ret = null;
	while (rs.next()) {
		opr_id = rs.getInt("opr_id");
		query = "select pr_id from pay_requests where opr_id = " + opr_id + " and contract_id = " + db.contract_id;
		rs_sub = stmt_sub.executeQuery(query);
		if (!rs_sub.next()) {
			period = rs.getString("period");
			if (!fp && !period.equals("Retention")) {
				output += "<option value=\"" + rs.getString(1) + "\">" + period + "</option>";
				count++;
			}
		}
		if (rs_sub != null) rs_sub.close();
		rs_sub = null;
	}
	output += "</select> &nbsp; <input type=\"submit\" value=\"Next\">";
	if (count != 0) {
		out.print(output);
%>
	<br><b>Request Final Payment?</b> <input type="checkbox" name="final" value="y">
<%
	}
	else out.print ("<b>ERROR!</b><p>No valid pay period was found. Unable to create a new pay request.");
}
if (stmt_ret != null) stmt_ret.close();
stmt_ret = null;
if (stmt_sub != null) stmt_sub.close();
stmt_sub = null;
if (rs != null) rs.close();
rs = null;
if (stmt != null) stmt.close();
stmt = null;
db.disconnect();
%>
<script language="javascript">
	var m = document.main;
<% 
if (count == 0) out.print("m.action = \"\";");
%>
</script>
</td>
</tr>
</table>
</form>
</body>
</html>