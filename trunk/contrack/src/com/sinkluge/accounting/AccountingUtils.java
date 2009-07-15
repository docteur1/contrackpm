package com.sinkluge.accounting;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import kf.KF;
import kf.client.Document;

import org.apache.log4j.Logger;

import accounting.Accounting;
import accounting.CR;
import accounting.CRD;
import accounting.Code;
import accounting.Subcontract;
import accounting.VoucherAttachment;

import com.sinkluge.Info;
import com.sinkluge.User;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.security.Name;
import com.sinkluge.security.Permission;
import com.sinkluge.security.Security;

public class AccountingUtils {

	public static Logger getLogger() {
		return Logger.getLogger(AccountingUtils.class);
	}
	
	private static Accounting getAccounting(String className) throws Exception {
		Accounting acc = null;
		try {
			acc = (Accounting) Class.forName(className).newInstance();
		} catch (ClassNotFoundException e) {
			throw new ClassNotFoundException("acc_classname: " + className
				+ " was not found. Please specify a valid subclass of accounting.Accounting", e);
		}
		return acc;
	}
	
	/**
	 * Returns <code>Accounting</code> associated with the <code>ServletContext</code> and the siteId.<p>
	 * This creates a <code>Attributes</code> instance so it is more desirable to use 
	 * {@link #getAccounting(ServletContext, Attributes)} when possible.</p>
	 * @param sc			<code>ServletContext</code> holding or to hold <code>Accounting</code> object
	 * @param siteId		<code>siteId</code> (<code>Attributes</code>)
	 * @return				<code>Accounting</code> object associated with the <code>ServletContext</code> and 
	 * 						 	<code>siteId</code>
	 * @throws Exception
	 */
	public static Accounting getAccounting(ServletContext sc, int siteId) throws Exception {
		Accounting acc = (Accounting) sc.getAttribute("acc" + siteId);
		if (acc == null) {
			Attributes attr = new Attributes(siteId);
			acc = getAccounting(sc, attr);
			attr.close();
		}
		return acc;
	}
	
	/**
	 * @param sc			<code>ServletContext</code> holding or to hold <code>Accounting</code> object
	 * @param attr			<code>Attributes</code> (<code>siteId</code>)
	 * @return				<code>Accounting</code> object associated with the <code>ServletContext</code> and 
	 * 						 	<code>Attributes</code> (<code>siteId</code>)
	 * @throws Exception
	 */
	public static Accounting getAccounting(ServletContext sc, Attributes attr) throws Exception {
		Accounting acc = null;
		if (attr != null && attr.hasAccounting()) {
			Logger log = getLogger();
			if (log.isDebugEnabled()) log.debug("getting acc for site: " + attr.getSiteId());
			acc = (Accounting) sc.getAttribute("acc" + attr.getSiteId());
			if (acc == null) {
				acc = getAccounting(attr);
				sc.setAttribute("acc" + attr.getSiteId(), acc);
			} else acc.prepareForAccess();
		}
		return acc;
	}
	
	/**
	 * The actual method to generate <code>Accounting</code> objects.
	 * @param attr
	 * @return
	 * @throws Exception
	 */
	private static Accounting getAccounting(Attributes attr) throws Exception {
		Accounting acc = null;
		Logger log = getLogger();
		if (attr.hasAccounting()) {
			if (log.isDebugEnabled()) log.debug("Opening connection to " + attr.get("acc_endpoint"));
			acc = getAccounting(attr.get("acc_classname"));
			// Let's not use the session database...
			acc.setInitParameters(attr.get("acc_endpoint"), 
				attr.get("acc_username"), attr.get("acc_password"), attr.getSiteId());
		} else {
			log.debug("No accounting found!");
		}
		return acc;
	}
	
	/**
	 * @param session		Client Session
	 * @return				<code>Accounting</code> object associated with current session <code>Attributes</code> 
	 * 						(<code>siteId</code>) stored in the ServletContext.
	 * @throws Exception
	 */
	public static Accounting getAccounting(HttpSession session) throws Exception {
		Attributes attr = (Attributes) session.getAttribute("attr");
		Accounting acc = null;
		if (attr.hasAccounting())
			acc = getAccounting(session.getServletContext(), attr);
		return acc;
	}
	
	public static Code getCode (String id) {
		return getCode(Integer.parseInt(id));
	}
	
