var error = false;
function subtotal () {
	error = false;
	var cur_vwctd = getNum("vwctd");
	var cur_con = getNum("con");
	if (cur_con < cur_vwctd && !error) {
		error = true;
		eval("m.vwctd").style.backgroundColor = "#FFFFCC";
		alert("Error!\n\nValue of Work cannot exceed\nAdjusted Contract Amount.");
		return;
	}
	var cur_ptd = getNum("ptd");
	var obj = document.getElementById("subtotal")
	obj.innerHTML = numFormat(cur_vwctd - cur_ptd);
	var retRate = getNum("rate");
	ret = retRate * (cur_vwctd - cur_ptd);
	eval("m.ret").value = ret;
	var obj = document.getElementById("dret");
	obj.innerHTML = numFormat(ret);
	obj = document.getElementById("due");
	obj.innerHTML = numFormat(cur_vwctd - cur_ptd - ret);
}
function numFormat(val) {
	var num = Math.round(val*100)/100;
	var str = num.toFixed(2) + "";
	return putCommas(str);
}
function putCommas(str) {
	var comma = str.indexOf(",");
	// if there is no comma, go from decimal point
	if (comma == -1) comma = str.indexOf(".");
	// if there is no decimal point, go from end of number
	if (comma == -1) comma = str.length();
	if (comma > 3) {
		str = str.substring(0, comma - 3) + "," + str.substring(comma - 3);
		str = putCommas(str);
	} 
	return str;
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
	var obj = eval("m." + obj_name);
	return getNumByElement(obj);
}