var jsonrpc = new JSONRpcClient("JSON-RPC");
var jsonpoller = new JSONRpcClient("../JSON-RPC");
var perms;
var limit = 0;
var nextLoc = null;
function setProjectId(id, loc) {
	projectId = id;
	document.getElementById("limitList")[2].selected = true;
	nextLoc = loc;
	loadProjectList(true);
}
function changeProjectId() {
	var projectList = document.getElementById("projectList");
	projectId = projectList.value;
	jsonrpc.home.setProjectId(projectIdCallback, projectId);
}
var reload = true;
function projectIdCallback(result, e) {
	perms = result.perms;
	document.title = document.title.substring(0, document.title.indexOf(" -")) + " - " + result.siteName;
	document.getElementById("companyName").innerHTML = result.siteName;
	fitFrame();
	document.cookie = "lpid=" + escape(projectId) + "; path=" + path + 
		"; expires=Fri, 31 Dec 2099 23:59:59 GMT;";
	var frame = document.getElementById("frame");
	if (!nextLoc) {
		if (!frame.src || frame.src == "" || frame.src.indexOf("blank.html") != -1) show("main.jsp");
		else if (reload) window.mainFrame.location.reload();
	} else {
		show(nextLoc);
		nextLoc = null;
	}
	reload = true;
	initMenu();
	
}
function loadProjectList(first) {
	limit = document.getElementById("limitList").value;
	if (!first) projectId = document.getElementById("projectList").value;
	jsonrpc.home.getProjectList(projectListCallback, limit);
}
function projectListCallback(result, e) {
	var projectList = document.getElementById("projectList");
	projectList.length = 0;
	if (result.list) { 
		for (var j = 0; j < result.list.length; j++) {
			var opt = document.createElement("option");
			opt.text = result.list[j].projectNum + " " + result.list[j].projectName;
			opt.value = result.list[j].projectId;
			if (opt.value == projectId) opt.selected = true;
			projectList[j] = opt;
		}
		if (result.list.length > 0) 
			document.getElementById("limitList").selectedIndex = result.list[0].limit;
		changeProjectId();
	}
}
var mb = null;
var timeoutID = 0;
function openMenu(obj, id) {
	if (mb && mb.id != id) {
		window.clearTimeout(timeoutID);
		closeMenuDelay();
	}
	else keepOpen();
	mb = document.getElementById(id);
	mb.style.display = "inline";
	mb.style.top = (obj.offsetTop + obj.offsetHeight - 1) + "px";
	mb.style.left = obj.offsetLeft + "px";
}
function closeMenu() {
	timeoutID = window.setTimeout(closeMenuDelay, 250);
}
function keepOpen() {
	window.clearTimeout(timeoutID);
}
function closeMenuDelay() {
	if (mb) mb.style.display = "none";
}
function show(loc, cMenu) {
	document.getElementById("frame").src = loc;
	if (cMenu) closeMenuDelay();
}
function pop(loc, x, y, cMenu) {
	var win = window.open(loc, "manage", "toolbar=no,location=no,directories=no,status=no,menubar=no,"
		+ "scrollbars=yes,resizable=yes,width=" + x + ",height=" + y + ",left=25,top=25");
	if (cMenu) closeMenuDelay();
}
function fitFrame() {
	fitRightItem();
	var frame = document.getElementById("frame"); 
	frame.style.height = (document.documentElement.clientHeight - 
		frame.offsetTop) + "px";
}
function fitRightItem() {
	var leftItem = document.getElementById("leftItem");
	var rightItem = document.getElementById("rightItem");
	var topBar = document.getElementById("topBar");
	if (leftItem.offsetWidth >= rightItem.offsetLeft && leftItem.offsetHeight > rightItem.offsetTop) {
		rightItem.style.top = topBar.offsetHeight + "px";
		topBar.style.height = (topBar.offsetHeight + rightItem.offsetHeight) + "px";
	} else if (leftItem.offsetWidth < rightItem.offsetLeft) {
		rightItem.style.top = "5px";
		topBar.style.height = "";
	} 
}
function initMenu() {
	var divs = document.getElementsByTagName("div");
	for (var i = 0; i < divs.length; i++) {
		if (divs[i].className.indexOf("menuItem") != -1) {
			divs[i].onmouseover = keepOpen;
			divs[i].onmouseout = closeMenu;
			if (divs[i].className.indexOf("menuHidden") != -1) {
				if (perms.map[divs[i].id])	divs[i].style.display = "block";
				else divs[i].style.display = "none";
			}
		}
		if (divs[i].className.indexOf("menuHead") != -1) {
			divs[i].onmouseout = closeMenu;
			if (divs[i].id) {
				if (perms.map[divs[i].id]) {
					divs[i].style.cursor = "pointer";
					if(divs[i].onchange) {
						divs[i].onclick = divs[i].onchange;
					}
				} else {
					divs[i].onchange = divs[i].onclick;
					divs[i].onclick = null;
					divs[i].style.cursor = "not-allowed";
				}
				
			}
		}
	}
}
function poll() {
	jsonpoller.home.poll(pollCallback);
}
var counterID = null;
function clearCountdown() {
	if (counterID != null) window.clearInterval(counterID);
	counterID = null;
	counter = null;
	hideMessage();
	jsonrpc.home.preventTimeout(clearCountdownCallback);
}
function clearCountdownCallback(e) {
	if (e == null) {
		poll();
	} else {
		connectionError(e);
		return;
	}
}
var counter = null;
var oldTitle = null;
function countdown () {
	if (counterID == null) counterID = window.setInterval(countdown, 1000);
	// three minute countdown
	if (counter == null) {
		counter = 3*60;
		oldTitle = document.title;
	}
	if (counter != 0) {
		var obj = document.getElementById("timeToExpire");
		var seconds = counter % 60;
		var minutes = Math.floor(counter / 60);
		if (seconds < 10) seconds = "0" + seconds;
		obj.innerHTML = minutes + ":" + seconds;
		if (seconds % 3 == 0) document.title = "Session expires in " + minutes + ":" + seconds;
		else document.title = oldTitle;
		counter--;
	}  else {
		kick("Browser Session Expired");
	}
}
function pollCallback(result, e) {
	if (e == null) {
		if (result.kick) {
			kick(result.message);
			return;
		} else if (result.prekick) {
			hide("doc4");
			hide("doc6");
			document.getElementById("doc3").innerHTML = "Session Inactive";
			display("doc8");
			display("doc5");
			countdown();
			display("doc1");
			display("doc2");
			document.getElementById("doc7").focus();
		} else if (result.message != null) 
			showMessage(result.message, "Message from Contrack");
		var faxE = document.getElementById("faxError");
		if (result.faxMessage != null) {
			faxE.innerHTML = "Fax " + result.faxMessage;
			faxE.style.display = "inline";
		} else faxE.style.display = "none";
	} else {
		connectionError(e);
		return;
	}
	window.setTimeout(poll, 30000);
}
function display(id, msg) {
	var doc = document.getElementById(id);
	doc.style.display = "block";
	if (msg != null) doc.innerHTML = msg;
}
function hide(id) {
	document.getElementById(id).style.display = "none";
}
function hideMessage() {
	hide("doc2");
	hide("doc1");
	if (flashID != null) {
		window.clearInterval(flashID);
		document.title = oldTitle;
	}
}
var flashID = null;
var flashMessage = null;
function flash() {
	if (flashID == null) {
		flashID = window.setInterval(flash, 3000);
		oldTitle = document.title;
	}
	if (document.title == oldTitle) document.title = flashMessage;
	else document.title = oldTitle;			
}
function showMessage(msg, title, nookbutton) {
	hide("doc8");
	hide("doc5");
	document.getElementById("doc3").innerHTML = title;
	flashMessage = title;
	flash();
	display("doc4", msg);
	if (!nookbutton) display("doc6");
	else hide("doc6");
	display("doc1");
	display("doc2");
	if (!nookbutton) document.getElementById("doc9").focus();
}
function kick(msg) {
	logout = false;
	var loc = "../logout.jsp";
	if (msg != null) loc += "?reason=" + msg;
	window.location.href = encodeURI(loc);
}
function connectionError(e) {
	if (testMode) kick("Automatically kicked: test mode");
	showMessage("Your browser is having difficulty connecting to the the Contrack server. "
		+ "<div class=\"link bold\" onclick=\"hideMessage(); poll();\">Reconnect</div> or "
		+ "<div class=\"link bold\" onclick=\"kick('Requested for connection problem');\">"
		+ "restart your session</div>.<br/><br/>Error: " + e.message + " (" + e.name + ": " 
		+ e.code + ").", "Connection Error", true);
	jsonpoller.home.setError(nullCallback, null, "CONNECTION ERROR ON HOME (JSONRPC): \n"
		+ "Message: " + e.message + "<br>Name: " + e.name + "<br>Code: "
		+ e.code + (e.javaStack != null ? "<br>Stack: " + e.javaStack : "")
		+ "<br>URL: " + window.location.toString(), null, true);
}
function nullCallback(result, e) {
	// Do nothing
}
var logout = true;
window.onunload = function (ev) {
	if (logout && !testMode) {
		var temp = jsonrpc.home.destroySession("Browser Closed");
   	}
}