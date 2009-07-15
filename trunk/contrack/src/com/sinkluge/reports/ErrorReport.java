package com.sinkluge.reports;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.database.Database;

public class ErrorReport extends Report {

	public void create(Info in, Image logo) throws Exception {
		throw new IllegalArgumentException("Report not found!");
	}
	
	public void doCleanup(Database db) throws Exception {
	}

	@Override
	public ReportContact getReportContact(String id, Database db) throws Exception {
		return null;
	}
}
