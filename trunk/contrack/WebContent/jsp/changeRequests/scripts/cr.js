var jsonrpc = new JSONRpcClient("../JSON-RPC");
function edit(field) {
	openWin("textarea.jsp?id=" + field, 600, 500);
}
function editCD(id) {
	openWin("crdFrameset.jsp?id=" + id, 700, 600);
}
function openWin(loc, x, y) {
	var msgWindow = open(loc, "crEdit", "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,"
		+ "resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
	if (msgWindow.opener == null) msgWindow.opener = self;
	msgWindow.focus();
}
function spell() {
	spellCheck(cr);
}
var changed = false;
function fChanged(e) {
	changed = true;
}
function doUnload() {
	if(changed) return "You have unsaved work on this page!";
}
window.onbeforeunload = doUnload;
var detailCount = 0;
var costList = null;
function addItem() {
	if (costList == null) jsonrpc.list.getCodesAndContracts(addItem2);
	else addItem2(null, null);
}
function addItem2(result, e) {
	if (result != null) costList = result;
	if (costList) {
		var table = document.getElementById("detail");
		var row = table.insertRow(table.rows.length);
		row.id = "row" + table.rows.length;
		var rowId = row.id;
		var cell = row.insertCell(0);
		cell.rowSpan = 2;
		var count = document.getElementById("count").value * 1;
		count++;
		detailCount++;
		document.getElementById("count").value = count;
		cell.className = "it";
		var temp = document.createElement("div");
		temp.className = "link";
		temp.onclick = removeRow;
		temp.innerHTML = "Delete";
		cell.appendChild(temp);
		cell = row.insertCell(1);
		cell.rowSpan = 2;
		cell.className = "right";
		cell.appendChild(document.createTextNode(" "));
		cell = row.insertCell(2);
		cell.rowSpan = 2;
		cell.className = "right";
		cell.appendChild(document.createTextNode(" "));
		cell = row.insertCell(3);
		cell.className = "inputleft"
		cell.colSpan = "5";
		temp = document.createElement("select");
		temp.name = "sc_id" + count;
		temp.onchange = fChanged;
		var temp2;
		var use;
		for (var i = 0; i < costList.length; i++) {
			use = true;
			for (var j = 0; j < idUsed.length; j++) {
				use = !(idUsed[j] == costList[i].id) && use;
			}
			if (use) {
				temp2 = document.createElement("option");
				temp2.value = costList[i].id;
				temp2.innerHTML = costList[i].text;
				temp.appendChild(temp2);
				if (temp2.value.indexOf("n") != -1) temp2.style.fontWeight = "bold";
			}
		}
		cell.appendChild(temp);
		row = table.insertRow(table.rows.length);
		row.id = rowId + "2";
		cell = row.insertCell(0);
		cell.className = "inputleft";
		temp = document.createElement("input");
		temp.type = "text";
		temp.name = "work_description" + count;
		temp.required = true;
		temp.eName = "Detail Description";
		temp.onchange = fChanged;
		cell.appendChild(temp);
		cell = row.insertCell(1);
		cell.className = "inputright";
		temp = document.createElement("input");
		temp.type = "text";
		temp.name = "amount" + count;
		temp.id = "amount" + count;
		temp.required = true;
		temp.required = true;
		temp.isFloat = true;
		temp.value = "0.00";
		temp.eName = "Detail Amount";
		temp.onchange = updateFees;
		temp.size = 6;
		temp.className = "aright";
		cell.appendChild(temp);
		cell = row.insertCell(2);
		cell.className = "inputright";
		temp = document.createElement("input");
		temp.type = "text";
		temp.name = "fee" + count;
		temp.id = "fee" + count;
		temp.required = true;
		temp.value = "0.00";
		temp.eName = "Detail Fee";
		temp.isFloat = true;
		temp.size = 6;
		temp.className = "aright";
		temp.onchange = updateFees;
		cell.appendChild(temp);
		cell.appendChild(temp);
		cell = row.insertCell(3);
		cell.className = "inputright";
		temp = document.createElement("input");
		temp.type = "text";
		temp.name = "bonds" + count;
		temp.id = "bonds" + count;
		temp.isFloat = true;
		temp.value = "0.00";
		temp.eName = "Detail Bond";
		temp.size = 6;
		temp.className = "aright";
		temp.onchange = updateFees;
		cell.appendChild(temp);
		cell = row.insertCell(4);
		cell.className = "aright";
		cell.appendChild(document.createTextNode(" "));
		document.getElementById("tableDiv").style.overflowX = "scroll";
		window.scrollTo(0, row.offsetTop);
	}
}
function getTarget(e) {
	var obj;
	if (e == null) obj = window.event.srcElement;
	else obj = e.target;
	return obj;
}
function removeRow2(obj) {
	if (window.confirm("Remove this detail (and associated Change Authorization)?")) {
		detailCount--;
		changed = true;
		while (obj.tagName != "TR") obj = obj.parentNode;
		var row2 = document.getElementById(obj.id + "2");
		obj.parentNode.removeChild(row2);
		obj.parentNode.removeChild(obj);
		document.getElementById("tableDiv").style.overflowX = "auto";
	}
}
function removeRow(e) {
	obj = getTarget(e);
	removeRow2(obj);
}
function updateFees(e) {
	changed = true;
	var fees = 0;
	var total = 0;
	var bonds = 0;
	var elem;
	for (var i = 0; i < cr.length; i++) {
		elem = cr.elements[i];
		if (elem.name) {
			if (elem.name.indexOf("amount") != -1) total += parseNum(elem);
			else if (elem.name.indexOf("fee") != -1) fees += parseNum(elem);
			else if (elem.name.indexOf("bond") != -1) bonds += parseNum(elem);
		}
	}
	document.getElementById("total").innerHTML = formatNum(total + fees + bonds);
	document.getElementById("fees").innerHTML = formatNum(fees);
	document.getElementById("bonds").innerHTML = formatNum(bonds);
}
function parseNum(elem) {
	var val;
	try {
		val = elem.value;
		if (val == null || val == "" || val.match(/^\s+$/)) val = "0";
		var c;
		for (var i = 0; i < val.length; i++) {
			c = val.charAt(i);
			if (c == ",") val = val.substring(0,i) + val.substring(i+1);
		}
		val = parseFloat(val);
	} catch (e) {
		val = 0;
	}
	elem.value = formatNum(val);
	return val;
}
function formatNum(num) {
	var nStr = num.toFixed(2);
	nStr += "";
	x = nStr.split(".");
	x1 = x[0];
	x2 = x.length > 1 ? "." + x[1] : "";
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + "," + '$2');
	}
	return x1 + x2;
}
function statusChange(e) {
	changed = true;
	if ("Approved" == cr.status.value) {
		cr.approved_date.required = true;
		document.getElementById("addLink").style.display = "none";
	} else {
		parent.left.document.getElementById("save").disabled = false;
		document.getElementById("addLink").style.display = "block";
	}
}
var idUsed = new Array();