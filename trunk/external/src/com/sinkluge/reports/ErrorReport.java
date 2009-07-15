package com.sinkluge.reports;

import org.apache.commons.io.output.ByteArrayOutputStream;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.database.Database;

public class ErrorReport implements Report {

	public ByteArrayOutputStream create(Info in, Image logo) throws Exception {
		return null;
	}

	public void doCleanup(Database db) throws Exception {
	}

}
