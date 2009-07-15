package accounting.ce;

import java.net.MalformedURLException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import org.apache.cayenne.CayenneContext;
import org.apache.cayenne.CayenneRuntimeException;
import org.apache.cayenne.DataChannel;
import org.apache.cayenne.DataObjectUtils;
import org.apache.cayenne.ObjectId;
import org.apache.cayenne.event.EventManager;
import org.apache.cayenne.exp.Expression;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.ObjectIdQuery;
import org.apache.cayenne.query.SQLTemplate;
import org.apache.cayenne.query.SelectQuery;
import org.apache.cayenne.remote.ClientChannel;
import org.apache.cayenne.remote.hessian.HessianConnection;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import accounting.Accounting;
import accounting.Action;
import accounting.CR;
import accounting.CRD;
import accounting.Check;
import accounting.Code;
import accounting.Company;
import accounting.Cost;
import accounting.Result;
import accounting.Route;
import accounting.Subcontract;
import accounting.Voucher;
import accounting.VoucherAttachment;
import accounting.VoucherDistribution;
import accounting.ce.client.Apcheck;
import accounting.ce.client.Apvoucher;
import accounting.ce.client.Apvoucherdist;
import accounting.ce.client.Glinfo;
import accounting.ce.client.Jccat;
import accounting.ce.client.Jcchangeorder;
import accounting.ce.client.Jcchangeorderstep;
import accounting.ce.client.Jcdetail;
import accounting.ce.client.Jcdetailsum;
import accounting.ce.client.Jcjob;
import accounting.ce.client.Jcphase;
import accounting.ce.client.Vendor;

import com.caucho.hessian.client.HessianProxyFactory;
import com.sinkluge.database.Database;

public class CEAccounting extends Accounting {
	
	
	final static private int JC_CO_STEP_SENT = 100;
	
	private CayenneContext context;
	private Map<String, List<Integer>> map = null;
	private Map<Integer, String> unmap = null;
	private int gl;
	private int siteId;
	private String url;
	private HessianProxyFactory hpf;
	private Log log = LogFactory.getLog(CEAccounting.class);
	private HessianConnection connection;
	private String groupCode = null;
	
	@Deprecated
	public void close() {
		// Does nothing now
	}
	
	public void shutdown() {
		log.debug("Cleaning up resources");
		DataChannel channel = context.getChannel();
		if (channel != null) {
			EventManager events = channel.getEventManager();
			if (events != null) events.shutdown();
			channel = null;
		}
		context = null;
	}
	
	private void init() {
		int startMonth = 0;
		Glinfo glinfo = (Glinfo) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Glinfo", "id", 0)));
		if (glinfo != null) startMonth = glinfo.getStartmonth() - 1;
		Calendar cal = Calendar.getInstance();
		int curMonth = 12 - startMonth + cal.get(Calendar.MONTH);
		if (curMonth > 12) curMonth -= 12;
		int year = cal.get(Calendar.YEAR);
		if (cal.get(Calendar.MONTH) + 1 < curMonth) year--; 
		gl = year * 100 + curMonth;
	}
	
	private void initMap() throws Exception {
		String query = "select letter, mapping from cost_types where site_id = " + siteId;
		Database db = new Database();
		ResultSet rs = db.dbQuery(query);
		StringTokenizer st;
		List<Integer> list;
		if (map == null) map = new HashMap<String, List<Integer>>();
		while (rs.next()) {
			list = new ArrayList<Integer>();
			st = new StringTokenizer(rs.getString(2), ",");
			while (st.hasMoreTokens()) {
				list.add(new Integer(st.nextToken()));
			}
			map.put(rs.getString(1), list);
		}
		if (rs != null) rs.getStatement().close();
		rs = null;
		db.disconnect();
	}
	
	private List<Integer> getMap(String type) throws Exception {
		if (type != null) {
			if (map == null) initMap();
			return map.get(type);
		} else return null;
	}
	
	private int mapFirst(String type) throws Exception {
		List<Integer> l = getMap(type);
		return l != null ? l.get(0) : null;
	}
	
	private Iterator<Integer> map(String type) throws Exception {
		List<Integer> l = getMap(type);
		return l != null ? l.iterator() : null;
	}
	
	private void initUnmap() throws Exception {
		if (map == null) initMap();
		unmap = new HashMap<Integer, String>();
		String key;
		for (Iterator<String> i = map.keySet().iterator(); i.hasNext();) {
			key = i.next();
			for (Iterator<Integer> j = map.get(key).iterator(); j.hasNext();)
				unmap.put(j.next(), key);
		}
	}
	
	private String map(int type) throws Exception {
		if (unmap == null) initUnmap();
		return unmap.get(type);
	}

	private ObjectId getCodePK(String entity, Code code) {
		Map<String, String> map = new HashMap<String, String>();
		map.put("jobnum", code.getJobNum());
		map.put("catnum", code.getCostCode());
		map.put("phasenum", code.getDivision());
		return new ObjectId(entity, map);
	}
	
	@Override
	public int deleteCode(Code code) throws Exception {
		Jccat cat = (Jccat) DataObjectUtils.objectForQuery(context, new ObjectIdQuery(getCodePK("Jccat", code)));
		try {
			Iterator<Integer> i = map(code.getPhaseCode());
			cat.setBudgetAmount(i.next(), 0d);
			return DELETED;
		} catch (NullPointerException e) {
			return ERROR;
		}
	}

