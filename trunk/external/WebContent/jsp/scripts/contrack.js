var win;
function openWin(loc) {
	win = window.open(loc,"EPEXT","directories=no,height=500,width=500,left=25,location=no,menubar=no,top=25,resizable=yes,status=no,scrollbars=yes");
	if (win.opener == null) opener = self;
	win.focus();
}
var className;
function rC (obj) {
	className = obj.className;
	obj.className = "yellow";
}
function rCl (obj) {
	obj.className = className;
}
	
function printDoc() {
	win = window.open("../utils/print.jsp?doc=" + printName, "print");
	win.focus();
	return false;
}
function submitForm() {
	if (checkForm(m)) {
		m.submit();
		return true;
	}
  		else return false;
  	}
window.onunload = closeWindows;
function closeWindows() {
	if (win) win.close();
}
window.setInterval(expire, 30*60000);
function expire() {
	alert("Your session has been inactive for 30 minutes.\nYou must logon to continue.");
	location = "../../index.jsp?logoff=true";
}