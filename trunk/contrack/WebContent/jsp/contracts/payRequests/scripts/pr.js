var error = false;
function subtotal() {
	retention(true);
}
function retention(calcRet) {
	error = false;
	if (!fp) var cur_vwctd = getNum("vwctd");
	else var cur_vwctd = getNum("con");
	var cur_con = getNum("con");
	if (cur_con < cur_vwctd) {
		error = true;
		alert("Value of Work cannot be greater than Adjusted Contract.");
	}
	var cur_ptd = getNum("ptd");
	var obj = document.getElementById("subtotal")
	obj.innerHTML = numFormat(cur_vwctd - cur_ptd);
	var ret = getNum("ret");
	var retRate = getNum("rate");
	if (calcRet) {
		ret = retRate * (cur_vwctd - cur_ptd);
		eval("f.ret").value = numFormat(ret);
	}
	obj = document.getElementById("due");
	obj.innerHTML = numFormat(cur_vwctd - cur_ptd - ret);
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