package com.sinkluge.reports.documents;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.ReportContact;

import kf.KF;

public class KFWImage extends Report {
	
	public KFWImage(String id, boolean pro, HttpSession session) throws Exception {
		getImage(id, true, pro, session);
	}
	
	public KFWImage(String id, HttpSession session) throws Exception {
		getImage(id, false, false, session);
	}
	
	/**
	 * Used by the non-session {@link com.sinkluge.servlets.AccountingImage}
	 * accounting image servlet.
	 * @param id			The documentID or the KFW document
	 * @param siteId		The siteId, not important in this context since the document isn't "site" specific, but is need to instantiate the KF class.
	 * @param application	The current ServletContext of the web application used to find the context instance of {@link kf.KF}
	 * @throws Exception
	 */
	public KFWImage(String id, int siteId, ServletContext application) throws Exception {
		KF kf = KF.getKF(application, siteId);
		getImage(id, true, true, kf);
	}

	private void getImage(String id, boolean acc, boolean pro, HttpSession session) 
			throws Exception {
		KF kf = KF.getKF(session);
		getImage(id, acc, pro, kf);
	}
	
	private void getImage(String id, boolean acc, boolean pro, KF kf) 
			throws Exception {
		if (acc) stream = kf.getAccountDocumentPDF(id, pro);
		else stream = kf.getProjectDocumentPDF(id);
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
