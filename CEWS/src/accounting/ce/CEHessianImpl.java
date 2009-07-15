package accounting.ce;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.caucho.hessian.server.HessianServlet;
import com.sinkluge.CEDatabase;

import accounting.Action;
import accounting.CR;
import accounting.CRD;
import accounting.Code;
import accounting.Result;
import accounting.Route;
import accounting.Subcontract;
import accounting.VoucherAttachment;

public class CEHessianImpl extends HessianServlet implements CEHessian {

	private static final long serialVersionUID = 3L;
	
	final static private int JC_DETAIL_COMMITTED = 20;
	final static private int JC_DETAIL_COMMITT_BILL = 22;
	final static private int JC_CO_STEP_SENT = 100;
	final static private int JC_CO_STEP_INITIATED = 1;
	final static private int JC_CO_STEP_APPROVED = 20;
	final private int JC_DETAIL_CO_TYPE = 19;
	final private int JC_DETAIL_CHANGE_OFFSET = 32;
	
	final private int AP_VOUCHER_ROUTE_PENDING = 2;
	final private int AP_VOUCHER_ROUTE_APPROVED = 1;
	final private int AP_VOUCHER_ROUTE_REJECTED = 3;
	
	private CEDatabase cdb = null;
	private Logger log = Logger.getLogger(CEHessianImpl.class);
	
	public CEHessianImpl() throws Exception {
		cdb = new CEDatabase();
	}
	
	public Result updateSubcontract(Subcontract sub, int costtype) throws SQLException {
		return updateSubcontractDetail(sub, null, null, costtype, null, null, true);
	}
	
	private Result updateSubcontractDetail(Subcontract sub, String oldrfc, String rfc, int costtype,
			String co, String jobrfc, boolean approved) throws SQLException {
		Result result = new Result(Action.NO_ACTION);
		ResultSet rs = getSubitem(sub, oldrfc);
		boolean created = false;
		int jcunique = 0;
		String subnum = null;
		if (!rs.first()) {
			rs.moveToInsertRow();
			created = true;
			log.debug("Creating subitem");
			result = new Result(Action.CREATED);
			subnum = sub.getAltContractId() == null ? Integer.toString(sub.getContractId())
				: sub.getAltContractId();
			rs.updateString("subnum", subnum);
			ResultSet jcu = cdb.dbQuery("select * from jcunique where id = 0", true);
			if (jcu.first()) {
				jcunique = jcu.getInt("lastused") + 1;
				jcu.updateInt("lastused", jcunique);
				jcu.updateRow();
			}
			if (jcu != null) jcu.getStatement().close();
		} else {
			result = new Result(Action.UPDATED);
			subnum = rs.getString("subnum");
			jcunique = rs.getInt("jcunique");
			log.debug("Found subitem: " + subnum);
		}
		rs.updateInt("sequence", 1);
		Code code = sub.getCode();
		rs.updateString("rfcnum", rfc);
		rs.updateString("jobnum", code.getJobNum());
		rs.updateString("phasenum", code.getDivision());
		rs.updateString("catnum", code.getCostCode());
		rs.updateString("des", sub.getDescription());
		rs.updateInt("flatprice", 1);
		rs.updateDouble("amount", sub.getAmount());
		rs.updateInt("costtype", costtype);
		rs.updateInt("jcunique", jcunique);
		if (created) rs.insertRow();
		else rs.updateRow();
		if (rs != null) rs.getStatement().close();
		rs = cdb.dbQuery("select * from subheader where subnum = '" + subnum + "' and "
			+ getRfcQuery(oldrfc), true);
		created = false;
		if (!rs.first()) {
			rs.moveToInsertRow();
			created = true;
		}
		rs.updateString("subnum", subnum);
		rs.updateString("rfcnum", rfc);
		rs.updateString("jobnum", code.getJobNum());
		rs.updateString("vennum", sub.getAltCompanyId());
		rs.updateString("des", sub.getDescription());
		rs.updateString("contracttext", sub.getText());
		log.debug("updateSubcontractDetail: conum->" + co);
		rs.updateString("conum", co);
		rs.updateString("jobrfcnum", jobrfc);
		rs.updateDate("entereddate", (java.sql.Date) sub.getDate());
		rs.updateDate("contractdate", (java.sql.Date) sub.getDate());
		if (approved) {
			rs.updateDate("approveddate", (java.sql.Date) sub.getDate());
			rs.updateInt("approved", 1);
		} else {
			rs.updateDate("approveddate", null);
			rs.updateInt("approved", 0);
		}
		log.debug("Setting retention: " + sub.getRetention() * 100);
		rs.updateDouble("retentionpct", sub.getRetention() * 100);
		rs.updateDouble("contracttotal", sub.getAmount());
		if (created) rs.insertRow();
		else rs.updateRow();
		if (rs != null) rs.getStatement().close();
		result.setId("jcunique", Integer.toString(jcunique));
		result.setId("altContractId", subnum);
		if (log.isDebugEnabled()) 
			log.debug(result.getAction() + " subcontract using jcunique: " + result.getId("jcunique") 
				+ " and altContractId: " + result.getId("altContractId"));
		updateCommittedCosts(subnum, jcunique, sub, true);
		return result;
	}
	
