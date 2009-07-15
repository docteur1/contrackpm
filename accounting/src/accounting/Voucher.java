package accounting;

import java.util.Date;
import java.util.ArrayList;
import java.util.List;

public class Voucher implements Comparable<Voucher> {

	private String id;
	private List<VoucherDistribution> vds = new ArrayList<VoucherDistribution>();
	private String description;
	private String name;
	private String invoiceNum;
	private String poNum;
	private Date date;
	private double amount;
	private double paid;
	private double discount;
	private double retention;
	private String accountCompanyId;
	private int companyId;
	private int payRequestId;
	private List<Check> checks = new ArrayList<Check>();
	
	public List<Check> getChecks() {
		return checks;
	}
	
	public void addCheck(Check check) {
		checks.add(check);
	}
	
	public void removeCheck(Check check) {
		checks.remove(check);
	}

	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public List<VoucherDistribution> getVoucherDistributions() {
		return vds;
	}
	public void addVoucherDistribution(VoucherDistribution vd) {
		vds.add(vd);
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getInvoiceNum() {
		return invoiceNum;
	}
	public void setInvoiceNum(String invoiceNum) {
		this.invoiceNum = invoiceNum;
	}
	public String getPoNum() {
		return poNum;
	}
	public void setPoNum(String poNum) {
		this.poNum = poNum;
	}
	public Date getDate() {
		return date;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public double getAmount() {
		return amount;
	}
	public void setAmount(double amount) {
		this.amount = amount;
	}
	public double getPaid() {
		return paid;
	}
	public void setPaid(double paid) {
		this.paid = paid;
	}
	public double getDiscount() {
		return discount;
	}
	public void setDiscount(double discount) {
		this.discount = discount;
	}
	public double getRetention() {
		return retention;
	}
	public void setRetention(double retention) {
		this.retention = retention;
	}
	public String getAccountCompanyId() {
		return accountCompanyId;
	}
	public void setAccountCompanyId(String accountCompanyId) {
		this.accountCompanyId = accountCompanyId;
	}
	public int getCompanyId() {
		return companyId;
	}
	public void setCompanyId(int companyId) {
		this.companyId = companyId;
	}
	public int getPayRequestId() {
		return payRequestId;
	}
	public void setPayRequestId(int payRequestId) {
		this.payRequestId = payRequestId;
	}
	public int compareTo(Voucher voucher) {
		return date.compareTo(voucher.getDate());
	}
	
}
