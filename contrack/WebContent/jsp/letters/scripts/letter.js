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
function save() {
	var inputs = document.getElementsByTagName("input");
	var ids = "";
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].type == "hidden") {
			if (ids != "") ids += ",";
			ids += inputs[i].value + inputs[i].name;
		}
	}
	if (!letter_id) window.location = surl + ids;
	else window.location = surl + ids + "&letter_id=" + letter_id;
}
function resizeHead(name) {
	var div = document.getElementById(name + "Div");
	var head = document.getElementById(name + "Head");
	var table = document.getElementById(name);
	if (table.style.display == "none") table = document.getElementById(name + "Proj");
	if (table.offsetWidth != 0)	div.style.width = (table.offsetWidth + div.offsetWidth - div.clientWidth) + "px";
	head.style.width = div.offsetWidth + "px";
}
function searchFormSubmit() {
	var search = document.getElementById("search").value;
	var div = document.getElementById("searchTableDiv");
	var projTable = document.getElementById("searchTableProj");
	var table = document.getElementById("searchTable");
	var inputs;
	if (search.length > 1) {
		projTable.style.display = "none";
		inputs = projTable.getElementsByTagName("input");
		for (var i = 0; i < inputs.length; i++) {
			if (inputs[i].checked) inputs[i].checked = false;
		}
		try {
			jsonrpc.search.searchLetter(searchCallBack, search);
		} catch (e) {
			alert(e);
		}
	} else {
		table.style.display = "none";
		inputs =table.getElementsByTagName("input");
		for (var i = 0; i < inputs.length; i++) {
			if (inputs[i].checked) inputs[i].checked = false;
		}
		projTable.style.display = "inline";
		resizeHead("searchTable");
	}
	return false;
}
function removeAll(type) {
	var table = document.getElementById(type + "Table");
	table.style.display = "none";
	var numRows = table.rows.length;
	for (var i = 0; i < numRows; i++) table.deleteRow(table.rows.length - 1);
	document.getElementById(type + "TableProj").style.display = "inline";
	resizeHead(type + "Table");
}
function remove(type, id) {
	var row;
	var inputs = document.getElementById(type + "Table").getElementsByTagName("input");
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].type == "hidden" && inputs[i].name == id) {
			row = inputs[i].parentNode.parentNode;
			
			break;
		}
	}
	var table = row.parentNode;
	var pRow = row.previousSibling;
	var nRow = row.nextSibling;
	while (pRow && pRow.tagName != "TR") pRow = pRow.previousSibling;
	while (nRow && nRow.tagName != "TR") nRow = nRow.nextSibling;
	if (id.indexOf("C") != -1) {
		table.removeChild(row);
	// Is the previous row a company row ...
	} else if (pRow.cells[0].innerHTML == "&nbsp;") {
		// Is there a companyrow past it
		if (!nRow || nRow.cells[0].innerHTML == "&nbsp;" 
			|| nRow.cells[0].innerHTML.indexOf("C") != -1) 
				table.removeChild(pRow);
		table.removeChild(row);
	} else table.removeChild(row);
	if (table.rows.length == 0) {
		table.parentNode.style.display = "none";
		document.getElementById(table.parentNode.id + "Proj").style.display = "inline";
	}
	resizeHead(table.parentNode.id);
}
function searchCallBack(result, e) {
	var table = document.getElementById("searchTable");
	var row, cell, chk, i, numRows = table.rows.length, txt;
	var companyId, contactId, validEmail, validFax, oldCompanyId = 0, color = true;
	for (var i = 0; i < numRows; i++) table.deleteRow(table.rows.length - 1);
	if (result.length != 0) {
		for (i = 0; i < result.length; i++) {
			validEmail = vEmail(result[i].email);
			validFax = vPhone(result[i].fax);
			contactId = result[i].contactId;
			companyId = result[i].companyId;
			row = table.insertRow(table.rows.length);
			if (color) row.className = "gray";
			row.onmouseover = b;
			row.onmouseout = n;
			row.title = result[i].companyName;
			cell = row.insertCell(0);
			cell.className = "left input";
			if (companyId != oldCompanyId) {
				if (contactId == 0) {
					chk = document.createElement("input");
					chk.type = "checkbox";
					chk.value = (hasFax && validFax? "F" : "") + "#C" + companyId;
					cell.appendChild(chk);
				} else cell.appendChild(document.createTextNode(" "));
				cell = row.insertCell(1);
				cell.className = "right bold";
				cell.style.whiteSpace = "nowrap";
				txt = result[i].companyName;
				if (contactId == 0) {
					txt += " ";
					if (hasFax && validFax) txt += "F";
				}
				cell.appendChild(document.createTextNode(txt));
				color = !color;
			}
			if (contactId != 0) {
				row = table.insertRow(table.rows.length);
				row.title = result[i].companyName;
				if (color) row.className = "gray";
				row.onmouseover = b;
				row.onmouseout = n;
				cell = row.insertCell(0);
				cell.className = "left input";
				chk = document.createElement("input");
				chk.type = "checkbox";
				chk.value = (validEmail?"E":"") + (hasFax && validFax? "F" : "") + "#N" + result[i].contactId;
				cell.appendChild(chk);
				cell = row.insertCell(1);
				cell.className = "right";
				cell.style.whiteSpace = "nowrap";
				txt = result[i].name;
				if (txt == null) txt = "";
				txt += " ";
				if (validEmail) txt += "E";
				if (hasFax && validFax) txt += "F";
				cell.appendChild(document.createTextNode(txt));
			}
			color = !color;
			oldCompanyId = companyId;
		}
	} else {
		row = table.insertRow(0);
		cell = row.insertCell(0);
		cell.colSpan = "2";
		cell.className = "left right bold acenter";
		cell.appendChild(document.createTextNode("No matches found!"));
	}
	table.style.display = "inline";
	resizeHead("searchTable");
}
function vEmail(s) {
	if (s && s.match(/^([a-zA-Z0-9])+([.a-zA-Z0-9_-])*@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-]+)+/)) return true;
	else return false;	
}