	public Result deleteSubcontract(Subcontract sub) throws SQLException {
		return deleteSubcontractDetail(sub, null);
	}
		
	private Result deleteSubcontractDetail(Subcontract sub, String rfc) throws SQLException {
		Result result = new Result(Action.NO_ACTION);
		ResultSet rs = getSubitem(sub, null);
		if (rs.first()) {
			// Is it empty?
			String subnum = rs.getString("subnum");
			if (rs != null) rs.getStatement().close();
			rs = null;
			ResultSet temp = cdb.dbQuery("select count(*) from subpayment where subnum = '" +
				subnum + "'" + getRfcQuery2(rfc));
			int count = 0;
			if (temp.first()) count = temp.getInt(1);
			temp.getStatement().close();
			temp = cdb.dbQuery("select count(*) from subinvoice where subnum = '" + subnum + 
				"'" + getRfcQuery2(rfc));
			if (temp.first()) count += temp.getInt(1);
			temp.getStatement().close();
			if (count > 0) {
				cdb.disconnect();
				return new Result(Action.BLOCKED, 
					"Invoices and/or payments are associated with this " + (rfc == null ? "subcontract" :
					"change authorization") + " in ComputerEase." +
					"\nThis " + (rfc == null ? "subcontract" :
					"change authorization") + " must first be deleted from ComputerEase.");
			}
			// Zero out the committed costs...
			sub.setAmount(0d);
			temp = cdb.dbQuery("select jcunique from subitem where subnum = '" + subnum + "'" +
				getRfcQuery2(rfc));
			while (temp.next()) {
				updateCommittedCosts(subnum, temp.getInt(1), sub, false);
			}
			temp.getStatement().close();
			int del = cdb.dbInsert("delete from subheader where subnum = '" + subnum + "'" + getRfcQuery2(rfc));
			if (del > 0) {
				del = cdb.dbInsert("delete from subitem where subnum = '" + subnum + "'"  + getRfcQuery2(rfc));
				result = new Result(Action.DELETED);
			}
		} else result = new Result(Action.NOT_FOUND, 
			"Unable to delete, subcontract not found in ComputerEase database");
		if (rs != null) rs.getStatement().close();
		cdb.disconnect();
		return result;
	}
	
