function hide() {
	parent.document.getElementById("fs").rows = "41,0,*,16";
	window.location = "blank.html";
	return false;
}
function save() {
	if(checkForm(f)) {
		f.action = "processCode.jsp";
		f.submit();
	} else return false;
}
function loadCode(obj) {
	var t = obj.options[obj.selectedIndex].text;
	var x = t.indexOf(" ");
	var div = t.substring(0,x);
	t = t.substring(x+1);
	x = t.indexOf("-");
	f.cost_code.value = t.substring(0,x);
	t = t.substring(x+1);
	x = t.indexOf(" ");
	f.phase.value = t.substring(0,x);
	f.description.value = t.substring(x+1);
	for (var i = 0; i < f.div.options.length; i++) {
		if (f.div.options[i].value == div) f.div.options[i].selected = true;
	}
	obj.selectedIndex = 0;
}
function Type(type, name) {
	this.type = type;
	this.name = name;
	this.toString = function() { return this.type + " " + this.name; };
}
function verifyCostType(type){
	var found = false;
	for(var i = 0; i < typesList.length; i++) {
		if (typesList[i].type == type) {
			found = true;
			break;
		}
	}
	if (!found) {
		var msg = "ERROR\n-----------------------\nOnly the following cost types are valid:\n\n";
		for(var i = 0; i < typesList.length; i++) {
			msg += "    " + typesList[i].toString() + "\n";
		}
		window.alert(msg);
	}
}