package com.sinkluge.reports.contracts;

import java.sql.ResultSet;

import com.lowagie.text.Image;
import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.reports.Report;
import com.sinkluge.reports.CombinedReport;
import com.sinkluge.reports.ReportContact;

public class GenSubcontractAllDocs extends CombinedReport {
	
	private String addDays;
	private Database db;
	private Attributes attr;
	private Info in;
	private Image logo;
	
	public void doCleanup(Database db) {}
	
	public ReportContact getReportContact(String id, Database db) {
		String query = "select contact_id, company_id from contracts "
			+ "where contract_id = " + id;
		ResultSet rs = null;
		ReportContact rp = new ReportContact();
		try {
			rs = db.dbQuery(query);
			if (rs.next()) {
				if (rs.getInt(1) != 0) {
					rp.setContactId(rs.getInt(1));
					rp.setCompanyId(rs.getInt(2));
				} else rp.setCompanyId(rs.getInt(2)); 
			}
		} catch (Exception e) {
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
			} catch (Exception e) {}
		}
		return rp;
	}
	
	public GenSubcontractAllDocs (String contract_id, String addDays, Database db, Attributes attr) throws Exception{
		id = contract_id;
		type = Type.SUBCONTRACT;
		this.db = db;
		this.addDays = addDays;
		this.attr = attr;
	}//constructor
	
	public void create(Info in, Image logo) throws Exception {
		this.in = in;
		this.logo = logo;
		stream = null;
		//d.connect();
		//Create contract checklist
		Report r = createContractChecklist();
		add(r);
		
		//Create contract worksheet
		r = createContractWorksheet();
		add(r);
		
		//Submittal Form
		r = createSubmittal();
		add(r);
		
		//Add Summary
		r = createSummary();
		add(r);
		
	}
	
	private Report createContractChecklist() throws Exception {
		ResultSet rs = db.dbQuery(GenContractChecklist.getQuery(id));
		rs.first();
		ResultSet rs2 = db.dbQuery(GenContractChecklist.getQuery2(id));
		rs2.first();
		Report g = new GenContractChecklist(rs.getString(1), attr.getJobName(), addDays, 
			rs2.getString("contract_title"), rs2.getString("contractee_title"), 
			rs2.getBoolean("site_work"), attr.get("short_name"), id);
		g.create(in, logo);
		// Now append that to the existing document...
		rs.getStatement().close();
		rs = null;
		rs2.getStatement().close();
		rs2 = null;
		return g;
	}
	
	private Report createContractWorksheet() throws Exception {
		Report g = new GenSubcontractWorksheet(id, db, attr.get("short_name"));
		g.create(in, null);
		return g;
	}
	
	private Report createSubmittal() throws Exception {
		Report g = new GenSubSubmittal(id, db, attr);
		g.create(in, logo);
		return g;
	}
	
	private Report createSummary() throws Exception {
		Report g = new GenSubJobsiteSummary(id, db, attr.get("short_name"), attr.get("full_name"));
		g.create(in, logo);
		return g;
	}
}
