function include_js(script_filename) {
    var html_doc = document.getElementsByTagName('head').item(0);
    var js = document.createElement('script');
    //js.setAttribute('language', 'javascript');
    //js.setAttribute('type', 'text/javascript');
    js.setAttribute('src', script_filename);
    html_doc.appendChild(js);
}
function include_css(css_filename) {
    var html_doc = document.getElementsByTagName('head').item(0);
    var js = document.createElement('link');
    js.setAttribute('rel', 'stylesheet');
    js.setAttribute('type', 'text/css');
    js.setAttribute('href', css_filename);
    html_doc.appendChild(js);
}
function calSetupLoaded() {
	var imgs = document.getElementsByTagName("img");
	var id;
	for (var i = 0; i < imgs.length; i++) {
		id = imgs[i].id;
		if (id.indexOf("cal") == 0) {
			imgs[i].style.cursor = "pointer";
		    Calendar.setup({
		        inputField     :    id.substring(3),
		        button		   :	id,
		        ifFormat       :    "%m/%d/%Y",
		        weekNumbers	   :	false,
		        align          :    "bc"
		    });
		}
	}
}
var calLoaded = false;
var calappbase = window.location.pathname.match(/^\/\w+\//);
window.onload = initCal;
function initCal() {
	if(!calLoaded) {
		include_css(calappbase + "jsp/utils/calendar/calendar-system.css");
		include_js(calappbase + "jsp/utils/calendar/calendar.js");
		calLoaded = true;
	}
}
function insertDate(id) {
	var now = new Date();
	var month = now.getMonth() + 1 ;
	var day = "";
	day = "0" + now.getDate();
	day = day.substring(day.length-2,day.length);
	month = "0" + month;
	month = month.substring(month.length-2,month.length);
	try {
		document.getElementById(id).value = month + "/" + day + "/" + now.getFullYear();
	} catch (e) {
		window.alert("Cannot find element with ID: " + id);
	}
}