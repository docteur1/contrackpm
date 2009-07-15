function rC (obj) {
	obj.className = "blue";
}
function rCl (obj) {
	obj.className = "white";
}
function editCode(id) {
	parent.edit.document.location = "editCode.jsp?id=" + id;
	if (navigator.appName == "Microsoft Internet Explorer") parent.document.getElementById("fs").rows = "41,47,*,16";
	else parent.document.getElementById("fs").rows = "41,42,*,16";
}
function openWin(loc, w, h) {
	msgWindow=open("","newWindow","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=" + w + ",height=" + h + ",left=25,top=25");
	msgWindow.document.location.href = loc;
	if (msgWindow.opener == null) msgWindow.opener = self;
	msgWindow.focus();
}
con_url = "contracts.jsp?id=";
del_url = "phaseDetail.jsp?id=";
v_url = "voucherDetail.jsp?id=";
co_url = "cr.jsp?id=";