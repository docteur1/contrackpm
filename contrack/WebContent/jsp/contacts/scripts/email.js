var cls;
function n(e) {
	var obj = window.event ? window.event.srcElement : e.target;
	while (obj.tagName != "TR") obj = obj.parentNode;
	obj.className = cls;
}
function b(e) {
	var obj = window.event ? window.event.srcElement : e.target;
	while (obj.tagName != "TR") obj = obj.parentNode;
	cls = obj.className;
	obj.className = "yellow";
}
function nn(id) {
	id.className = cls;
}
function bb(id) {
	cls = id.className;
	id.className = "yellow";
}
function searchFormSubmit() {
	try {
		jsonrpc.search.searchEmail(searchCallBack, document.getElementById("search").value);
	} catch (e) {
		alert(e);
	}
	return false;
}
function email() {
	var table = document.getElementById("emailTable");
	if (!table.inited) alert("No contacts selected!");
	else {
		var emails = "";
		for (var i = 1; i < table.rows.length; i++) {
			if (emails != "") emails += ";";
			emails += table.rows[i].cells[1].innerHTML;
		}
		emails = emails.replace("&lt;","<","g");
		emails = emails.replace("&gt;",">","g");
		window.location = "mailto: " + emails;
	}
}
function searchCallBack(result, e) {
	var table = document.getElementById("searchTable");
	var row, cell, chk, i, numRows = table.rows.length;
	for (i = 1; i < numRows; i++) table.deleteRow(table.rows.length - 1);
	if (result.length != 0) {
		for (i = 0; i < result.length; i++) {
			row = table.insertRow(i+1);
			if (i % 2 == 1) row.className = "gray";
			row.onmouseover = b;
			row.onmouseout = n;
			cell = row.insertCell(0);
			cell.className = "left input";
			chk = document.createElement("input");
			chk.type = "checkbox";
			chk.value = result[i].name + " <" + result[i].email + ">";
			chk.manage = "search";
			cell.appendChild(chk);
			cell = row.insertCell(1);
			cell.className = "right";
			cell.style.whiteSpace = "nowrap";
			cell.title = result[i].companyName;
			chk = document.createTextNode(result[i].name + " <" + result[i].email + ">");
			cell.appendChild(chk);
		}
	} else {
		row = table.insertRow(1);
		cell = row.insertCell(0);
		cell.colSpan = "2";
		cell.className = "left right bold acenter";
		cell.appendChild(document.createTextNode("No matches found!"));
	}
	table.style.display = "inline";
}
function add(txt) {
	var chks = document.getElementsByTagName("input");
	for (var i  = 0; i < chks.length; i++) {
		if (chks[i].type == "checkbox") {
			if (txt == chks[i].manage && chks[i].checked) addEmail(chks[i].value);
			else if (!txt && !chks[i].manage && chks[i].checked) addEmail(chks[i].value);
		}
	}
	var table = document.getElementById("emailTable");
	for (var i = 1; i < table.rows.length; i++) {
		if (i % 2 == 0) table.rows[i].className = "gray";
		else table.rows[i].className = "";
	}
}
var curId = 0;
function addEmail(txt) {
	var table = document.getElementById("emailTable");
	if (!table.inited) {
		table.deleteRow(table.rows.length - 1);//Remove the "No emails" table row
		table.inited = true;
	}
	var found = false;
	for (var i = 1; i < table.rows.length; i++) {
		var txt2 = txt;
		txt2 = txt2.replace("<","&lt;","g");
		txt2 = txt2.replace(">","&gt;","g");
		found = found || table.rows[i].cells[1].innerHTML == txt2;
	}
	if (!found) {
		var row = table.insertRow(table.rows.length);
		row.onmouseover = b;
		row.onmouseout = n;
		cell = row.insertCell(0);
		cell.className = "left";
		chk = document.createElement("a");
		chk.href = "javascript: remove('" + txt + "');";
		chk.appendChild(document.createTextNode("Remove"));
		cell.appendChild(chk);
		cell = row.insertCell(1);
		cell.className = "right";
		cell.style.whiteSpace = "nowrap";
		chk = document.createTextNode(txt);
		cell.appendChild(chk);
	}
}
function removeAll() {
	var table = document.getElementById("emailTable");
	var i, numRows = table.rows.length
	if (table.inited) { 
		for (i = 1; i < numRows; i++) table.deleteRow(table.rows.length - 1);
		var row = table.insertRow(1);
		cell = row.insertCell(0);
		cell.className = "left right bold acenter";
		cell.colSpan = "2";
		cell.appendChild(document.createTextNode("No emails"));
		table.inited = false;
	}
}
function remove(txt) {
	var table = document.getElementById("emailTable");
	var found = false;
	txt = txt.replace("<","&lt;","g");
	txt = txt.replace(">","&gt;","g");		
	for (var i = 1; i < table.rows.length; i++) {	
		found = found || table.rows[i].cells[1].innerHTML == txt;
		if (found) break;
	}
	table.deleteRow(i);
	for (var i = 1; i < table.rows.length; i++) {
		if (i % 2 == 0) table.rows[i].className = "gray";
		else table.rows[i].className = "";
	}
	if (table.rows.length == 1) {
		var row = table.insertRow(1);
		cell = row.insertCell(0);
		cell.className = "left right bold acenter";
		cell.colSpan = "2";
		cell.appendChild(document.createTextNode("No emails"));
		table.inited = false;
	}
}
function selectAll(txt) {
	var chks = document.getElementsByTagName("input");
	for (var i  = 0; i < chks.length; i++) {
		if (chks[i].type == "checkbox") {
			if (txt == chks[i].manage) chks[i].checked = !chks[i].checked;
			else if (!txt && !chks[i].manage) chks[i].checked = !chks[i].checked;
		}
	}	
}