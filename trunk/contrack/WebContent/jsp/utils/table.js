function sortTable(e){
	if (!e) var e = window.event;
	var target = e.target;
	if (!target) target = e.srcElement;
	ts_resortTable(target);
}
function n(id) {
	id.className = id.oldClassName;
}
function b(id) {
	id.oldClassName = id.className;
	id.className = "yellow";
	if (id.oldClassName.indexOf("bold") != -1) id.className += " bold";
}
var rendered = false;
function getWindowHeight() {
    var y = 0;
    if (self.innerHeight) y = self.innerHeight;
    else if (document.documentElement && document.documentElement.clientHeight)
    	y = document.documentElement.clientHeight;
    else if (document.body) y = document.body.clientHeight;
    return y;
}
function getWindowWidth() {
	var y = 0;
	if (self.innerWidth) y = self.innerWidth;
	else if (document.documentElement && document.documentElement.clientWidth)
		y = document.documentElement.clientWidth;
	else if (document.body) y = document.body.clientWidth;
	return y;
}
function resize() {
	try {
		var div = document.getElementById("tableDiv");
		var head = document.getElementById("tableHead");
		var table = document.getElementById("tableMain");
		div.style.width = "100%";
		div.style.height = (getWindowHeight() - div.offsetTop - 15) + "px";
		var hRow = head.rows[0];
		if (hRow.cells[0].colSpan != 1) hRow = head.rows[1];
		var row = table.rows[0];
		var hRowWidth, rowWidth;
		for (var i = 0; i < hRow.cells.length; i++) {
			if (sortCol(hRow.cells[i])) {
				hRow.cells[i].onclick = sortTable;
				hRow.cells[i].style.cursor = "pointer";
				hRow.cells[i].nowrap = true;
				if (!rendered) hRow.cells[i].innerHTML = ts_getInnerText(hRow.cells[i]) 
					+ "<span class=\"sortarrow\">&nbsp;&nbsp;&nbsp;</span>";
			}
			hRowWidth = hRow.cells[i].clientWidth - 6;
			rowWidth = row.cells[i].clientWidth - 6;
	
			if (hRowWidth > rowWidth) {
				row.cells[i].style.width = hRowWidth + "px";
				hRow.cells[i].style.width = hRowWidth + "px";
			} else {
				hRow.cells[i].style.width = rowWidth + "px";
				row.cells[i].style.width = rowWidth + "px";
			}
		}
		if (hRow.offsetWidth < table.offsetWidth) hRow.cells[hRow.cells.length - 1].style.width =
			(hRow.cells[hRow.cells.length - 1].clientWidth - hRow.offsetWidth + table.offsetWidth - 6) + "px";
		div.style.width = (table.offsetWidth + div.offsetWidth - div.clientWidth) + "px";
		hRow.cells[hRow.cells.length - 1].style.width = (hRow.cells[hRow.cells.length - 1].clientWidth 
			+ div.offsetWidth - table.offsetWidth - 6) + "px";
		rendered = true;
	} catch (e) {
	} finally {
		waitDiv.style.display = "none";
	}
}
function sortCol(obj) {
	return obj.className.indexOf("nosort") == -1;
}
var SORT_COLUMN_INDEX;
function ts_getInnerText(el) {
	if (typeof el == "string") return el;
	if (typeof el == "undefined") return el;
	if (el.innerText) return el.innerText;	//Not needed but it is faster
	var str = "";
	var cs = el.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		switch (cs[i].nodeType) {
			case 1: //ELEMENT_NODE
				if (cs[i].nodeName.toLowerCase() == "input") str += cs[i].getAttribute("type").toLowerCase();
				else str += ts_getInnerText(cs[i]);
				break;
			case 3:	//TEXT_NODE
				str += cs[i].nodeValue;
				break;
		}
	}
	return str;
}
function ts_colorRow(tr, color) {
    	var cName = tr.className;
    	if (color) tr.className = "gray";
    	else tr.className = "";
    	if (cName.indexOf("sortbottom") != -1) tr.className += " sortbottom";
    	if (cName.indexOf("bold") != -1) tr.className += " bold";
}
function ts_resortTable(td,clid) {
    // get the span
    var span;
    for (var ci=0;ci < td.childNodes.length;ci++) {
        if (td.childNodes[ci].tagName && td.childNodes[ci].tagName.toLowerCase() == 'span') span = td.childNodes[ci];
    }
    var spantext = ts_getInnerText(span);
    var column = clid || td.cellIndex;
    var table = document.getElementById("tableMain");
    // Work out a type for the column
    if (table.rows.length <= 1) return;
    var itm = " ";
    var i = 0;
    for(i = 0; itm.match(/^\s*$/) && i < table.rows.length; i++)
    	itm = ts_getInnerText(table.rows[i].cells[column]);
    sortfn = ts_sort_default;
    if (itm.match(/^\d*\s[a-zA-Z]{3}\s\d{2}$/)) sortfn = ts_sort_date;
    else if (itm.match(/^[-]?[\d\,]*[\d\.]+$/)) sortfn = ts_sort_numeric;
    else if (itm.match(/^checkbox$/) || itm.match(/^radio$/)) sortfn = ts_sort_checkbox;
   	else if (itm.match(/^text$/)) sortfn = ts_sort_textbox;
    SORT_COLUMN_INDEX = column;
    var newRows = new Array();
    for (j=0; j < table.rows.length; j++) {newRows[j] = table.rows[j];} 
    newRows.sort(sortfn);
    if (span.getAttribute("sortdir") == 'down') {
        ARROW = '&nbsp;&uarr;';
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        ARROW = '&nbsp;&darr;';
        span.setAttribute('sortdir','down');
    }
    var color = false;
    for (i=0; i < newRows.length; i++) {
    	if (!newRows[i].className || (newRows[i].className && 
    			(newRows[i].className.indexOf('sortbottom') == -1))) {
    		ts_colorRow(newRows[i], color);
    		table.tBodies[0].appendChild(newRows[i]);
    		color = !color;
    	}
    }
    // do sortbottom rows only
    for (i=0;i<newRows.length;i++) { 
    	if (newRows[i].className && (newRows[i].className.indexOf('sortbottom') != -1)) {
    		ts_colorRow(newRows[i], color);
    		table.tBodies[0].appendChild(newRows[i]);
    		color = !color;
    	}
    }
    // Delete any other arrows there may be showing
    var allspans = document.getElementsByTagName("span");
    for (var ci=0;ci<allspans.length;ci++) {
        if (allspans[ci].className == 'sortarrow') {
            if (getParent(allspans[ci],"table") == getParent(td,"table")) { // in the same table as us?
                allspans[ci].innerHTML = '&nbsp;&nbsp;&nbsp;';
            }
        }
    }
    span.innerHTML = ARROW;
}
function getParent(el, pTagName) {
	if (el == null) return null;
	else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
		return el;
	else
		return getParent(el.parentNode, pTagName);
}
function ts_sort_checkbox(a,b) {
	aa = a.cells[SORT_COLUMN_INDEX].firstChild;
    bb = b.cells[SORT_COLUMN_INDEX].firstChild;
	return bb.checked - aa.checked;
}
function ts_sort_textbox(a,b) {
	aa = a.cells[SORT_COLUMN_INDEX].firstChild;
    bb = b.cells[SORT_COLUMN_INDEX].firstChild;
	 if (aa.value==bb.value) return 0;
    if (aa.value<bb.value) return -1;
    return 1;
}
function ts_date_month(d) {
	d = d.match(/[a-zA-Z]{3}/);
	if (d == "Jan") return "01";
	else if (d == "Feb") return "02";
	else if (d == "Mar") return "03";
	else if (d == "Apr") return "04";
	else if (d == "May") return "05";
	else if (d == "Jun") return "06";
	else if (d == "Jul") return "07";
	else if (d == "Aug") return "08";
	else if (d == "Sep") return "09";
	else if (d == "Oct") return "10";
	else if (d == "Nov") return "11";
	else if (d == "Dec") return "12";
}
function ts_date_day(d) {
	var dt = d.substring(0, d.indexOf(" "));
	if (dt.length == 1) dt = "0" + dt;
	return dt;
}
function ts_date_year(d) {
	var dt = d.substring(d.lastIndexOf(" ") + 1);
	if (dt < 50) dt = "20" + dt;
	else dt = "19" + dt;
	return dt;
}
function ts_sort_date(a,b) {
    // y2k notes: two digit years less than 50 are treated as 20XX, greater than 50 are treated as 19XX
    var aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    var bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    var dt1 = parseInt(ts_date_year(aa) + ts_date_month(aa) + ts_date_day(aa));
    var dt2 = parseInt(ts_date_year(bb) + ts_date_month(bb) + ts_date_day(bb));
    if (dt1==dt2) return 0;
    else if (dt1<dt2) return -1;
    else return 1;
}
function ts_sort_numeric(a,b) { 
	try {
	    aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.-]/g,''));
	    if (isNaN(aa)) aa = 0;
	    bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.-]/g,'')); 
	    if (isNaN(bb)) bb = 0;
	    return aa-bb;
    } catch (e) {
    	return 0;
    }
}
function ts_sort_default(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}
window.onload = resize;
window.onresize = resize;

/*
 * Wait until we actually have a body
 */
window.setTimeout(showLoading, 10);
var waitDiv = document.createElement("div");
function showLoading() {
	if (!document.getElementsByTagName("body").item(0)) {
		window.setTimeout(showLoading, 10);
		return;
	}
	document.getElementsByTagName("body").item(0).appendChild(waitDiv);
	waitDiv.style.position = "absolute";
	waitDiv.style.zIndex = "50";
	waitDiv.style.left = "0px";
	waitDiv.style.top = "0px";
	waitDiv.style.width = "100%";
	var y = getWindowHeight();
	waitDiv.style.height = y; //(document.body.clientHeight) + "px";
	waitDiv.style.backgroundColor = "white";
	var img = document.createElement("img");
	var path = window.location.pathname.match(/^\/\w+\//);
	img.setAttribute("src", path + "images/loading_circle.gif");
	waitDiv.appendChild(img);
	img.style.position = "absolute";
	img.style.left = (getWindowWidth()/2 - 33) + "px";
	img.style.top = (y/2 - 33) + "px";
}