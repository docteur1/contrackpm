package com.sinkluge.JSON;

import java.io.Serializable;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

import accounting.Accounting;
import accounting.Code;
import accounting.Company;
import accounting.Subcontract;
import accounting.Voucher;

import com.sinkluge.accounting.AccountingUtils;
import com.sinkluge.database.Database;

public class AccountingJSON implements Serializable {

	private static final long serialVersionUID = 1L;
	
	public static AccountingResult[] getCompanyByVoucher(HttpSession session, String id) throws Exception {
		Logger log = Logger.getLogger(AccountingJSON.class);
		log.debug("Find Account ID by Voucher");
		Database db = new Database();
		ArrayList<AccountingResult> ar = null;
		try {
			Accounting acc = AccountingUtils.getAccounting(session);
			Voucher voucher = acc.getVoucher(id);
			if (log.isDebugEnabled()) log.debug("Voucher (" + id + ") " + voucher);
			if (voucher != null) {
				Company company = acc.getCompany(voucher.getAccountCompanyId());
				if (company != null) {
					ar = new ArrayList<AccountingResult>();
					ar.add(new AccountingResult(company.getAccountId(), company.getName()));
				}
			}
		} catch (Exception e) {
			log.error("Exception Thrown", e);
		} finally {
			db.disconnect();
		}
		if (log.isDebugEnabled()) log.debug("Returning " + ar.size() + " results");
		if (ar == null || ar.size() == 0) return null;
		else return ar.toArray(new AccountingResult[0]);
	}
	
	public static AccountingResult[] getCompanyByContract(HttpSession session, int id) throws Exception {
		Logger log = Logger.getLogger(AccountingJSON.class);
		log.debug("Find Account ID by Contract " + id);
		Database db = new Database();
		ResultSet rs = db.dbQuery ("select cost_code_id from contracts where contract_id = " + id);
		ArrayList<AccountingResult> ar = null;
		if (rs.first()) {
			Code code = AccountingUtils.getCode(rs.getInt(1));
			if (code != null) {
				if (log.isDebugEnabled()) log.debug("Searching for contracts: " + code.getJobNum() + " " 
						+ code.getDivision() + " " + code.getCostCode());
				Accounting acc = AccountingUtils.getAccounting(session);
				List<Subcontract> subs = acc.getSubcontracts(code);
				if (subs != null && subs.size() > 0) {
					int index = 0;
					ar = new ArrayList<AccountingResult>();
					Company company;
					for (Iterator<Subcontract> i = subs.iterator(); i.hasNext(); index++) {
						company = acc.getCompany(i.next().getAltCompanyId());
						if (company != null) ar.add(new AccountingResult(company.getAccountId(), company.getName()));
					}
				}
			}
		}
		rs.getStatement().close();
		db.disconnect();
		if (log.isDebugEnabled() && ar != null) log.debug("Returning " + ar.size() + " results");
		if (ar == null || ar.size() == 0) return null;
		else return ar.toArray(new AccountingResult[0]);
	}
	
	public static AccountingResult[] getCompanyByOldContract(HttpSession session, int id) throws Exception {
		Logger log = Logger.getLogger(AccountingJSON.class);
		log.debug("Find Account ID by Old Contract " + id);
		Database db = new Database();
		ArrayList<AccountingResult> ar = null;
		ResultSet rs = db.dbQuery ("select company_id from contracts where contract_id = " + id);
		if (rs.first()) {
			int companyID = rs.getInt(1);
			rs.getStatement().close();
			rs = db.dbQuery("select cost_code_id from contracts where company_id = " + companyID
				+ " and contract_id != " + id + " order by contract_id desc limit 1");
			if (rs.first()) {
			Code code = AccountingUtils.getCode(rs.getInt(1));
				if (code != null) {
					Accounting acc = AccountingUtils.getAccounting(session);
					List<Subcontract> subs = acc.getSubcontracts(code);
					if (subs != null && subs.size() > 0) {
						int index = 0;
						ar = new ArrayList<AccountingResult>();
						Company company;
						for (Iterator<Subcontract> i = subs.iterator(); i.hasNext(); index++) {
							company = acc.getCompany(i.next().getAltCompanyId());
							if (company != null) ar.add(new AccountingResult(company.getAccountId(), company.getName()));
						}
					}
				}
			}
			rs.getStatement().close();
		}
		db.disconnect();
		if (log.isDebugEnabled()) log.debug("Returning " + ar.size() + " results");
		if (ar == null || ar.size() == 0) return null;
		else return ar.toArray(new AccountingResult[0]);
	}
	
	public static AccountingResult[] getCompanyByName(HttpSession session, String name) throws Exception {
		Logger log = Logger.getLogger(AccountingJSON.class);
		log.debug("Find Account ID by searching for company name: " + name);
		Database db = new Database();
		ArrayList<AccountingResult> ar = null;
		Company company = AccountingUtils.getAccounting(session).searchForCompany(name);
		if (company != null) {
			ar = new ArrayList<AccountingResult>();
			ar.add(new AccountingResult(company.getAccountId(), company.getName()));
		}
		db.disconnect();
		if (log.isDebugEnabled()) log.debug("Returning " + ar.size() + " results");
		if (ar == null || ar.size() == 0) return null;
		else return ar.toArray(new AccountingResult[0]);
	}
	
	public static void setCompanyAccountIdByContract(HttpSession session, String id, int contractId) 
			throws Exception {
		Logger log = Logger.getLogger(AccountingJSON.class);
		Database db = new Database();
		if (log.isDebugEnabled()) log.debug("Set account ID: " + id);
		AccountingUtils.setCompanyIdByContract(contractId, id);
		Subcontract sub = AccountingUtils.getSubcontract(contractId);
		// Now update or create the contract
		AccountingUtils.getAccounting(session).updateSubcontract(sub);
		db.disconnect();
	}

	public static boolean doCompaniesMatch(HttpSession session, int prID, String accountID) throws Exception {
		Logger log = Logger.getLogger(AccountingJSON.class);
		log.debug("Searching for companyID match pr_id " + prID + " account ID " + accountID);
		Database db = new Database();
		boolean result = false;
		ResultSet rs = db.dbQuery("select cai.account_id from pay_requests join contracts using(contract_id) " +
				"join job using(job_id) join company_account_ids as cai on contracts.company_id = cai.company_id " +
				"and job.site_id = cai.site_id where pr_id = " + prID);
		if (rs.first()) {
			Voucher voucher = AccountingUtils.getAccounting(session).getVoucher(accountID);
			result = rs.getString(1).equals(voucher.getAccountCompanyId());
			log.debug("Companies match? " + result + " " + voucher.getAccountCompanyId());
		} else {
			result = true;
			log.debug("Company ID not found...");
		}
		rs.getStatement().close();
		rs = null;
		db.disconnect();
		return result;
	}

}
