function resizePopup(event) {
	if (window.scrollMaxX) window.resizeTo(window.scrollMaxX + window.outerWidth, window.outerHeight);
	else if ((navigator.userAgent.toLowerCase().indexOf("gecko") == -1) && 
		(document.body.offsetWidth < document.body.scrollWidth)) 
			window.resizeTo(document.body.scrollWidth + 30, document.body.offsetHeight + 30);
}
window.onload = resizePopup;