function vPhone(s) {
	if (s) {
		if (s.match(/^(1\s)?\(\d{3}\)\s\d{3}[-]\d{4}$/)) return true;
		else if (s.match(/^\1?d{10}$/)) return true;
		else if (s.match(/^(1[-])?\d{3}[-]\d{3}[-]\d{4}$/)) return true;
		else return false;
	} else return false;
}
function selectAll() {
	var chks = document.getElementsByTagName("input");
	for(var i = 0; i < chks.length; i++) {
		if (chks[i].type == "checkbox") chks[i].checked = !chks[i].checked;
	}
}
function add(type) {
	var chks = document.getElementsByTagName("input");
	var errors = new Array(2);
	errors[0] = 0;
	errors[1] = 0;
	var id, company, name;
	for(var i = 0; i < chks.length; i++) {
		if (chks[i].checked) {
			id = chks[i].value.substring(chks[i].value.indexOf("#") + 1);
			company = chks[i].parentNode.parentNode.title;
			name = chks[i].parentNode.parentNode.cells[1].innerHTML;
			if (type == "email") {
				if (chks[i].value.indexOf("E") != -1) addContact("email", id, company, name);
				else {
					errors[0]++;
					if (chks[i].value.indexOf("F") != -1 && hasFax) addContact("fax", id, company, name);
					else {
						errors[1]++;
						addContact("print", id, company, name);
					}
				}
			} else if (type == "fax" && hasFax) {
				if (chks[i].value.indexOf("F") != -1) addContact("fax", id, company, name);
				else {
					errors[1]++;
					addContact("print", id, company, name);
				}
			} else {
				addContact("print", id, company, name);
			}		
		}
	}
	if (errors[0] + errors[1] > 0) window.alert("WARNING!\n-----------------\nSome recipients could not be " 
		+ (hasFax ? "faxed or " : "") + "emailed\nand were added to " + (hasFax ? "\"Fax\" or " : "") 
		+ "\"Print\"");
}
function addContact(type, val, company, name) {
	var table = document.getElementById(type + "Table");
	var inputs = table.getElementsByTagName("input");
	var form = document.getElementById("letterForm");
	var row, cell, obj, i, exists = false;
	for (i = 0; i < inputs.length && !exists; i++) {
		exists = exists || (inputs[i].name == val);
	}
	if (!exists) {
		document.getElementById(type + "TableProj").style.display = "none";
		var companyId, contactId, oldCompanyId = 0, color = true;
		row = table.insertRow(table.rows.length);
		if (table.rows.length % 2 == 0) row.className = "gray";
		row.onmouseover = b;
		row.onmouseout = n;
		cell = row.insertCell(0);
		if (val.indexOf("C") != -1) {
			row.id = val;
			cell.className = "left";
			obj = document.createElement("A");
			obj.href = "javascript: remove('" + type + "','" + val + "');";
			obj.innerHTML = "Remove";
			cell.appendChild(obj);
			cell = row.insertCell(1);
			cell.className = "right bold";
			cell.style.whiteSpace = "nowrap";
			obj = document.createElement("input");
			obj.type = "hidden";
			obj.name = val;
			if (type == "email") obj.value = "E";
			else if (type == "fax" && hasFax) obj.value = "F";
			else obj.value = "P";
			cell.appendChild(obj);
			cell.appendChild(document.createTextNode(company));
		} else {
			cell.className = "left";
			cell.innerHTML = "&nbsp;"
			cell = row.insertCell(1);
			cell.className = "right bold";
			cell.style.whiteSpace = "nowrap";
			cell.appendChild(document.createTextNode(company));
			row = table.insertRow(table.rows.length);
			if (table.rows.length % 2 == 0) row.className = "gray";
			row.onmouseover = b;
			row.onmouseout = n;
			row.id = val;
			cell = row.insertCell(0);
			cell.className = "left";
			obj = document.createElement("A");
			obj.href = "javascript: remove('" + type + "','" + val + "');";
			obj.innerHTML = "Remove";
			cell.appendChild(obj);
			cell = row.insertCell(1);
			cell.className = "right";
			cell.style.whiteSpace = "nowrap";
			obj = document.createElement("input");
			obj.type = "hidden";
			obj.name = val;
			if (type == "email") obj.value = "E";
			else if (type == "fax" && hasFax) obj.value = "F";
			else obj.value = "P";
			cell.appendChild(obj);
			cell.appendChild(document.createTextNode(name));
		}
		table.style.display = "inline";
		resizeHead(type + "Table");
		if (row) row.scrollIntoView();
	}
}