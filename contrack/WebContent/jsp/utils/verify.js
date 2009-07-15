function req(obj) {
	return isBlank(obj)
}
function isBlank (obj) {
	return obj.value == null || obj.value == "" || obj.value.match(/^\s+$/);
}	
function vDate(obj) {
	var bad = true;
	var today = new Date();
	if (obj.value.match(/^\d{2}\/\d{2}\/\d{4}$/)) bad = false;
	else if (obj.value.match(/^\d{2}\/\d{2}\/\d{2}$/)) {
		bad = false;
		obj.value = obj.value.substring(0,6) + "20" + obj.value.substring(6);
	} else if (obj.value.match(/^\d{2}\/\d{2}$/)) {
		bad = false;
		obj.value = obj.value.substring(0,5) + "/" + today.getFullYear();
	} else if (obj.value.match(/^\d{8}$/)) {
		bad = false;
		obj.value = obj.value.substring(0,2) + "/" + obj.value.substring(2,4) + "/" + obj.value.substring(4);
	} else if (obj.value.match(/^\d{6}$/)) {
		bad = false;
		obj.value = obj.value.substring(0,2) + "/" + obj.value.substring(2,4) + "/20" + obj.value.substring(4);
	} else if (obj.value.match(/^\d{4}$/)) {
		bad = false;
		obj.value = obj.value.substring(0,2) + "/" + obj.value.substring(2) + "/" + today.getFullYear();
	}
	if (bad) return false;
	var year = obj.value.substring(6);
	var month = obj.value.substring(0,2);
	var day = obj.value.substring(3,5);
	var year = year-0;
	var month = month-0;
	var day = day-0;
	if (day > 31 || month < 1 || month > 12) return false;
	else if ((month == 4 || month == 6 || month == 9 || month ==11) && day > 30) return false;
	else if (month == 2) {
		if (year % 4 == 0 && day > 29) return false;
		else if (day > 28) return false;
	}
	return true;
}
function vInt(s) {
	deComma(s);
	if(s.value.match(/^([-]?)(\d*)$/)) return true;
	else return false;
}
function vFloat (s){
	deComma(s);
	if(s.value.match(/^([-]?)(\d*)(\.?)(\d*)$/)) {
		if (s.value.indexOf(".") == s.value.length - 1)
			s.value += "00";
		return true;
	} else return false;
}
function deComma (s) {
	for (var i = 0; i < s.value.length; i++) {
		var c = s.value.charAt(i);
		if (c == ",") s.value = s.value.substring(0,i) + s.value.substring(i+1);
	}
}

// Try to get rid of this function
function isDigit(c) {
	return ((c >= "0") &&  (c <= "9"));
}
function vEmail(s) {
	if (s.value.match(/^([a-zA-Z0-9])+([.a-zA-Z0-9_-])*@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-]+)+$/)) return true;
	else return false;	
}

function vPhone(s) {
	if (s.value.match(/^(1\s)?\(\d{3}\)\s\d{3}[-]\d{4}$/)) return true;
	else {
		if (s.value.match(/^\d{3}[-]\d{3}[-]\d{4}$/)) {
			s.value = "(" + s.value.substring(0,3) + ") " + s.value.substring(4,7) + "-" + s.value.substring(8);
			return true;
		} else if (s.value.match(/^\d{10}$/)) {
			s.value = "(" + s.value.substring(0,3) + ") " + s.value.substring(3,6) + "-" + s.value.substring(6);
			return true;
		} else if (s.value.match(/^1[-]\d{3}[-]\d{3}[-]\d{4}$/)) {
			s.value = "1 (" + s.value.substring(2,5) + ") " + s.value.substring(6,9) + "-" + s.value.substring(10);
			return true;
		} else if (s.value.match(/^\d{11}$/)) {
			s.value = "1 (" + s.value.substring(1,4) + ") " + s.value.substring(4,7) + "-" + s.value.substring(7);
			return true;
		} else return false;
	}
}
function vZip(s) {
	if (s.value.match(/^\d{5}([-]\d{4})?$/)) return true;
	else return false;
}
function checkForm(obj) {
	var msg;
	var empty_fields = "";
	var errors = "";
	for (var i = 0; i < obj.length; i++) {
		var e = obj.elements[i];
		if (e.type != "button" && e.type != "submit") e.style.backgroundColor = "white";
		if(e.required && req(e)) {
			empty_fields += "\n    " + e.eName;
			e.style.backgroundColor = "#FFFFCC";	
		} else if(e.isInt && !vInt(e) && !req(e)) {
			errors += "- " + e.eName + " contains an invalid integer number.\n";
			e.style.backgroundColor = "#FFFFCC";
		} else if(e.isFloat && !vFloat(e) && !req(e)) {
			errors += "- " + e.eName + " contains an invalid decimal number.\n"; 
			e.style.backgroundColor = "#FFFFCC";
		} else if(e.isDate && !vDate(e) && !req(e)) {
			var today = new Date();
			var year = today.getFullYear() + "";
			errors += "- " + e.eName + " contains an invalid date.\n    "
				+ "Examples: 05/21/" + year + ", 05/21/" + year.substring(2) + ", 05/21, 0521" + year 
				+ ", 0521" + year.substring(2) + ", or 0521.\n";
			e.style.backgroundColor = "#FFFFCC";
		} else if(e.isEmail && !vEmail(e) && !req(e)) {
			errors += "- " + e.eName + " contains an invalid email address.\n";
			e.style.backgroundColor = "#FFFFCC";
		} else if(e.isPhone && !vPhone(e) && !req(e)) {
			errors += "- " + e.eName + " contains an invalid phone number.\n    "
				+ "Examples: (000) 000-0000, 000-000-0000, or 0000000000.\n    "
				+ "Or: 1 (000) 000-0000, 1-000-000-0000, or 1000000000.\n";
			e.style.backgroundColor = "#FFFFCC";
		} else if(e.isZip && !vZip(e) && !req(e)) {
			errors += "- " + e.eName + " contains an invalid zip code.\n";
			e.style.backgroundColor = "#FFFFCC";
		}
	}

	//Are there errors?
	if (!empty_fields && !errors) return true;
	
	//Display errors
	msg  = "_________________________________________________\n\n";
	msg += "The form was not submitted because of the following error(s).\n";
	msg += "Please correct these error(s) and re-submit.\n";
	msg += "_________________________________________________\n\n";
	
	if (empty_fields) {
		msg += "- The following required field(s) are empty:" + empty_fields + "\n";
		if (errors) msg += "\n";
	}
	
	msg += errors;
	alert(msg);
	return false;
}