	public static Code getCode (long id) {
		Code code = null;
		ResultSet rs = null;
		Database db = new Database();
		try {
			String query = "select job_num, division, cost_code, phase_code, code_description, budget from job_cost_detail "
				+ "join job using(job_id) where cost_code_id = " + id;
			rs = db.dbQuery(query);
			if (rs.first()) {
				code = new Code();
				code.setJobNum(rs.getString("job_num"));
				code.setPhaseCode(rs.getString("phase_code"));
				code.setDivision(rs.getString("division"));
				code.setCostCode(rs.getString("cost_code"));
				code.setName(rs.getString("code_description"));
				code.setAmount(rs.getDouble("budget"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return code;
	}
	
	private static String getAltCompanyId(int id, int siteId) {
		ResultSet rs = null;
		String accountId = null;
		Database db = new Database();
		try {
			rs = db.dbQuery("select account_id from company_account_ids where company_id = " 
					+ id + " and site_id = " + siteId);
			if (rs.next()) accountId = rs.getString(1);
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return accountId;
	}
	
	public static Subcontract getSubcontract(ResultSet rs, int siteId) throws SQLException {
		Subcontract data = null;
		Code code = getCode(rs.getLong("cost_code_id"));
		if (code != null) {
			data = new Subcontract();
			data.setCompanyId(rs.getInt("company_id"));
			data.setAltCompanyId(getAltCompanyId(data.getCompanyId(), siteId));
			data.setAltContractId(rs.getString("altContractId"));
			data.setCode(code);
			data.setAmount(rs.getDouble("amount"));
			data.setContractId(rs.getInt("contract_id"));
			data.setText(rs.getString("description"));
			data.setRetention(rs.getDouble("retention_rate"));
			data.setDescription(code.getName());
			data.setDate(rs.getDate("agreement_date"));
		}
		return data;
	}
	
	public static CRD getCRD(String id, Accounting acc) {
		return getCRD(id, null, acc);
	}
	
	public static CRD getCRD(String id, CR cr, Accounting acc) {
		CRD crd = null;
		Logger log = getLogger();
		String sql = "select crd.*, job_num, company_name from change_request_detail as crd join "
			+ "contracts using(contract_id) join company using(company_id) join job on "
			+ "crd.job_id = job.job_id where crd_id = " + id;
		log.debug("Performing: " + sql);
		ResultSet rs = null;
		Database db = new Database();
		try {
			rs = db.dbQuery(sql);
			if (rs.first()) {
				log.debug("Found crd_id: " + rs.getString("crd_id"));
				crd = new CRD();
				if (rs.getInt("cr_id") != 0) {
					if (cr == null) cr = getCr(rs.getString("cr_id"));
					crd.setBudget(rs.getDouble("amount"));
					if (acc != null) {
						crd.setOwner(acc.getCRDOwner(id));
					} else crd.setOwner(0);
					crd.setCrNum(cr.getNum());
				}
				crd.setContract(rs.getDouble("amount"));
				crd.setCode(getCode(rs.getInt("cost_code_id")));
				crd.setText(rs.getString("work_description"));
				crd.setDate(rs.getDate("created"));
				if (rs.getInt("contract_id") != 0) {
					if (log.isDebugEnabled()) log.debug("looking up contract with id: " 
							+ rs.getInt("contract_id"));
					crd.setSub(getSubcontract(rs.getInt("contract_id")));
					if (cr == null) crd.setCaNum(rs.getString("change_auth_num"));
					crd.setApproved(rs.getBoolean("authorization"));
					crd.setSubCANum(rs.getInt("sub_ca_num"));
				}
			}
		} catch (NullPointerException e) {
			log.error("getCRD: NullPointerException caught", e);
		} catch (SQLException e) {
			log.error(e.getMessage(), e);
		} catch (Exception e) {
			log.error(e.getMessage(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return crd;
	}
	
	public static CR getCr(String id) {
		CR cr = null;
		String sql = "select cr.*, co_num, job_num, company_name from change_requests as cr left join "
			+ "change_orders as co using(co_id) left join job on cr.job_id = job.job_id "
			+ "left join job_contacts as jc on cr.to_id = jc.job_contact_id left join company "
			+ "using(company_id) where cr_id = " + id;
		ResultSet rs = null;
		Database db = new Database();
		try {
			rs = db.dbQuery(sql);
			if (rs.first()) {
				cr = new CR();
				cr.setApprovedDate(rs.getDate("approved_date"));
				cr.setCoNum(rs.getString("co_num"));
				cr.setDate(rs.getDate("date"));
				cr.setDescription(rs.getString("description"));
				cr.setJobNum(rs.getString("job_num"));
				cr.setNum(rs.getString("num"));
				cr.setRecipient(rs.getString("company_name"));
				User user = User.getUser(rs.getInt("signed_id"));
				cr.setSigner(user.getFullName());
				cr.setSubmitDate(rs.getDate("submit_date"));
				cr.setTitle(rs.getString("title"));
			}
		} catch (Exception e) {
			getLogger().error(e.getMessage(), e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return cr;
	}
	
	public static Subcontract getSubcontract(int contractId) {
		Subcontract data = null;
		ResultSet rs = null;
		Database db = new Database();
		try {
			String query = "select cost_code_id, altContractId, contracts.retention_rate, contracts.description, contract_id, company.company_id, agreement_date, amount, site_id "
				+ "from contracts join company using(company_id) join job on job.job_id = contracts.job_id where contract_id = " + contractId;
			rs = db.dbQuery(query);
			if (rs.first()) data = getSubcontract(rs, rs.getInt("site_id"));
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return data;
	}
	
	public static boolean companyNeedsIDByContract (int contractID) throws SQLException {
		Database db = new Database();
		ResultSet rs = db.dbQuery("select account_id from contracts as cn join job using(job_id) " +
				"join company_account_ids as cai on cai.company_id = cn.company_id and job.site_id = " +
				"cai.site_id where contract_id = " + contractID);
		boolean result = !rs.isBeforeFirst();
		rs.getStatement().close();
		db.disconnect();
		rs = null;
		return result;
	}
	
	public static String getCompanyNameByContract (int contractID) throws SQLException {
		Database db = new Database();
		ResultSet rs = db.dbQuery("select company_name from company join contracts using(company_id)"
				+ " where contract_id = " + contractID);
		String result = "ERROR!";
		if (rs.first()) result = rs.getString(1);
		rs.getStatement().close();
		db.disconnect();
		rs = null;
		return result;
	}
	
	public static void setCompanyIdByContract(int contractId, String accountId) throws Exception {
		Database db = new Database();
		ResultSet rs = db.dbQuery("select company_id, site_id from contracts join job using(job_id) where "
				+ "contract_id = " + contractId);
		if (rs.first()) setCompanyId(rs.getInt("company_id"), accountId, rs.getInt("site_id"));
		rs.getStatement().close();
		rs = null;
	}
	
	public static void setCompanyId(int id, String accountId, int siteId) 
			throws SQLException {
		Logger log = Logger.getLogger(AccountingUtils.class);
		Database db = new Database();
		if (log.isDebugEnabled()) log.debug("Setting account ID: " + accountId + " for " + id + " on site " + siteId);
		if (db.dbInsert("update company_account_ids set account_id = '" + accountId + "' where site_id = "
				+ siteId + " and company_id = " + id) == 0) {
			log.debug("Could not find company id record... creating record");
			if (db.dbInsert("insert ignore into company_account_ids (company_id, site_id, account_id) " +
				"values (" + id + ", " + siteId + ", '" + accountId + "')") != 1)
				log.warn("Could not set account ID: " + accountId + " for " + id + " on site " + siteId);
		}
		db.disconnect();
	}
	
	public static int countDocuments(String id, HttpSession session) throws Exception {
		Security sec = (Security) session.getAttribute("sec");
		boolean accPermission = sec.ok(Name.ACCOUNTING, Permission.READ);
		int count = 0;
		if (sec.ok(Name.ACCOUNTING_DATA, Permission.READ)) {
			List<Document> docs;
			List<VoucherAttachment> vas;
			Accounting acc = AccountingUtils.getAccounting(session);
			KF kf = null;
			Info in = (Info) session.getServletContext().getAttribute("in");
			if (in.hasKF) kf = KF.getKF(session);
			if (kf != null) {
				docs = kf.getAccountDocuments(id, accPermission);
				if (docs != null) {
					count = docs.size();
					docs.clear();
				}
			}
			if (acc.hasDocuments()) {
				vas = acc.getVoucherAttachments(id);
				if (vas != null) {
					count += vas.size();
					vas.clear();
				}
			}
		}
		return count;
	}
}
