package com.sinkluge.JSON;

import java.io.Serializable;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import com.sinkluge.database.Database;
import com.sinkluge.security.Name;
import com.sinkluge.security.Permission;
import com.sinkluge.security.Security;

public class CloseoutJSON implements Serializable {

	private static final long serialVersionUID = 1L;

	public static void update(HttpSession session, String fieldId, String value, boolean isCheckbox) 
			throws Exception {
		Database db = new Database();
		Security sec = (Security) session.getAttribute("sec");
		if (!sec.ok(Name.SUBCONTRACTS, Permission.WRITE)) return;
		if (isCheckbox && value != null) value = "y";
		else if (isCheckbox) value = "n";
		String fieldName="", contractId="";
		Logger log = Logger.getLogger(CloseoutJSON.class);
		if (fieldId != null) {
			fieldName = fieldId.substring(0,2);
			contractId = fieldId.substring(2);
			if(fieldName.equals("rS")) fieldName = "req_tech_submittals";
			if(fieldName.equals("hS")) fieldName = "have_tech_submittals";
			if(fieldName.equals("rW")) fieldName = "req_warranty";
			if(fieldName.equals("hW")) fieldName = "have_warranty";
			if(fieldName.equals("rT")) fieldName = "req_owner_training";
			if(fieldName.equals("hT")) fieldName = "have_owner_training";
			if(fieldName.equals("hL")) fieldName = "have_lien_release";
			if(fieldName.equals("rP")) fieldName = "req_specialty";
			if(fieldName.equals("hP")) fieldName = "have_specialty";
			if(fieldName.equals("tN")) fieldName = "tracking_notes";
			String update = "update contracts set " + fieldName + " = '" + value 
				+ "' where contract_id = " + contractId;
			log.debug(update);
			db.dbInsert(update);
		}
		db.disconnect();
	}
	
}