	private Jccat getJccat(Code code) throws Exception {
		return (Jccat) DataObjectUtils.objectForQuery(context, new ObjectIdQuery(getCodePK("Jccat", code)));
	}
	
	@Override
	public Code getCode(Code code) throws Exception {
		Jccat cat = getJccat(code);
		if (cat != null){
			double amount = 0;
			Overhead oh = new Overhead(cat.getJob());
			int type;
			for (Iterator<Integer> i = map(code.getPhaseCode()); i.hasNext(); ) {
				type = i.next();
				amount += (oh.get(type) + 1) * cat.getBudgetAmount(type);
			}
			code.setAmount(amount);
			code.setName(cat.getName());
			return code;
		} else return null;
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<Code> getCodes(String jobNum) throws Exception {
		Expression e = ExpressionFactory.matchExp(Jccat.JOBNUM_PROPERTY, jobNum);
		e = e.andExp(ExpressionFactory.noMatchExp(Jccat.CATNUM_PROPERTY, null));
		SelectQuery s = new SelectQuery(Jccat.class, e);
		s.addOrdering(Jccat.PHASENUM_PROPERTY, true);
		s.addOrdering(Jccat.CATNUM_PROPERTY, true);
		List<Code> codes = new ArrayList<Code>();
		Hashtable<String, Double> types = new Hashtable<String, Double>();
		double amount;
		Jccat cat;
		Code code;
		String key;
		if (map == null) initMap();
		Overhead oh = null;
		for (Iterator<String> i = map.keySet().iterator(); i.hasNext();) {
			types.put(i.next(), new Double(0));
		}
		for (Iterator cats =  context.performQuery(s).iterator(); cats.hasNext();){
			cat = (Jccat) cats.next();
			if (oh == null) oh = new Overhead(cat.getJob());
			for (short i = 1; i <= 16; i++) {
				key = map(i);
				if (key != null) {
					amount = types.get(key);
					amount += cat.getBudgetAmount(i) * (oh.get(i) + 1);
					types.put(key, amount);
				}
			}
			for (Enumeration<String> keys = types.keys(); keys.hasMoreElements();) {
				key = keys.nextElement();
				code = new Code();
				code.setCostCode(cat.getCatnum());
				code.setDivision(cat.getPhasenum());
				code.setJobNum(cat.getJobnum());
				code.setName(cat.getName());
				code.setPhaseCode(key);
				code.setAmount(types.get(key));
				codes.add(code);
				types.put(key, 0d);
			}
		}
		return codes;
	}

	private int getId(String table, String col, String accountId) {
		ResultSet rs = null;
		int id = 0;
		Database db = null;
		try {
			db = new Database();
			rs = db.dbQuery("select " + col + " from " + table + " where account_id = '" + accountId + "'");
			if (rs.next()) id = rs.getInt(1);
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return id;
	}
	
	private String getId(String table, String col, int id) {
		ResultSet rs = null;
		String accountId = null;
		Database db = null;
		try {
			db = new Database();
			rs = db.dbQuery("select account_id from " + table + " where " + col + " = " + id);
			if (rs.next()) accountId = rs.getString(1);
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return accountId;
	}
	
	public static String getAltCompanyId(int companyId, int siteId, Database db) throws
		SQLException {
		ResultSet rs = null;
		String accountingCompanyId = null;
		try {
			rs = db.dbQuery("select account_id from company_account_ids where company_id = " 
				+ companyId + " and site_id = " + siteId);
			if (rs.next()) accountingCompanyId = rs.getString(1);
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			try {
				if (rs != null) rs.getStatement().close();
			} catch (SQLException e) {}
			rs = null;
			db.disconnect();
		}
		return accountingCompanyId;
	}
	
	private Vendor getVendor(String vennum) {
		return (Vendor) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Vendor", "vennum", vennum)));
	}
	
	private Company getCompany(String vennum, int id) throws Exception {
		Vendor vendor = getVendor(vennum);
		if (vendor != null) {
			Company company = getCompany(vendor);
			company.setId(id);
			company.setAccountId(vennum);
			return company;
		} else return null;
	}
	
	private Company getCompany(Vendor vendor) throws Exception {
		Company company = new Company();
		company.setAddress(vendor.getAddress1());
		company.setCity(vendor.getAddresscity());
		company.setState(vendor.getAddressstate());
		company.setZip(vendor.getAddresszip());
		String comment = "";
		if (vendor.getNotes1() != null) comment += vendor.getNotes1();
		if (vendor.getNotes2() != null) comment += 
			"".equals(comment) ? vendor.getNotes2() : "\n----\n" + vendor.getNotes2();
		if (vendor.getMemo() != null) comment += 
			"".equals(comment) ? vendor.getMemo() : "\n----\n" + vendor.getMemo();
		company.setComment(comment);
		company.setEmail(vendor.getEmail());
		company.setFax(vendor.getFaxnum());
		company.setFederalId(vendor.getId());
		company.setName(vendor.getName());
		company.setPhone(vendor.getPhonenum());
		company.setUrl(vendor.getWeb());
		company.setPhaseCode(map(vendor.getCosttype()));
		company.setAccountId(vendor.getVennum());
		return company;
	}

	@Override
	public Company getCompany(String altCompanyId) throws Exception {
		return getCompany(altCompanyId, getCompanyId(altCompanyId));
	}
	
	@Override
	public Company getCompany(int id) throws Exception {
		return getCompany(getAltCompanyId(id), id);
	}

	@Override
	public Cost getCost(String id) throws Exception {
		Jcdetail jc = (Jcdetail) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Jcdetail", "serialnum", id)));
		if (jc != null) {
			Code code = new Code();
			code.setCostCode(jc.getCatnum());
			code.setDivision(jc.getPhasenum());
			code.setJobNum(jc.getJobnum());
			code.setPhaseCode(map(jc.getType()));
			code = getCode(code);
			Cost cost = new Cost();
			cost.setCode(code);
			cost.setCost(jc.getCost());
			cost.setDate(jc.getDate());
			cost.setDescription(jc.getDes1());
			cost.setHours(jc.getHours());
			cost.setId(jc.getSerialnum());
			cost.setInvoiceNum(jc.getInvnum());
			cost.setName(jc.getWho());
			cost.setId(jc.getSerialnum());
			return cost;
		} else return null;
	}
	
	private Jcjob getJob(String jobNum) throws Exception {
		Jcjob job = (Jcjob) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Jcjob", "jobnum", jobNum)));
		return job;
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<Cost> getSummedCosts(String jobNum) throws Exception {
		SQLTemplate sql = new SQLTemplate(Jcdetailsum.class, 
			"select jobnum, catnum, phasenum, type, sum(cost) as cost, sum(hours) as "
			+ "hours from jcdetail where jobnum = '" + jobNum + "' and catnum "
			+ "is not null and phasenum is not null and type < 17 "
			+ "group by jobnum, catnum, phasenum, type order by catnum, "
			+ "phasenum, type");
		
		List<Cost> costs = new ArrayList<Cost>();
		Cost cost;
		Code code;
		
		Jcdetailsum jc;
		Jcjob jcjob = getJob(jobNum);
		Map<String, Cost> map = new HashMap<String, Cost>();
		if (jcjob != null) {
			Overhead oh = new Overhead(getJob(jobNum));
			String key;
			if (oh != null) {
				for (Iterator i = context.performQuery(sql).iterator(); i.hasNext(); ){
					jc = (Jcdetailsum) i.next(); 
					code = new Code();
					code.setJobNum(jobNum);
					code.setCostCode(jc.getCatnum());
					code.setDivision(jc.getPhasenum());
					code.setPhaseCode(map(jc.getType()));
					key = code.getDivision() + code.getCostCode() + code.getPhaseCode();
					cost = map.get(key);
					if (cost == null) {
						cost = new Cost();
						cost.setCode(code);
						cost.setCost(jc.getCost() * (oh.get(jc.getType()) + 1));
						cost.setHours(jc.getHours());
						map.put(key, cost);
					} else {
						cost.setCost((jc.getCost() * (oh.get(jc.getType()) + 1)) + cost.getCost());
						cost.setHours(jc.getHours() + cost.getHours());
						map.put(key, cost);
					}
				}
			}
		}
		for (Iterator<Cost> i = map.values().iterator(); i.hasNext(); ) 
			costs.add(i.next());
		map.clear();
		return costs;
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<Cost> getCosts(Code code) throws Exception {
		Expression e = ExpressionFactory.matchExp(Jcdetail.CATNUM_PROPERTY, code.getCostCode());
		e = e.andExp(ExpressionFactory.matchExp(Jcdetail.JOBNUM_PROPERTY , code.getJobNum()));
		e = e.andExp(ExpressionFactory.matchExp(Jcdetail.PHASENUM_PROPERTY, code.getDivision()));
		Expression types = null;
		for (Iterator<Integer> i = map(code.getPhaseCode()); i.hasNext(); ) {
			if (types == null) types = ExpressionFactory.matchExp(Jcdetail.TYPE_PROPERTY, i.next());
			else types = types.orExp(ExpressionFactory.matchExp(Jcdetail.TYPE_PROPERTY, i.next()));
		}
		e = e.andExp(types);
		SelectQuery s = new SelectQuery(Jcdetail.class, e);
		s.addOrdering(Jcdetail.DATE_PROPERTY, false);
		List<Cost> costs = new ArrayList<Cost>();
		Jcdetail jc;
		code = getCode(code);
		if (code != null) {
			Cost cost;
			Overhead oh = null;
			double burden = 0;
			for (Iterator i = context.performQuery(s).iterator(); i.hasNext(); ) {
				jc = (Jcdetail) i.next();
				if (oh == null) oh = new Overhead(jc.getJob());
				cost = getCost(jc);
				cost.setCode(code);
				burden += oh.get(jc.getType()) * cost.getCost();
				costs.add(cost);
			}
			if (burden != 0) costs.add(addOverhead(code, burden));
		}
		return costs;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public List<Cost> getAllCosts(String jobNum) throws Exception {
		Expression e = ExpressionFactory.matchExp(Jcdetail.JOBNUM_PROPERTY, jobNum);
		e = e.andExp(ExpressionFactory.lessExp(Jcdetail.TYPE_PROPERTY, 17));
		SelectQuery s = new SelectQuery(Jcdetail.class, e);
		s.addOrdering(Jcdetail.DATE_PROPERTY, true);
		List<Cost> costs = new ArrayList<Cost>();
		Jcdetail jc;
		Cost cost;
		Code code = null;
		Hashtable<String, Double> overhead = new Hashtable<String, Double>();
		Overhead oh = null;
		double burden = 0;
		String phase;
		List c = context.performQuery(s);
		for (Iterator i = c.iterator(); i.hasNext();) {
			jc = (Jcdetail) i.next();
			if (oh == null) oh = new Overhead(jc.getJob());
			phase = map(jc.getType());
			code = new Code();
			code.setCostCode(jc.getCatnum());
			code.setPhaseCode(phase);
			code.setDivision(jc.getPhasenum());
			cost = getCost(jc);
			try {
				burden = overhead.get(code.getDivision() + "\t" + code.getCostCode() + "\t" + code.getPhaseCode());
			} catch (NullPointerException np) {
				// primitive types hate null
				burden = 0;
			}
			burden += oh.get(jc.getType()) * cost.getCost();
			if (burden != 0) overhead.put(code.getDivision() + "\t" + code.getCostCode() + "\t" 
				+ code.getPhaseCode(), burden);
			cost.setCode(code);
			costs.add(cost);
		}
		c.clear();
		c = null;
		StringTokenizer st;
		String key;
		for (Enumeration<String> keys = overhead.keys(); keys.hasMoreElements(); ) {
			key = keys.nextElement();
			st = new StringTokenizer(key);
			code = new Code();
			code.setDivision(st.nextToken());
			code.setCostCode(st.nextToken());
			code.setPhaseCode(st.nextToken());
			costs.add(addOverhead(code, overhead.get(key)));
		}
		return costs;
	}
	
	private Cost addOverhead(Code code, double burden) {
		Cost cost = new Cost();
		cost.setCode(code);
		cost.setDate(new java.util.Date());
		cost.setName("Computed Overhead");
		cost.setCost(burden);
		return cost;
	}
	
	private Cost getCost(Jcdetail jc) {
		Cost cost = new Cost();
		cost.setName(jc.getWho());
		cost.setInvoiceNum(jc.getInvnum());
		cost.setCost(jc.getCost());
		cost.setDate(jc.getDate());
		cost.setDescription(jc.getDes1());
		cost.setInvoiceNum(jc.getInvnum());
		cost.setHours(jc.getHours());
		cost.setId(jc.getSerialnum());
		return cost;
	}
	
	@Override
	public double getCATotal(String subnum) throws Exception {
		return getCEHessian().getCATotal(subnum);
	}
	
	public Subcontract getSubcontract(String subnum, String phase) throws Exception {
		return getCEHessian().getSubcontractById(subnum, phase);
	}
	
	@Override
	public List<Subcontract> getSubcontracts(Code code) throws Exception {
		CEHessian ce = getCEHessian();
		List<Subcontract> list = ce.getSubcontracts(code, map.get(code.getPhaseCode()));
		return list;
	}

	@Override
	public Voucher getVoucher(String id) throws Exception {
		return getVoucher(id, getId("pay_requests", "pr_id", id));
	}

	@Override
	public Voucher getVoucher(int payRequestId) throws Exception {
		return getVoucher(getId("pay_requests", "pr_id", payRequestId), payRequestId);
	}
	
	private int getCompanyId(String altCompanyId) {
		ResultSet rs = null;
		int id = 0;
		Database db = null;
		try {
			db = new Database();
			rs = db.dbQuery("select company_id from company_account_ids where account_id = '" 
					+ altCompanyId + "' and site_id = " + siteId);
			if (rs.next()) id = rs.getInt(1);
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			} catch (SQLException e) {}
			rs = null;
			
		}
		return id;
	}
	
	private String getAltCompanyId(int id) {
		ResultSet rs = null;
		String accountId = null;
		Database db = null;
		try {
			db = new Database();
			rs = db.dbQuery("select account_id from company_account_ids where company_id = " 
					+ id + " and site_id = " + siteId);
			if (rs.next()) accountId = rs.getString(1);
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			try {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			} catch (SQLException e) {}
			rs = null;
		}
		return accountId;
	}
	
	@SuppressWarnings("unchecked")
	private Voucher getVoucher(String id, int payRequestId) throws Exception {
		Apvoucher ap = (Apvoucher) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Apvoucher", "vouchernum", id)));
		if (ap != null) {
			Voucher voucher = new Voucher();
			voucher.setAccountCompanyId(ap.getVennum());
			voucher.setAmount(ap.getAmount());
			voucher.setCompanyId(getCompanyId(voucher.getAccountCompanyId()));
			voucher.setDate(ap.getInvdate());
			voucher.setDescription(ap.getDes());
			voucher.setDiscount(ap.getDisctaken());
			voucher.setId(id);
			voucher.setInvoiceNum(ap.getInvnum());
			voucher.setName(ap.getVenname());
			voucher.setPaid(ap.getPtd());
			voucher.setPayRequestId(payRequestId);
			voucher.setPoNum(ap.getPonum());
			voucher.setRetention(ap.getRetheld());
			List<Apvoucherdist> dist = ap.getDistribution();
			Apvoucherdist apd;
			VoucherDistribution vd;
			for (Iterator<Apvoucherdist> i = dist.iterator(); i.hasNext(); ) {
				apd = i.next();
				vd = getVoucherDistribution(apd);
				vd.setVoucherId(id);
				voucher.addVoucherDistribution(vd);
			}
			Check check;
			Apcheck ac;
			List checks = ap.getChecks();
			if (checks != null) {
				for (Iterator i = ap.getChecks().iterator(); i.hasNext(); ) {
					ac = (Apcheck) i.next();
					check = new Check();
					check.setAmount(ac.getApamt());
					check.setCheckNum(ac.getChecknum());
					check.setVoucherNum(id);
					check.setName(ac.getName());
					voucher.addCheck(check);
				}
			}
			return voucher;
		} else return null;
	}
	
	private VoucherDistribution getVoucherDistribution(Apvoucherdist dist) throws Exception {
		VoucherDistribution vd = new VoucherDistribution();
		vd.setAmount(dist.getAmount());
		Apvoucher apv = dist.getVoucher();
		if (apv != null) {
			vd.setDate(apv.getInvdate());
			vd.setVoucherId(apv.getVouchernum().toString());
		}
		Code code = new Code();
		code.setJobNum(dist.getJobnum());
		code.setCostCode(dist.getCatnum());
		code.setDivision(dist.getPhasenum());
		code.setPhaseCode(map(dist.getCosttype()));
		vd.setCode(code);
		vd.setDescription(dist.getDes());
		vd.setDiscount(dist.getDisctaken());
		vd.setPaid(dist.getPtd());
		vd.setRetention(dist.getRetheld());
		return vd;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public List<VoucherDistribution> getVoucherDistributions(Code code) throws Exception {
		Expression e = ExpressionFactory.matchExp(
			Apvoucherdist.JOBNUM_PROPERTY, code.getJobNum());
		e = e.andExp(ExpressionFactory.matchExp(
			Apvoucherdist.PHASENUM_PROPERTY, code.getDivision()));
		e = e.andExp(ExpressionFactory.matchExp(
			Apvoucherdist.CATNUM_PROPERTY, code.getCostCode()));
		Expression types = null;
		for (Iterator<Integer> i = map(code.getPhaseCode()); i.hasNext(); ) {
			if (types == null) types = ExpressionFactory.matchExp(
				Apvoucherdist.COSTTYPE_PROPERTY, i.next());
			else types = types.orExp(ExpressionFactory.matchExp(
				Apvoucherdist.COSTTYPE_PROPERTY, i.next()));
		}
		e = e.andExp(types);
		SelectQuery s = new SelectQuery(Apvoucherdist.class, e);
		Apvoucherdist dist;
		VoucherDistribution vd;
		List<VoucherDistribution> vds = new ArrayList<VoucherDistribution>();
		for (Iterator i = context.performQuery(s).iterator(); i.hasNext();) {
			dist = (Apvoucherdist) i.next();
			vd = getVoucherDistribution(dist);
			vds.add(vd);
		}
		Collections.sort(vds);		
		return vds;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Company searchForCompany(String name) throws Exception {
		Company company = null;
		Expression e;
		SelectQuery s;
		Vendor v;
		List result;
		if (name != null) {
			while (company == null) {
				e = ExpressionFactory.likeExp(Vendor.NAME_PROPERTY, name.toUpperCase() + "%");
				s = new SelectQuery(Vendor.class, e);
				result = context.performQuery(s);
				if (result != null && result.size() > 0) {
					v = (Vendor) result.get(0);
					company = getCompany(v);
				}
				if (company == null) {
					e = ExpressionFactory.likeExp(Vendor.NAME_PROPERTY, name + "%");
					s = new SelectQuery(Vendor.class, e);
					result = context.performQuery(s);
					if (result != null && result.size() > 0) {
						v = (Vendor) result.get(0);
						company = getCompany(v);
					}
				}
				if (company == null) name = name.substring(0, name.length() - 1);
			}
		}
		return company;
	}

	private ObjectId getPhasePK(Code code) {
		Map<String, String> map = new HashMap<String, String>();
		map.put("jobnum", code.getJobNum());
		map.put("phasenum", code.getDivision());
		return new ObjectId("Jcphase", map);
	}
	
	@Override
	public int updateCode(Code code) throws Exception {
		int op = NO_ACTION;
		Jccat cat = (Jccat) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(getCodePK("Jccat", code)));
		Overhead oh = null;
		if (cat != null) {
			oh = new Overhead(cat.getJob());
			cat.setName(code.getName());
			cat.setBudgetAmount(map(code.getPhaseCode()).next(), (double) Math.round(code.getAmount()*100 / 
					(oh.get(map(code.getPhaseCode()).next()) + 1))/100);
			op = UPDATED;
		} else {
			// Doesn't exist does the phase exits?
			Jcphase phase = (Jcphase) DataObjectUtils.objectForQuery(context, 
					new ObjectIdQuery(getPhasePK(code)));
			// Phase exists create the code
			if (phase != null) {
				oh = new Overhead(phase.getJob());
				createCat(code, oh);
				op = CREATED;
			} else {
				// Phase doesn't exist does the job?
				Jcjob job = (Jcjob) DataObjectUtils.objectForQuery(context, 
						new ObjectIdQuery(new ObjectId("Jcjob", "jobnum", code.getJobNum())));
				// Job exists create the phase
				if (job != null) {
					oh = new Overhead(job);
					phase = (Jcphase) context.newObject(Jcphase.class);
					phase.setJob(job);
					ResultSet rs = null;
					Database db = null;
					try {
						db = new Database();
						rs = db.dbQuery("select description from job_divisions join job using(job_id) where "
							+ "division = '" + code.getDivision() + "' and job_num = '" 
							+ code.getJobNum() + "'");
						log.debug("Performing division lookup: "
							+ "select description from job_divisions join job using(job_id) where "
							+ "division = '" + code.getDivision() + "' and job_num = '" 
							+ code.getJobNum() + "'");
						if (rs.first()) phase.setName(rs.getString(1));
						else phase.setName("Contrack");
					} catch (Exception e) {
						phase.setName("Contrack");
						e.printStackTrace();
					} finally {
						try {
							if (rs != null) rs.getStatement().close();
							if (db != null) db.disconnect();
						} catch (SQLException e) {}
						rs = null;
					}
					phase.setPhasenum(code.getDivision());
					phase.setSequence(500);
					Jccat phaseCat = (Jccat) context.newObject(Jccat.class);
					phaseCat.setJob(job);
					phaseCat.setPhase(phase);
					phaseCat.setSequence(0);
					phaseCat.setCatnum("");
					createCat(code, oh);
					op = CREATED;
				} else op = NO_JOB;
			}
		}
		context.commitChanges();
		return op;
	}
	
	private void createCat(Code code, Overhead oh) throws Exception {
		Jccat cat =(Jccat) context.newObject(Jccat.class);
		cat.setJobnum(code.getJobNum());
		cat.setPhasenum(code.getDivision());
		cat.setCatnum(code.getCostCode());
		cat.setName(code.getName());
		try {
			cat.setBudgetAmount(map(code.getPhaseCode()).next(),  (double) Math.round(code.getAmount()*100 / 
					(oh.get(map(code.getPhaseCode()).next()) + 1))/100);
		} catch (NullPointerException e) {}
		cat.setSequence(500);
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public int updateEstimate(Code code) throws Exception {
		int op = NO_ACTION;
		boolean proceed = true;
		if (code.getAmount() != 0) {
			Expression e = ExpressionFactory.matchExp(Jcdetail.JOBNUM_PROPERTY, code.getJobNum());
			e = e.andExp(ExpressionFactory.matchExp(
				Jcdetail.PHASENUM_PROPERTY, code.getDivision()));
			e = e.andExp(ExpressionFactory.matchExp(
					Jcdetail.CATNUM_PROPERTY, code.getCostCode()));
			e = e.andExp(ExpressionFactory.matchExp(Jcdetail.TYPE_PROPERTY, 17));
			e = e.andExp(ExpressionFactory.matchExp(Jcdetail.GLPERIOD_PROPERTY, gl));
			SelectQuery s = new SelectQuery(Jcdetail.class, e);
			Jcdetail jc = null;
			List jcs = context.performQuery(s);
			if (!jcs.isEmpty()) jc = (Jcdetail) jcs.get(0);
			DecimalFormat df = new DecimalFormat("0.00");
			Date date = new Date(System.currentTimeMillis());
			if (jc != null) op = UPDATED;
			else {
				Jccat cat = (Jccat) DataObjectUtils.objectForQuery(context, 
						new ObjectIdQuery(getCodePK("Jccat", code)));
				if (cat == null) proceed = updateCode(code) == CREATED;
				jc = (Jcdetail) context.newObject(Jcdetail.class);
				jc.setCatnum(code.getCostCode());
				jc.setGlperiod(gl);
				jc.setJobnum(code.getJobNum());
				jc.setPhasenum(code.getDivision());
				jc.setType(JC_DETAIL_ESTIMATE);
				jc.setCost(0d);
				jc.setJcunique(0);
				jc.setHours(0d);
			}
			jc.setDes1("[#=" + df.format(code.getAmount()) + "]");
			jc.setDate(date);
			jc.setDateposted(date);
			if (proceed) context.commitChanges();
		}
		return op;
	}
	
	@Override
	public Result updateSubcontract(Subcontract sub) throws Exception {
		CEHessian ce = getCEHessian();
		Code code = sub.getCode();
		Jccat jccat = getJccat(code);
		if (jccat == null){
			int temp = updateCode(code);
			if (temp != CREATED) return new Result(Action.NO_CODE, getMessage(temp));
		}
		Vendor vendor = getVendor(sub.getAltCompanyId());
		if (vendor == null) return new Result(Action.NO_COMPANY);
		Result result = ce.updateSubcontract(sub, map(code.getPhaseCode()).next());
		return result;
	}

	@Override
	public void setInitParameters(String url, String user, String password,
			int siteId) throws Exception {
		hpf = new HessianProxyFactory();
		hpf.setUser(user);
		hpf.setPassword(password);
		this.url = url;
		connection = new HessianConnection(url + "cayenne-service", user, password, null);
		DataChannel channel = new ClientChannel(connection);
		context = new CayenneContext(channel);
		this.siteId = siteId;
		init();
	}
	
	private CEHessian getCEHessian() throws MalformedURLException {
		return (CEHessian) hpf.create(CEHessian.class, url + "hessian-service");
	}
	
	public double getBudgetChangeTotal(Code code) throws Exception {
		return getCEHessian().getBudgetChangeTotal(code, mapFirst(code.getPhaseCode()) 
			+ JC_DETAIL_CHANGE_OFFSET);
	}

	final private int JC_CO_STEP_APPROVED = 20;
	final private int JC_DETAIL_CO_TYPE = 19;
	final private int JC_DETAIL_ESTIMATE = 17;
	final private int JC_DETAIL_CHANGE_OFFSET = 32;
	
	@Override
	public CR getCR(String jobNum, String crNum) throws Exception {
		Jcchangeorder co = getJcchangeorder(jobNum, crNum);
		CR cr = null;
		if (co != null) {
			cr = new CR();
			cr.setTitle(co.getDes());
			cr.setDescription(co.getNotes());
			try {
				cr.setNum(co.getOrdernum());
			} catch (NumberFormatException e) { cr.setNum("0"); }
			cr.setDate(co.getDate());
			cr.setCoNum(cr.getCoNum());
			cr.setJobNum(jobNum);
			Jcchangeorderstep jcs;
			List<Jcchangeorderstep> steps = co.getChangeordersteps();
			if (steps != null) {
				for (Iterator<Jcchangeorderstep> i = steps.iterator(); i.hasNext(); ){
					jcs = i.next();
					switch(jcs.getType()) {
					case JC_CO_STEP_SENT:
						cr.setSubmitDate(jcs.getDate());
						cr.setRecipient(jcs.getWho());
						break;
					case JC_CO_STEP_APPROVED:
						cr.setApprovedDate(jcs.getDate());
						cr.setSigner(jcs.getWho());
						break;
					}
				}
			}
			steps = null;
		}
		return cr;
	}
	
	private Jcchangeorder getJcchangeorder(String jobnum, String ordernum) {
		Map<String, String> map = new HashMap<String, String>();
		map.put("jobnum", jobnum);
		map.put("ordernum", ordernum);
		return (Jcchangeorder) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Jcchangeorder", map)));
	}

	@Override
	public CRD getCRD(CRD crd) throws Exception {
		Code code = crd.getCode();
		CRD crd2 = null;
		if (code != null) {
			CR cr = getCR(crd.getCode().getJobNum(), crd.getCrNum());
			if (cr != null) {
				crd2 = new CRD();
				crd2.setCode(code);
				Jcdetail jc = getChangeOrderDetail(code, cr.getNum(), 
					JC_DETAIL_CO_TYPE + map(code.getPhaseCode()).next());
				if (jc != null) crd2.setOwner(jc.getCost());
				jc = getChangeOrderDetail(code, cr.getNum(), JC_DETAIL_CHANGE_OFFSET
					+ map(code.getPhaseCode()).next());
				if (jc != null) crd2.setBudget(jc.getCost());
				crd2.setCrNum(crd.getCrNum());
			}
		}
		Subcontract sub = crd.getSub();
		if (sub != null) {
			if (sub.getAltContractId() != null)
				sub = getSubcontract(sub.getAltContractId(), sub.getCode().getPhaseCode());
			else sub = getSubcontract(sub);
			if (sub != null) {
				CRD temp = getCEHessian().getCA(crd);
				if (temp != null) {
					if (crd2 == null){
						crd2 = new CRD();
						crd2.setCode(sub.getCode());
					}
					crd2.setSub(sub);
					crd2.setContract(temp.getContract());
					crd2.setSubCANum(temp.getSubCANum());
					crd2.setDate(temp.getDate());
					crd2.setText(temp.getText());
					crd2.setCaAltId(temp.getCaAltId());
				}
			}
		}
		return crd2;
	}

	@SuppressWarnings("unchecked")
	private Jcdetail getChangeOrderDetail(Code code, String ordernum, int type) {
		Expression e = ExpressionFactory.matchExp(Jcdetail.JOBNUM_PROPERTY, 
				code.getJobNum());
		e = e.andExp(ExpressionFactory.matchExp(
			Jcdetail.PHASENUM_PROPERTY, code.getDivision()));
		e = e.andExp(ExpressionFactory.matchExp(
			Jcdetail.CATNUM_PROPERTY, code.getCostCode()));
		e = e.andExp(ExpressionFactory.matchExp(
			Jcdetail.TYPE_PROPERTY, type));
		e = e.andExp(ExpressionFactory.matchExp(
			Jcdetail.PONUM_PROPERTY, ordernum));
		SelectQuery s = new SelectQuery(Jcdetail.class, e);
		List l = context.performQuery(s);
		if (l != null && l.size() == 1) return (Jcdetail) l.get(0);
		else return null;
	}
	
	@Override
	public Result updateCR(CR cr) throws Exception {
		return getCEHessian().updateCR(cr);
	}

	@Override
	public Result updateCRD(CRD crd) throws Exception {
		Jccat cat = getJccat(crd.getCode());
		if (cat == null) {
			int temp = updateCode(crd.getCode());
			if (temp != CREATED) return new Result(Action.NO_CODE, 
				Action.NO_CODE.getMessage() + ": " + getMessage(temp));
		}
		Result r = getCEHessian().updateCRD(crd, mapFirst(crd.getCode().getPhaseCode()), gl);
		return r;
	}

	@Override
	public Result deleteCR(CR cr) throws Exception {
		return getCEHessian().deleteCR(cr);
	}
	
	@Override
	public Result deleteCRD(CRD crd) throws Exception {
		log.debug("Called deleteCRD");
		Result result = new Result(Action.NO_ACTION);
		CR cr = getCR(crd.getCode().getJobNum(), crd.getCrNum());
		if (cr != null) {
			Jcdetail jcd = getChangeOrderDetail(crd.getCode(), cr.getNum(), JC_DETAIL_CO_TYPE);
			if (jcd != null) context.deleteObject(jcd);
			if (jcd != null) {
				context.deleteObject(jcd);
				if (log.isDebugEnabled()) log.debug("Deleted jcdetail: " + jcd);
			}
			Integer i = new Integer(JC_DETAIL_CHANGE_OFFSET + map(crd.getCode().getPhaseCode()).next());
			jcd = getChangeOrderDetail(crd.getCode(), cr.getNum(), i);
			if (jcd != null) context.deleteObject(jcd);
			if (jcd != null) {
				context.deleteObject(jcd);
				if (log.isDebugEnabled()) log.debug("Deleted jcdetail: " + jcd);
			}
			result = new Result(Action.DELETED);
		}
		Subcontract sub = crd.getSub();
		if (sub != null) {
			log.debug("Deleting sub: " + sub.getAltContractId());
			result = getCEHessian().deleteCA(crd);
		}
		context.commitChanges();
		return result;
	}

	@Override
	public double getCROwner(CR cr) throws Exception {
		return getCEHessian().getCROwner(cr);
	}
	
	public double getCRDOwner(String id) throws Exception {
		double amount = 0;
		String sql = "select crd.cr_id, jcd.job_id, division, cost_code from job_cost_detail as jcd join " +
				"change_request_detail as crd using(cost_code_id) where crd_id = " + id;
		ResultSet rs = null;
		Database db = new Database();
		try {
			rs = db.dbQuery(sql);
			if (rs.first() && rs.getInt("cr_id") != 0) {
				sql = "select sum(amount + fee + bonds) as owner from change_request_detail as crd " +
						"join job_cost_detail as jcd using(cost_code_id) where cost_code = '" +
						rs.getString("cost_code") + "' and division = '" + rs.getString("division") + "' " +
						"and jcd.job_id = " + rs.getString("job_id") + " and cr_id = " + rs.getString("cr_id");
				if (log.isDebugEnabled()) log.debug("performing: " + sql);
				rs.getStatement().close();
				rs = db.dbQuery(sql);
				if (rs.first()) amount = rs.getDouble(1);
			}
		} catch (SQLException e) {
			throw new Exception("Exception getting owner amount", e);
		} finally {
			try {
				if (rs != null) rs.getStatement().close();
				rs = null;
			} catch (SQLException e) {}
			db.disconnect();
		}
		return amount;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void prepareForAccess() throws Exception {
		List test = null;
		try {
			SQLTemplate sql = new SQLTemplate("Jcdetail", "select * from jcdetail where serialnum = 0");
			test = context.performQuery(sql);
		} catch (CayenneRuntimeException e) {
			DataChannel channel = context.getChannel();
			if (channel instanceof ClientChannel) {
				// Try resetting the channel
				EventManager ev = channel.getEventManager();
				if (ev != null) ev.shutdown();
				connection = new HessianConnection(connection.getUrl(), connection.getUserName(), 
						connection.getPassword(), connection.getSharedSessionName());
				channel = new ClientChannel(connection);
				context = new CayenneContext(channel);
			}
		} finally {
			if (test != null) {
				test.clear();
				test = null;
			}
		}
	}

	@Override
	public Result deleteSubcontact(Subcontract sub) throws Exception {
		return getCEHessian().deleteSubcontract(sub);
	}

	@Override
	public Subcontract getSubcontract(Subcontract sub) throws Exception {
		return getCEHessian().getSubcontract(sub);
	}
	
	public List<String> getRoutes() throws Exception {
		return getCEHessian().getRoutes();
	}

	@Override
	public String getWebConfigJspName() {
		return "ceSettings.jsp";
	}

	@Override
	public boolean hasRouting() {
		return true;
	}
	
	@Override
	public boolean hasDocuments() {
		return true;
	}

	@Override
	public List<VoucherAttachment> getVoucherAttachments(String id)
			throws Exception {
		return getCEHessian().getVoucherAttachments(id);
	}

	@Override
	public java.io.ByteArrayOutputStream getVoucherAttachment(String id)
			throws Exception {
		// Does nothing
		return null;
	}

	@Override
	public Route getVoucherRouteByVoucher(String voucherId) throws Exception {
		return getCEHessian().getVoucherRouteByVoucher(voucherId, getGroupCode());
	}

	private String getGroupCode() throws Exception {
		if (groupCode == null) {
			Database db = null;
			ResultSet rs = null;
			try {
				db = new Database();
				rs = db.dbQuery("select val from settings where id = 'ce" + siteId
					+ "' and name = 'route'");
				if (rs.first()) groupCode = rs.getString(1);
			} catch (SQLException e) {
				log.error("getGroupCode(): error performing query", e);
			} finally {
				if (rs != null) rs.getStatement().close();
				if (db != null) db.disconnect();
			}
			if (groupCode == null) throw new Exception("getVoucherRouteByVoucher: "
				+ "cannot find group code in settings table id=ce" + siteId
				+ ", name=route");
		}
		return groupCode;
	}
	
	@Override
	public void setVoucherRoute(Route route) throws Exception {
		getCEHessian().setVoucherRoute(route, getGroupCode());
	}

	@Override
	public Route getVoucherRoute(String routeId) throws Exception {
		return getCEHessian().getVoucherRoute(routeId);
	}

	@Override
	public List<Voucher> getRoutedVouchers() throws Exception {
		List<String> vns = getCEHessian().getRoutedVoucherNums(getGroupCode());
		List<Voucher> vs = new ArrayList<Voucher>();
		Voucher v;
		for (Iterator<String> i = vns.iterator(); i.hasNext(); ) {
			v = getVoucher(i.next());
			if (v != null) vs.add(v);
		}
		return vs;
	}

	@Override
	public void addVoucherLink(String voucherID, long documentId, String key, 
			String siteUrl)	throws Exception {
		getCEHessian().setVoucherURL(voucherID, documentId, key, siteUrl);		
	}

}
