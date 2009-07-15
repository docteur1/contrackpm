var msg = null;
function cb(result, e) {
	if (result != null) {
		for (var i = 0; i < result.length; i++) {
			if (ask(result[i].name, result[i].id)) {
				// Synchronous call wait to complete
				var wait = jsonrpc.accounting.setCompanyAccountIdByContract(result[i].id, contractID);
				done();
				break;
			}
		}
	}
	if (nextFunction != null) nextFunction();
	else done("Unable to find company");
}
function byContract() {
	nextFunction = byOldContract;
	jsonrpc.accounting.getCompanyByContract(cb, contractID);
}
function byOldContract() {
	nextFunction = byName;
	jsonrpc.accounting.getCompanyByOldContract(cb, contractID);
}
function byName() {
	nextFunction = null;
	jsonrpc.accounting.getCompanyByName(cb, companyName);
}
function ask(company, id) {
	return window.confirm("Match company in accounting database\n-----------------------------\n" +
		"Contrack: " + companyName + "\n" +
		"Accounting: " + company + " (" + id + ")\n\nIs this correct?");
}