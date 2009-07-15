package com.sinkluge.reports;

import java.io.IOException;

import com.lowagie.text.DocumentException;

public abstract class CombinedReport extends Report {

	public void add(Report r) throws 
		DocumentException, IOException {
		ReportUtils.add(r, this, false, null);
	}

}