	private void updateCommittedCosts(String subnum, int jcunique, Subcontract sub, boolean closeDb) throws SQLException {
		ResultSet rs = cdb.dbQuery("select name from vendor where vennum = '" + sub.getAltCompanyId() + "'");
		String who = "Unknown";
		if (rs.first()) who = rs.getString(1);
		rs.getStatement().close();
		rs = cdb.dbQuery("select * from jcdetail where jcunique = " 
			+ jcunique + " and ponum = '" + subnum + "' and type = " + JC_DETAIL_COMMITTED, true);
		if (!rs.isBeforeFirst()) {
			insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITTED, who, sub, rs);
			insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITT_BILL, who, sub, rs);
		} else {
			String phasenum, catnum;
			Code code = sub.getCode();
			boolean found = false;
			while (rs.next()) {
				phasenum = rs.getString("phasenum");
				catnum = rs.getString("catnum");
				if (phasenum.equals(code.getDivision()) && catnum.equals(code.getCostCode())) {
					rs.updateDouble("cost", sub.getAmount());
					rs.updateString("who", who);
					found = true;
				}
				else rs.updateDouble("cost", 0); 
				rs.updateDate("dateposted", new java.sql.Date(System.currentTimeMillis()));
				rs.updateRow();
			}
			// not found on our code insert it.
			if (!found) insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITTED, who, sub, rs);
			rs.getStatement().close();
			// Now we got to do committ bill.
			rs = cdb.dbQuery("select phasenum, catnum, sum(cost) as amount from jcdetail where jcunique = " 
				+ jcunique + " and ponum = '" + subnum + "' and type = " + JC_DETAIL_COMMITT_BILL 
				+ " group by phasenum, catnum"	, true);
			double amount;
			Code oc;
			found = false;
			while (rs.next()) {
				phasenum = rs.getString("phasenum");
				catnum = rs.getString("catnum");
				amount = rs.getDouble("amount");
				if (phasenum.equals(code.getDivision()) && catnum.equals(code.getCostCode())) {
					found = true;
					if (log.isDebugEnabled()) 
						log.debug("found committed billing amount: " + amount + " new: " + sub.getAmount() +
							" insert neg amount? " + (amount > sub.getAmount()));
					if (amount > sub.getAmount())
						insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITT_BILL, who, sub,  
							-(amount - sub.getAmount()));
					else if (sub.getAmount() > amount) 
						insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITT_BILL, who, sub,  
							sub.getAmount() - amount);
				} else if (amount != 0) {
					log.debug("Non zero amount on unexpected code committed billing cost, zeroing");
					oc = new Code();
					oc.setJobNum(code.getJobNum());
					oc.setCostCode(catnum);
					oc.setDivision(phasenum);
					insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITT_BILL, who, sub, -amount, oc);
				}
			}
			if (!found) insertCommittedCost(subnum, jcunique, JC_DETAIL_COMMITT_BILL, who, sub);
		}
		rs.getStatement().close();
		if (closeDb) cdb.disconnect();
	}
	
	private void insertCommittedCost(String subnum, int jcunique, int type, String who, Subcontract sub)
			throws SQLException {
		insertCommittedCost(subnum, jcunique, type, who, sub, sub.getAmount());
	}
	
	private void insertCommittedCost(String subnum, int jcunique, int type, String who, Subcontract sub, 
			double amount)throws SQLException {
		insertCommittedCost(subnum, jcunique, type, who, sub, amount, sub.getCode());
	}
	
	private void insertCommittedCost(String subnum, int jcunique, int type, String who, Subcontract sub,
			double amount, Code code) throws SQLException {
		ResultSet rs = cdb.dbQuery("select * from jcdetail where serialnum = 0", true);
		insertCommittedCost(subnum, jcunique, type, who, sub, rs, amount, code);
		rs.getStatement().close();
	}
	
	private void insertCommittedCost(String subnum, int jcunique, int type, String who, Subcontract sub, 
			ResultSet rs) throws SQLException {
		insertCommittedCost(subnum, jcunique, type, who, sub, rs, sub.getAmount(), sub.getCode());
	}
	
	private void insertCommittedCost(String subnum, int jcunique, int type, String who, Subcontract sub, 
			ResultSet rs, double amount, Code code) throws SQLException {
		rs.moveToInsertRow();
		rs.updateString("jobnum", code.getJobNum());
		rs.updateString("catnum", code.getCostCode());
		rs.updateString("phasenum", code.getDivision());
		rs.updateInt("type", type);
		rs.updateInt("jcunique", jcunique);
		rs.updateString("des1", sub.getDescription());
		if (type == JC_DETAIL_COMMITTED) rs.updateInt("minortype", 1);
		else rs.updateInt("minortype", 0);
		rs.updateDate("date", (java.sql.Date) sub.getDate());
		rs.updateDate("datePosted", new java.sql.Date(System.currentTimeMillis()));
		rs.updateDouble("cost" , amount);
		rs.updateString("ponum", subnum);
		rs.updateString("who", who);
		if (log.isDebugEnabled()) log.debug("Inserted committed cost jcunique: " + jcunique
			+ " ponum: " + subnum + " amount: " + amount);
		rs.insertRow();
	}
	
	private String getRfcQuery(String rfcnum) {
		return rfcnum == null ? "rfcnum is null" : "rfcnum = '" + rfcnum + "'";
	}
	
	private String getRfcQuery2(String rfcnum) {
		return rfcnum == null ? "" : " and rfcnum = '" + rfcnum + "'";
	}
	
	private ResultSet getSubitem(Subcontract sub, String rfcnum) throws SQLException {
		ResultSet rs = cdb.dbQuery("select * from subitem where subnum = '" + sub.getAltContractId()
			+ "' and " + getRfcQuery(rfcnum) + " and sequence = 1", true);
		if (!rs.isBeforeFirst()) {
			Subcontract old = sub.getOld();
			if (old == null) old = sub;
			Code code = old.getCode();
			if (code != null) {
				log.debug("looking for subcontract by code");
				rs.getStatement().close();
				rs = cdb.dbQuery("select * from subitem where jobnum = '" +
					code.getJobNum() + "' and phasenum = '" + code.getDivision() + "' and " +
					"catnum = '" + code.getCostCode() + "' and " + getRfcQuery(rfcnum) + 
					" and sequence = 1", true);
				ResultSet sh;
				String subnum;
				while (rs.next()) {
					subnum = rs.getString("subnum");
					sh = cdb.dbQuery("select * from subheader where subnum = '" +
						rs.getString("subnum") + "' and " + getRfcQuery(rfcnum) + " and vennum = '" + 
						old.getAltCompanyId() + "'");
					if (sh.isBeforeFirst()) {
						rs.getStatement().close();
						rs = cdb.dbQuery("select * from subitem where subnum = '" + subnum
								+ "' and " + getRfcQuery(rfcnum) + " and sequence = 1", true);
						break;
					}
					sh.getStatement().close();
				}
				if (!rs.isBeforeFirst()) {
					rs.getStatement().close();
					rs = cdb.dbQuery("select * from subitem where subnum is null and rfcnum is null",
						true);
				}
			}
		}
		return rs;
	}
	
	public Subcontract getSubcontract(Subcontract sub) throws Exception {
		Subcontract subr = null;
		ResultSet rs = getSubitem(sub, null);
		if (rs.first()) subr = getSubcontract(rs.getString("subnum"), null, sub.getCode().getPhaseCode(),
			false);
		rs.getStatement().close();
		cdb.disconnect();
		return subr;
	}
	
	public Subcontract getSubcontractById(String subnum, String phase) throws Exception {
		return getSubcontract(subnum, null, phase, true);
	}

	private Subcontract getSubcontract(String subnum, String rfcnum, String phase, boolean closeDb) 
			throws SQLException {
		Subcontract sub = null;
		ResultSet rs = cdb.dbQuery("select * from subheader where subnum = '" + subnum + "' and "
			+ getRfcQuery(rfcnum));
		if (rs.first()) {
			sub = new Subcontract();
			sub.setAltContractId(subnum);
			sub.setDescription(rs.getString("des"));
			sub.setText(rs.getString("contracttext"));
			sub.setDate(rs.getDate("contractdate"));
			sub.setRetention(rs.getDouble("retentionpct")/100);
			sub.setAltCompanyId(rs.getString("vennum"));
			rs.getStatement().close();
			rs = cdb.dbQuery("select jobnum, phasenum, catnum, costtype, amount from subitem where " +
				"subnum = '" + subnum + "' and rfcnum is null and sequence = 1");
			if (rs.first()) {
				Code code = new Code();
				code.setJobNum(rs.getString("jobnum"));
				code.setDivision(rs.getString("phasenum"));
				code.setCostCode(rs.getString("catnum"));
				code.setPhaseCode(phase);
				sub.setAmount(rs.getDouble("amount"));
				int costtype = rs.getInt("costtype");
				rs.getStatement().close();
				rs = cdb.dbQuery("select name, budget" + costtype + "_amount from jccat where jobnum = '" + 
					code.getJobNum() + "' and phasenum = '" + code.getDivision() + "' and catnum = '" + 
					code.getCostCode() + "'");
				if (rs.first()) {
					code.setName(rs.getString("name"));
					code.setAmount(rs.getDouble(2));
				}
				sub.setCode(code);
			}
		}
		rs.getStatement().close();
		if (closeDb) cdb.disconnect();
		return sub;
	}

	public List<Subcontract> getSubcontracts(Code code, List<Integer> costtypes) throws SQLException {
		List<Subcontract> list = null;
		String sql = "select subnum from subitem where jobnum = '" + code.getJobNum() + "' " +
			"and phasenum = '" + code.getDivision() + "' and catnum = '" + code.getCostCode() + "' and " +
			"rfcnum is null";
		String cts = null;
		// Multiple costtypes in computerease may map to a single phasecode
		if (costtypes != null && costtypes.size() > 0) {
			for (Iterator<Integer> i = costtypes.iterator(); i.hasNext(); ) 
				cts = cts == null ? " and (costtype = " + i.next() : 
					" or costtype = " + i.next();
			cts += ")";
		} 
		ResultSet rs = cdb.dbQuery(sql + cts);
		Subcontract sub;
		if (!rs.isBeforeFirst()) {
			rs.getStatement().close();
			/*
			 * This query exists because the way computerease updated it's data, it didn't add the
			 * costtypes to subitems...
			 */
			rs = cdb.dbQuery(sql);
		}
		while (rs.next()) {
			if (list == null) list = new ArrayList<Subcontract>();
			sub = getSubcontract(rs.getString("subnum"), null, code.getPhaseCode(), false);
			if (sub != null) list.add(sub);
		}
		rs.getStatement().close();
		cdb.disconnect();
		return list;
	}
	
	public Result updateCRD(CRD crd, int costtype, int gl) throws Exception {
		log.debug("Begin updateCRD");
		Result result = new Result(Action.NO_ACTION);
		Subcontract sub = crd.getSub();
		Code code = crd.getCode();
		// There is a subcontract on this CRD
		CRD old = crd.getOld();
		if (sub != null) {
			// Look in accounting database
			sub = null;
			if (old != null) {
				sub = getSubcontract(old.getSub());
				if(log.isDebugEnabled()) log.debug("updateCRD: found old subcontract? " + sub != null);
			}
			if (sub == null) {
				sub = getSubcontract(crd.getSub());
				if (log.isDebugEnabled()) log.debug("updateCRD: Didn't find old subcontract, current sub found: " +
						sub != null);
			}
			if (sub != null) {
				sub.setAmount(crd.getContract());
				sub.setDate(crd.getDate());
				sub.setText(crd.getText());
				if (crd.getTitle() != null) sub.setDescription(crd.getTitle());
				result = updateSubcontractDetail(sub, crd.getOld() != null ? getRfcnum(crd.getOld()) : "XXX", 
					getRfcnum(crd), costtype, crd.getSubCANum() == 0 ? null : 
					Integer.toString(crd.getSubCANum()), crd.getCrNum(), crd.isApproved());
				if (log.isDebugEnabled()) log.debug("updateCA: " + result + " " + result.getMessage());
			} else result = new Result(Action.NO_SUBCONTRACT);
		}
		// This a part of a real CR
		if (crd.getCrNum() != null) {
			ResultSet rs = cdb.dbQuery("select * from jcchangeorder where jobnum = '" + code.getJobNum() +
				"' and ordernum = '" + crd.getCrNum() + "'");
			if (rs.first()) {
				// Start with owner contract amount
				ResultSet t = getJobChange(crd, JC_DETAIL_CO_TYPE);
				boolean create = false;
				if (!t.first()) {
					t.moveToInsertRow();
					t.updateInt("type", JC_DETAIL_CO_TYPE);
					create = true;
				}
				if (!create && crd.getOwner() == 0) t.deleteRow();
				else {
					updateJobChange(t, code, crd, rs.getString("des"), gl, crd.getOwner());
					if (create) t.insertRow();
					else t.updateRow();
				}
				t.getStatement().close();
				// Budget
				t = getJobChange(crd, JC_DETAIL_CHANGE_OFFSET + costtype);
				create = false;
				if (!t.first()) {
					t.moveToInsertRow();
					t.updateInt("type", JC_DETAIL_CHANGE_OFFSET + costtype);
					create = true;
				}
				if (!create && crd.getBudget() == 0) t.deleteRow();
				else {
					updateJobChange(t, code, crd, rs.getString("des"), gl, crd.getBudget());
					if (create) t.insertRow();
					else t.updateRow();
				}
				t.getStatement().close();
				if (result.getAction().equals(Action.NO_ACTION))
					result = new Result(Action.UPDATED);
			} else result = new Result(Action.NOT_FOUND, "Could not find change request in Computer Ease");
			rs.getStatement().close();
			cdb.disconnect();
		}
		return result;
	}
	
	private void updateJobChange(ResultSet t, Code code, CRD crd, String des, int gl, double cost)
			throws SQLException {
		t.updateString("jobnum", code.getJobNum());
		t.updateString("phasenum", code.getDivision());
		t.updateString("catnum", code.getCostCode());
		t.updateDate("date", (java.sql.Date) crd.getDate());
		t.updateDouble("cost", cost);
		t.updateDouble("hours", 0);
		t.updateDate("dateposted", (java.sql.Date) crd.getDate());
		t.updateInt("glperiod", gl);
		t.updateString("ponum", crd.getCrNum());
		t.updateString("des1", StringUtils.left(des, 31));
	}
	
	private ResultSet getJobChange(CRD crd, int type) throws SQLException {
		CRD old = crd.getOld();
		ResultSet rs = null;
		Code code;
		if (old != null) {
			code = old.getCode();
			rs = cdb.dbQuery("select * from jcdetail where jobnum = '" + code.getJobNum() + "' and " +
				"phasenum = '" + code.getDivision() + "' and catnum = '" + code.getCostCode() + "' and type = " +
				type + " and ponum = '" + old.getCrNum() + "'", true);
		}
		if (rs == null || !rs.isBeforeFirst()) {
			code = crd.getCode();
			rs = cdb.dbQuery("select * from jcdetail where jobnum = '" + code.getJobNum() + "' and " +
				"phasenum = '" + code.getDivision() + "' and catnum = '" + code.getCostCode() + "' and type = " +
				type + " and ponum = '" + crd.getCrNum() + "'", true);
		}
		return rs;
	}

	public Result deleteCA(CRD crd) throws SQLException {
		return deleteSubcontractDetail(crd.getSub(), getRfcnum(crd));
	}

	public double getCATotal(String subnum) throws SQLException {
		double ca = 0;
		ResultSet rs = cdb.dbQuery("select rfcnum from subheader where subnum = '" + subnum + "' "
			+ "and rfcnum is not null and approved = 1");
		ResultSet temp;
		while (rs.next()) {
			temp = cdb.dbQuery("select sum(amount) from subitem where subnum = '" + subnum + "' "
				+ "and rfcnum = '" + rs.getString(1) + "'");
			if (temp.first()) ca += temp.getDouble(1);
			temp.getStatement().close();
		}
		rs.getStatement().close();
		cdb.disconnect();
		return ca;
	}
	
	private String getRfcnum(CRD crd) {
		if (crd.getCrNum() != null) return crd.getCrNum();
		else return "CA" + crd.getCaNum();
	}

	public CRD getCA(CRD crd) throws Exception {
		CRD crdr = null;
		ResultSet rs = getSubitem(crd.getSub(), getRfcnum(crd));
		if (rs.first()) {
			ResultSet temp = cdb.dbQuery("select * from subheader where subnum = '" + rs.getString("subnum")
				+ "' and rfcnum = '" + rs.getString("rfcnum") + "'");
			if (temp.first()) {
				crdr = new CRD();
				crdr.setContract(rs.getDouble("amount"));
				crdr.setText(temp.getString("contracttext"));
				crdr.setSubCANum(temp.getInt("conum"));
				crdr.setDate(temp.getDate("entereddate"));
				crdr.setCaAltId(rs.getString("subnum") + "." + rs.getString("rfcnum"));
			}
			temp.getStatement().close();
		}
		rs.getStatement().close();
		cdb.disconnect();
		return crdr;
	}

	public Result updateCR(CR cr) throws SQLException {
		Result result = new Result(Action.NO_ACTION);
		CR old = cr.getOld();
		ResultSet rs = null;
		if (old != null) rs = cdb.dbQuery("select * from jcchangeorder where ordernum = '" + old.getNum() +
			"' and jobnum = '" + old.getJobNum() + "'", true);
		if (rs == null || !rs.first()) rs = cdb.dbQuery("select * from jcchangeorder where ordernum = '" 
				+ cr.getNum() + "' and jobnum = '" + cr.getJobNum() + "'", true);
		ResultSet temp;
		boolean create = false;
		if (!rs.first()) {
			temp = cdb.dbQuery("select jobnum from jcjob where jobnum = '" + cr.getJobNum() + "'");
			if (!temp.first()) {
				rs.getStatement().close();
				temp.getStatement().close();
				cdb.disconnect();
				return new Result(Action.NO_JOB);
			} else {
				rs.moveToInsertRow();
				create = true;
			}
		}
		rs.updateString("jobnum", cr.getJobNum());
		rs.updateString("ordernum", cr.getNum());
		rs.updateString("des", cr.getTitle());
		rs.updateDate("date", cr.getDate());
		rs.updateString("conum", cr.getCoNum());
		rs.updateInt("type", 1);
		rs.updateString("notes", cr.getDescription());
		if (create) {
			rs.insertRow();
			updateCOStep(cr, JC_CO_STEP_INITIATED, "Contrack User", cr.getDate());
			result = new Result(Action.CREATED);
		}
		else {
			rs.updateRow();
			result = new Result(Action.UPDATED);
		}
		rs.getStatement().close();
		if (cr.getApprovedDate() != null) updateCOStep(cr, JC_CO_STEP_APPROVED, cr.getSigner(),
			cr.getApprovedDate());
		else deleteCOStep(cr, JC_CO_STEP_APPROVED);
		if (cr.getSubmitDate() != null) updateCOStep(cr, JC_CO_STEP_SENT, cr.getRecipient(),
				cr.getSubmitDate());
		else deleteCOStep(cr, JC_CO_STEP_SENT);
		cdb.disconnect();
		return result;
	}
	
	private void deleteCOStep(CR cr, int type) throws SQLException {
		CR old = cr.getOld();
		int rows = 0;
		if (old != null) rows = cdb.dbInsert("delete from jcchangeorderstep where jobnum = '"
			+ old.getJobNum() + "' and ordernum = '" + old.getNum() + "' and type = " + type);
		if (rows == 0) rows = cdb.dbInsert("delete from jcchangeorderstep where jobnum = '"
			+ cr.getJobNum() + "' and ordernum = '" + cr.getNum() + "' and type = " + type);
	}
	
	private void updateCOStep(CR cr, int type, String who, Date date) throws SQLException {
		if(log.isDebugEnabled()) log.debug("updatingCOStep type->" + type + " who->" + who);
		CR old = cr.getOld();
		ResultSet rs = null; 
		if (old != null) rs = cdb.dbQuery("select * from jcchangeorderstep where jobnum = '"
			+ old.getJobNum() + "' and ordernum = '" + old.getNum() + "' and type = " + type, true);
		if (rs == null || !rs.first()) rs = cdb.dbQuery("select * from jcchangeorderstep where jobnum = '"
			+ cr.getJobNum() + "' and ordernum = '" + cr.getNum() + "' and type = " + type, true);
		boolean create = false;
		if (!rs.first()) {
			log.debug("updateCoStep create COStep");
			rs.moveToInsertRow();
			create = true;
		}
		rs.updateString("jobnum", cr.getJobNum());
		rs.updateString("ordernum", cr.getNum());
		rs.updateInt("type", type);
		rs.updateString("who", StringUtils.left(who, 31));
		rs.updateDate("date", (java.sql.Date) date);
		if (create) rs.insertRow();
		else rs.updateRow();
		rs.getStatement().close();
	}

	public Result deleteCR(CR cr) throws Exception {
		Result result = new Result(Action.NO_ACTION);
		// Delete the steps first
		deleteCOStep(cr, JC_CO_STEP_INITIATED);
		deleteCOStep(cr, JC_CO_STEP_APPROVED);
		deleteCOStep(cr, JC_CO_STEP_SENT);
		if (cdb.dbInsert("delete from jcchangeorder where jobnum = '" + cr.getJobNum() + "' and " +
			"ordernum = '" + cr.getNum() + "'") != 0) result = new Result(Action.DELETED);
		cdb.disconnect();
		return result;
	}

	public double getCROwner(CR cr) throws Exception {
		double result = 0;
		ResultSet rs = cdb.dbQuery("select sum(cost) from jcdetail where jobnum = '" + cr.getJobNum() +
			"' and ponum = '" + cr.getNum() + "' and type = " + JC_DETAIL_CO_TYPE);
		if (rs.first()) result = rs.getDouble(1);
		rs.getStatement().close();
		cdb.disconnect();
		return result;
	}

	public double getBudgetChangeTotal(Code code, int type) throws Exception {
		double change = 0;
		ResultSet rs = cdb.dbQuery("select cost, ponum from jcdetail where jobnum = '" + code.getJobNum() +
			"' and phasenum = '" + code.getDivision() + "' and catnum = '" + code.getCostCode() + "' and " +
			"type = " + type);
		ResultSet temp;
		while (rs.next()) {
			temp = cdb.dbQuery("select jobnum from jcchangeorderstep where jobnum = '" + code.getJobNum() + "' " +
				"and ordernum  = '" + rs.getString("ponum") + "' and type = " + JC_CO_STEP_APPROVED);
			if (temp.first()) change += rs.getDouble("cost");
			temp.getStatement().close();
		}
		rs.getStatement().close();
		cdb.disconnect();
		return change;
	}

	public List<String> getRoutes() throws Exception {
		List<String> list = null;
		ResultSet rs = cdb.dbQuery("select groupcode from apgroup where grouptype = 0 order by groupcode");
		if (rs.isBeforeFirst()) list = new ArrayList<String>();
		while (rs.next()) {
			list.add(rs.getString("groupcode"));
		}
		rs.getStatement().close();
		cdb.disconnect();
		return list;
	}

	public List<VoucherAttachment> getVoucherAttachments(String id)
			throws Exception {
		// does nothing
		return null;
	}

	public Route getVoucherRouteByVoucher(String voucherId, String groupCode) throws Exception {
		ResultSet rs = cdb.dbQuery("select step from apvoucherroute where voucher = "
			+ voucherId + " and groupcode= '" + groupCode + "'");
		String routeId = null;
		if (rs.first()) routeId = voucherId + "~" + rs.getString("step");
		log.debug("getVoucherRoute by voucherId: found routeId " + routeId);
		rs.getStatement().close();
		Route route = null;
		if (routeId != null) route = getVoucherRoute(routeId);
		return route;
	}
	
	public Route getVoucherRoute(String routeId) throws Exception {
		log.debug("getVoucherRoute using routeId " + routeId);
		String[] ids = routeId.split("~");
		int step = Integer.parseInt(ids[1]);
		ResultSet rs = cdb.dbQuery("select * from apvoucherroute where voucher = "
			+ ids[0] + " order by step");
		Route route = new Route();
		boolean found = false;
		route.setVoucherId(ids[0]);
		route.setId(ids[0] + "~" + step);
		while (rs.next()) {
			if (step == rs.getInt("step")) {
				found = true;
				route.setCurNotes(rs.getString("notes"));
				switch (rs.getInt("status")) {
				case AP_VOUCHER_ROUTE_PENDING:
					route.setStatus(Route.STATUS_PENDING);
					break;
				case AP_VOUCHER_ROUTE_APPROVED:
					route.setStatus(Route.STATUS_APPROVE);
					break;
				case AP_VOUCHER_ROUTE_REJECTED:
					route.setStatus(Route.STATUS_REJECT);
					break;
				}
			} else if (rs.getInt("status") != AP_VOUCHER_ROUTE_PENDING &&
					rs.getString("notes") != null) {
				route.addNote(rs.getString("notes"), rs.getString("user"));
			}
		}
		log.debug("getVoucherRoute: found " + step + "? " + found);
		if (!found) route = null;
		rs.getStatement().close();
		cdb.disconnect();
		return route;
	}
	
	public void setVoucherRoute(Route route, String groupCode) throws Exception {
		String[] ids = route.getId().split("~");
		ResultSet rs = cdb.dbQuery("select * from apvoucherroute where voucher = "
			+ ids[0] + " and step = " + ids[1], true);
		if (rs.first()) {
			int status = 0;
			switch (route.getStatus()) {
			case Route.STATUS_APPROVE:
				status = AP_VOUCHER_ROUTE_APPROVED;
				break;
			case Route.STATUS_PENDING:
				status = AP_VOUCHER_ROUTE_PENDING;
				break;
			case Route.STATUS_REJECT:
				status = AP_VOUCHER_ROUTE_REJECTED;
				break;
			}
			cdb.dbInsert("update apvoucher set routingstatus = 2 where vouchernum = " + ids[0]);
			rs.updateInt("status", status);
			rs.updateString("notes", route.getCurNotes());
			try {
				ResultSet group = cdb.dbQuery("select * from apgroupmember where groupcode = '"
						+ groupCode + "'");
				if (group.first()) rs.updateString("user", group.getString("user"));
				group.getStatement().close();
			} catch (SQLException e) {
				log.warn("Problem with query", e);
				rs.updateString("user", rs.getString("groupcode"));
			}
			rs.updateRow();
		}
		rs.getStatement().close();
		cdb.disconnect();
	}

	public List<String> getRoutedVoucherNums(String groupCode) throws Exception {
		ResultSet rs = cdb.dbQuery("select voucher from apvoucherroute where groupcode = '"
			+ groupCode + "' and status = " + AP_VOUCHER_ROUTE_PENDING);
		List<String> vs = new ArrayList<String>();
		while (rs.next()) vs.add(rs.getString(1));
		rs.getStatement().close();
		cdb.disconnect();
		return vs;
	}

	public void setVoucherURL(String voucherID, Long documentId, String key,
			String siteUrl) throws Exception {
		/*
		 * The ever lame computer ease doesn't allow me to write attachid
		 * to the apvoucher table so this doesn't work :(
		 *
		if (log.isDebugEnabled()) log.debug("setVoucherURL: " + documentId +
				" " + key);
		String path = siteUrl + "image.pdf?id=" + documentId + "&key=" + key
			+ "#view=FitV&statusbar=1&navpanes=0";
		ResultSet apvoucher = cdb.dbQuery("select * from apvoucher where vouchernum = "
			+ voucherID, true);
		int attachId = 0;
		if (apvoucher.first()) {
			attachId = apvoucher.getInt("attachid");
			ResultSet rs = cdb.dbQuery("select * from apvoucherattachment where "
				+ "ownerkey = " + attachId, true);
			/*
			 *  look for the right path to avoid duplicates
			 *  stupid computer ease can't do a db search on the path.
			 */
		/*
			boolean found = false;
			while (rs.next() && !found) {
				found = path.equals(rs.getString("path"));
				if (log.isDebugEnabled()) log.debug("Comparing values:\n" + path 
					+ "###\n" + rs.getString("path") + "###\nFound: " + found);
			}
			if (!found) {
				if (attachId == 0) {
					ResultSet ids =  cdb.dbQuery("select max(attachid) as ok from "
							+ "apvoucher");
					ids.first();
					attachId = ids.getInt(1);
					attachId++;
					apvoucher.updateInt("attachid", attachId);
					apvoucher.updateRow();
					ids.getStatement().close();
				} 
				rs.moveToInsertRow();
				rs.updateInt("ownerkey", attachId);
				rs.updateInt("type", 1);
				rs.updateInt("folder", 0);
				rs.updateString("directory", "General");
				rs.updateString("path", path);
				rs.insertRow();
			}
			rs.getStatement().close();
		}
		apvoucher.getStatement().close();
		cdb.disconnect();
		*/
	}

}
