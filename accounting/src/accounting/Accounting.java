package accounting;

import java.io.ByteArrayOutputStream;
import java.util.List;

public abstract class Accounting {

	public static final int CREATED = 0;
	public static final int UPDATED = 1;
	public static final int ERROR = 2;
	public static final int NO_JOB = 3;
	public static final int NO_ACTION = 4;
	public static final int NO_CODE = 5;
	public static final int DELETED = 6;
	public static final int NO_COMPANY = 7;
	public static final int NO_SUBCONTRACT = 8;
	
	public static String getMessage(int msg) {
		switch(msg) {
		case CREATED:
			return "Created";
		case UPDATED:
			return "Saved";
		case ERROR:
			return "Error";
		case NO_JOB:
			return "Project not found";
		case NO_ACTION:
			return "No action needed";
		case NO_CODE:
			return "Cost code not found";
		case DELETED:
			return "Deleted";
		case NO_COMPANY:
			return "Company not found";
		case NO_SUBCONTRACT:
			return "No subcontract found";
		default:
			return "ERROR: Message " + msg + " not found";
		}
	}
	
	@Deprecated
	public abstract void close();
	
	public abstract void shutdown();
	
	public abstract void prepareForAccess() throws Exception;
	
	public abstract void setInitParameters(String url, String user, String password,
			int siteId) throws Exception;
	
	public abstract int updateCode(Code code) throws Exception;
	
	public abstract int deleteCode(Code code) throws Exception;
	
	public abstract List<Code> getCodes(String jobNum) throws Exception;
	
	public abstract Code getCode(Code code) throws Exception;
	
	public abstract Result updateSubcontract(Subcontract con) throws Exception;
	
	public abstract List<Subcontract> getSubcontracts(Code code) throws Exception;
	
	public abstract Subcontract getSubcontract(Subcontract sub) throws Exception;
	
	public abstract Subcontract getSubcontract(String id, String phase) throws Exception;
	
	public abstract int updateEstimate(Code code) throws Exception;
	
	public abstract Voucher getVoucher(String id) throws Exception;
	
	public abstract Voucher getVoucher(int payRequestId) throws Exception;
	
	public abstract List<VoucherDistribution> getVoucherDistributions(Code code) throws Exception;
	
	public abstract Cost getCost(String id) throws Exception;
	
	public abstract List<Cost> getSummedCosts(String jobNum) throws Exception;
	
	public abstract List<Cost> getCosts(Code code) throws Exception;
	
	public abstract List<Cost> getAllCosts(String jobNum) throws Exception;
	
	public abstract Company getCompany(String id) throws Exception;
	
	public abstract Company getCompany(int id) throws Exception;
	
	public abstract Company searchForCompany(String name) throws Exception;
	
	public abstract Result updateCR(CR cr) throws Exception;
	
	public abstract Result updateCRD(CRD crd) throws Exception;
	
	public abstract CR getCR(String jobNum, String crNum) throws Exception;
	
	public abstract double getCROwner(CR cr) throws Exception;
	
	public abstract double getCRDOwner(String id) throws Exception;

	public abstract CRD getCRD(CRD crd) throws Exception;
	
	public abstract Result deleteCR(CR cr) throws Exception;
	
	public abstract Result deleteCRD(CRD crd) throws Exception;
	
	public abstract double getCATotal(String id) throws Exception;
	
	public abstract double getBudgetChangeTotal(Code code)
		throws Exception;
	
	public abstract Result deleteSubcontact(Subcontract sub) throws Exception;
	
	public abstract boolean hasRouting();
	
	public abstract boolean hasDocuments();
	
	public abstract String getWebConfigJspName();
	
	public abstract List<VoucherAttachment> getVoucherAttachments(String id) 
		throws Exception;
	
	public abstract ByteArrayOutputStream getVoucherAttachment(String id)
		throws Exception;
	
	public abstract Route getVoucherRouteByVoucher(String voucherId) throws Exception;
	
	public abstract Route getVoucherRoute(String routeId) throws Exception;
	
	public abstract List<Voucher> getRoutedVouchers() throws Exception;
	
	public abstract void setVoucherRoute(Route route) throws Exception;

	public abstract void addVoucherLink(String voucherID, long documentId, String key,
		String siteUrl) throws Exception;
}
