function printSel(obj) {
	if (obj.value != null && obj.value != "") {
		//var oWin = window.top;
		//if (oWin.opener != null) oWin = oWin.opener;
		var msgWin = window.open("", "print");
		var url = "../utils/print.jsp?doc=" + obj.value;
		msgWin.location = url;
		msgWin.focus();
	}
	obj.selectedIndex = 0;
}
