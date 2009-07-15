package accounting.ce;

import java.util.List;

import accounting.CR;
import accounting.CRD;
import accounting.Code;
import accounting.Result;
import accounting.Route;
import accounting.Subcontract;
import accounting.VoucherAttachment;

public interface CEHessian {

	public Result updateSubcontract(Subcontract sub, int costtype) throws Exception;
	
	public Result deleteSubcontract(Subcontract sub) throws Exception;
	
	public Subcontract getSubcontractById(String subnum, String phase) throws Exception;
	
	public Subcontract getSubcontract(Subcontract sub) throws Exception;
	
	public List<Subcontract> getSubcontracts(Code code, List<Integer> costtypes) throws Exception;
	
	public Result deleteCA(CRD crd) throws Exception;
	
	public Result deleteCR(CR cr) throws Exception;
	
	public double getCROwner(CR cr) throws Exception;
	
	public CRD getCA(CRD crd) throws Exception;
	
	public Result updateCR(CR cr) throws Exception;
	
	public Result updateCRD(CRD cr, int costtype, int gl) throws Exception;
	
	public double getCATotal(String subnum) throws Exception;
	
	public double getBudgetChangeTotal(Code code, int type) throws Exception;
	
	public List<String> getRoutes() throws Exception;
	
	public Route getVoucherRouteByVoucher(String voucherId, String groupCode) throws Exception;
	
	public Route getVoucherRoute(String routeId) throws Exception;
	
	public void setVoucherRoute(Route route, String groupCode) throws Exception;
	
	public List<VoucherAttachment> getVoucherAttachments(String id) throws Exception;
	
	public List<String> getRoutedVoucherNums(String groupCode) throws Exception;
	
	public abstract void setVoucherURL(String voucherID, Long documentId, String key,
			String siteUrl)	throws Exception;
}
