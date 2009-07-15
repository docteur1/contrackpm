var contextbase = window.location.pathname.match(/^\/\w+\//);
function openInlineWindow(url, widthP, heightP) {
	var bg = document.createElement("div");
	bg.style.position = "absolute";
	bg.style.top = "0px";
	bg.style.left = "0px";
	bg.style.opacity = "0.5";
	bg.style.filter = "alpha(opacity=50)";
	bg.style.backgroundColor = "black";
	bg.style.width = "100%";
	bg.style.height = "100%";
	bg.style.zIndex = "50";
	bg.id = "windowshade";
	var  doc = document.getElementsByTagName("body").item(0);
	doc.appendChild(bg);
	var iframe = document.createElement("iframe");
	iframe.style.position = "absolute";
	iframe.style.zIndex = "51";
	iframe.style.width = widthP + "%";
	iframe.style.height = heightP + "%";
	iframe.style.top = (100 - heightP)/2 + "%";
	iframe.style.left = (100 - widthP)/2 + "%";
	iframe.style.visibility = "hidden";
	iframe.style.border = "none";
	iframe.id = "inlineframe";
	iframe.style.backgroundColor = "white";
	doc.appendChild(iframe);
	var loading = document.createElement("div");
	var img = document.createElement("img");
	img.src = contextbase + "images/loading_circle.gif";
	img.style.position = "relative";
	img.style.top = "30%";
	loading.style.position = "absolute";
	loading.style.zIndex = "52";
	loading.style.width = widthP + "%";
	loading.style.height = heightP + "%";
	loading.style.top = (100 - heightP)/2 + "%";
	loading.style.left = (100 - widthP)/2 + "%";
	loading.style.textAlign = "center";
	loading.style.backgroundColor = "white";
	loading.appendChild(img);
	loading.id = "windowshadeloading";
	doc.appendChild(loading);
	if (iframe.readyState) iframe.onreadystatechange = _showWindow;
	else iframe.onload = _showWindow;
	iframe.src = url;
}
function _showWindow(e) {
	var iframe = document.getElementById("inlineframe");
	var loading = document.getElementById("windowshadeloading");
	iframe.style.visibility = "visible";
	document.getElementsByTagName("body").item(0).removeChild(loading);
}
function closeInlineWindow() {
	var iframe = document.getElementById("inlineframe");
	var  doc = document.getElementsByTagName("body").item(0);
	doc.removeChild(iframe);
	var ws = document.getElementById("windowshade");
	doc.removeChild(ws);
}