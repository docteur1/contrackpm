package com.sinkluge;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletContext;

import kf.KF;
import kf.client.Document;
import kf.client.Documentvalue;
import kf.client.Project;
import kf.client.Projectfield;

import org.apache.cayenne.exp.Expression;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.SelectQuery;
import org.apache.log4j.Logger;

import accounting.Accounting;
import accounting.Check;
import accounting.Code;
import accounting.Voucher;
import accounting.VoucherDistribution;

import com.sinkluge.accounting.AccountingUtils;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public class CacheAndIndexService implements Runnable, java.io.Serializable {
	
	private static final long serialVersionUID = 1L;
	private ServletContext sc;
	private String msg = "";
	
	private boolean running  = true;
	
	public boolean isRunning() {
		return running;
	}
	
	public String getLog() {
		return msg;
	}

	public CacheAndIndexService(ServletContext sc) {
		this.sc = sc;
	}
	
	private Logger log = Logger.getLogger(CacheAndIndexService.class);
	
	
	public void log(Object log) {
		this.log.debug(log);
		msg += log.toString() + "\n";
	}
	
	public void log(Object log, Throwable t) {
		this.log.error(log, t);
		msg += log.toString() + "\nERROR: " + t.getMessage() + "\n";
	}
	
	@SuppressWarnings("unchecked")
	public void run() {
		running = true;
		msg = "";
		log("Beginning Indexer");
		Database db = null;
		ResultSet rs = null;
		Accounting acc = null;
		Attributes attr = null;
		KF kf = null;
		Info in = null;
		try {
			db = new Database();
			String sql = "select site_id from sites";
			rs = db.dbQuery(sql);
			Projectfield pf;
			Project p;
			Expression e;
			Document d;
			Iterator<Documentvalue> j;
			List<Check> checks;
			List<Document> docList;
			Iterator<Document> docs;
			List<Documentvalue> dvs = null;
			Iterator<Check> k;
			List<Voucher> vs;
			List<VoucherDistribution> vds;
			HashMap<String, Documentvalue> hm = new HashMap<String, Documentvalue>();
			Documentvalue dv;
			String voucherID;
			String venID;
			String checkID;
			String poID;
			String jobId;
			@SuppressWarnings("unused")
			String protectedID;
			//String key;
			Voucher v;
			Check c;
			Code code;
			Integer siteID;
			List<Integer> sites = new ArrayList<Integer>();
			while (rs.next()) {
				sites.add(rs.getInt(1));
			}
			rs.getStatement().close();
			rs = null;
			for(Iterator<Integer> i = sites.iterator(); i.hasNext(); ) {
				siteID = i.next();
				log("Processing site id: " + siteID);
				attr = new Attributes(siteID);
				if (attr.hasAccounting()) {
					// Update KF
					acc = AccountingUtils.getAccounting(sc, attr);
					if ("1".equals(attr.get("kf_update_index"))) {
						in = (Info) sc.getAttribute("in");
						if (acc == null) throw new Exception ("No accounting found!");
						kf = new KF(in, attr);
						voucherID = attr.get("kf_acc_field_id");
						venID = attr.get("kf_acc_field_vendor_id");
						checkID = attr.get("kf_acc_field_check_id");
						poID = attr.get("kf_acc_field_po_id");
						protectedID = attr.get("kf_acc_pro_field_id");
						pf = (Projectfield) kf.getObject("Projectfield", "FieldID", voucherID);
						if (pf != null) {
							p = pf.getProject();
							if (p != null) {
								e = ExpressionFactory.matchExp(Document.NEEDS_UPDATE_PROPERTY, true);
								docList = (List<Document>) kf.query(new SelectQuery(Document.class, e));
								for (docs = docList.iterator(); docs.hasNext(); ) {
									d = docs.next();
									log("Analyzing Document ID: " + d.getDocumentID());
									hm.clear();
									dvs = d.getDocumentvalues();
									for(j = dvs.iterator(); j.hasNext(); ) {
										dv = (Documentvalue) j.next();
										hm.put(dv.getFieldID().toString(), dv);
									}
									if (has(hm, voucherID)) {
										log("Has voucher #" 
												+ get(hm, voucherID) + "#");
										/*
										 * first add the link... if we are here we have the voucher id
										 * 
										 * Just when Computer Ease could not get any lamer... it does
										 * Unforetunately, I can't write to the attachments table
										 * for some reason this is blocked :(
										 */
										/*
										rs = db.dbQuery("select * from kfw_links where document_id = " 
											+ d.getDocumentID(), true);
										if (rs.first()) key = rs.getString("document_key");
										else key = RandomStringUtils.randomAlphanumeric(30);
										acc.addVoucherLink(get(hm, voucherID), d.getDocumentID(), key, in.site_url);
										if (!rs.first()) {
											rs.moveToInsertRow();
											rs.updateLong("document_id", d.getDocumentID());
											rs.updateString("document_key", key);
											rs.updateString("site_id", siteID);
											rs.insertRow();
										}
										rs.getStatement().close();
										rs = null;
										*/
										if (has(hm, venID) && has(hm, checkID)) d.setNeedsUpdate(false);
										else {
											log("Missing check # or vendor #");
											if (acc == null) log("Lost acc");
											v = acc.getVoucher(get(hm, voucherID));
											log("Acc Voucher: " + v);
											if (v != null) {
												dv = hm.get(venID);
												if (dv != null) {
													dv.setFieldValue(v.getAccountCompanyId());
													log("Updated document with vennum");
													log(dv);
												}
												dv = hm.get(poID);
												if (dv != null) {
													dv.setFieldValue(v.getPoNum());
													log("Updated document with ponum");
												}
												dv = hm.get(checkID);
												if (dv != null) {
													checks = v.getChecks();
													if (checks != null && checks.size() == 1) {
														for (k = checks.iterator(); j.hasNext(); ) {
															c = k.next();
															dv.setFieldValue(Integer.toString(c.getCheckNum()));
														}
														log("Updated document checknum");
														d.setNeedsUpdate(false);
														checks.clear();
														checks = null;
													}
													log(dv);
												}
											}
											v = null;
										}
									} else d.setNeedsUpdate(false);
									kf.commit();	
								}
								if (dvs != null) {
									dvs.clear();
									dvs = null;
								}
								docList.clear();
								docList = null;
							}
							
						}
					
						vs = acc.getRoutedVouchers();
						for (Iterator<Voucher> vsi = vs.iterator(); vsi.hasNext();) {
							v = vsi.next();
							vds = v.getVoucherDistributions();
							code = vds.get(0).getCode();
							rs = db.dbQuery("select job.job_id from job_cost_detail as jcd "
								+ "join job using(job_id) where job_num = '" + code.getJobNum()
								+ "' and division = '" + code.getDivision() + "' and "
								+ "phase_code = '" + code.getPhaseCode() + "'");
							if (rs.first()) {
								jobId = rs.getString(1);
								rs.getStatement().close();
								rs = db.dbQuery("select * from suspense_cache where "
									+ "voucher_id = " + v.getId() + " and job_id = " + jobId, true);
								if (!rs.first()) rs.moveToInsertRow();
								rs.updateString("job_id", jobId);
								rs.updateString("voucher_id", v.getId());
								rs.updateString("company", v.getName());
								rs.updateString("po_num", v.getPoNum());
								rs.updateString("invoice_num", v.getInvoiceNum());
								rs.updateDate("voucher_date", new java.sql.Date(v.getDate().getTime()));
								rs.updateDouble("amount", v.getAmount());
								rs.updateString("description", v.getDescription());
								rs.updateBoolean("updated", true);
								try {
									if (rs.isFirst()) rs.updateRow();
									else rs.insertRow();
								} catch (SQLException t) {
									log("error writing to cache", t);
								}
							}
							rs.getStatement().close();
							rs = null;
							vds.clear();
						}
						vs.clear();
					} else log("Site updates not enabled for site " + siteID);
				} else log("Site doesn't have accounting site id " + siteID);
			} // run through sites
			sites.clear();
			sites = null;
			/* Delete the non-updated entries in the suspense cache
			 * This is how Contrack detects items that may not exist in the
			 * accounting database */
			sql = "delete from suspense_cache where updated = 0";
			log("Deleted " + db.dbInsert(sql) + " entries in the suspense cache");
			// change the flag for the next round.
			sql = "update suspense_cache set updated = 0";
			db.dbInsert(sql);
		} catch (SQLException e) {
			log("KFIndex error", e);
		} catch (Exception e) {
			log("KFIndex error", e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
				if (db != null) db.disconnect();
				db = null;
			} catch (SQLException e) {}
			log.debug("Finished running KFIndexer");
			running = false;
		}
	}

	private static String get(HashMap<String, Documentvalue> hm, String id) {
		try {
			return hm.get(id).getFieldValue();
		} catch (NullPointerException e) {
			return "";
		}
	}
	
	private static boolean has(HashMap<String, Documentvalue> hm, String id) {
		return !"".equals(get(hm, id));
	}
	
}
