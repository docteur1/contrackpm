package com.sinkluge.reports;

import org.apache.commons.io.output.ByteArrayOutputStream;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.database.Database;

public interface Report {

	public ByteArrayOutputStream create(Info in, Image logo) throws Exception;
	public void doCleanup(Database db) throws Exception;	
}
