package com.sinkluge.reports;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.database.Database;

class BlankReport extends Report {

	protected BlankReport() {
		
	}
	
	public void create(Info in, Image logo) throws Exception {	

	}

	public void doCleanup(Database db) throws Exception {

	}

	@Override
	public ReportContact getReportContact(String id, Database db)
			throws Exception {
		return null;
	}

}
