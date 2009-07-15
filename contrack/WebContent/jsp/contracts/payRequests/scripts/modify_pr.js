var error = false;
function subtotal () {
	retention (true, false);
}
function subadjtotal () {
	retention (true, true);
}
function insertDue () {
	error = false;
	if (!fp) {
		var cur_adjvwctd = getNum("adjvwctd");
	} else {
		var cur_adjvwctd = getNum("con");
	}
	var cur_adjptd = getNum("adjptd");
	var adjret = getNum("adjret");
	var due = cur_adjvwctd - cur_adjptd - adjret;
	eval("f.paid").value = numFormat(due);
}
function retention (calcRet, adjOnly) {
	error = false;
	if (!fp) {
		var cur_vwctd = getNum("vwctd");
		var cur_adjvwctd = getNum("adjvwctd");
	} else {
		var cur_vwctd = getNum("con");
		var cur_adjvwctd = cur_vwctd;
	}
	var cur_ptd = getNum("ptd");
	var cur_adjptd = getNum("adjptd");
	var obj = document.getElementById("subtotal")
	obj.innerHTML = numFormat(cur_vwctd - cur_ptd);
	var obj = document.getElementById("adjsubtotal")
	obj.innerHTML = numFormat(cur_adjvwctd - cur_adjptd);
	var ret = getNum("ret");
	var adjret = getNum("adjret");
	var retRate = getNum("rate");
	if (calcRet) {
		if (!adjOnly) {
			ret = retRate * (cur_vwctd - cur_ptd);
			eval("f.ret").value = numFormat(ret);
		} else {
			adjret = retRate * (cur_adjvwctd - cur_adjptd);
			eval("f.adjret").value = numFormat(adjret);
		}
	}
	obj = document.getElementById("due");
	obj.innerHTML = numFormat(cur_vwctd - cur_ptd - ret);
	obj = document.getElementById("adjdue");
	obj.innerHTML = numFormat(cur_adjvwctd - cur_adjptd - adjret);
}
function numFormat(val) {
	var num = Math.round(val*100)/100;
	return num.toFixed(2);
}
function getNumByElement(obj) {
	var val = 0.00;
	obj.style.backgroundColor = "white";
	if(vFloat(obj)) val = obj.value - 0;
	else {
		obj.style.backgroundColor = "#FFFFCC";
		if (!error) alert("Please enter a valid decimal number!");
		error = true;
	}
	return val;
}
function getNum(obj_name) {
	var obj = eval("f." + obj_name);
	return getNumByElement(obj);
}
var voucherChange = false;
function checkVoucher(prID) {
	if (voucherChange) {
		try {
			var jsonrpc = new JSONRpcClient("../../JSON-RPC");
			if (jsonrpc.accounting.doCompaniesMatch(prID, f.account_id.value)) return true;
			else {
				if (window.confirm("WARNING!\n------------------------\n"
					+ "The company on the pay request does match the\n"
					+ "company on voucher! Continue?\n")) return true;
				else {
					var msgWin = window.open("voucherInfo.jsp?id=" + f.account_id.value);
					msgWin.focus();
					return false;
				}
			}
		} catch (e) {
			alert(e);
		}
	} else return true;
}