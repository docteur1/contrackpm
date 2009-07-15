package accounting;

import java.util.Date;

public class VoucherDistribution implements Comparable<VoucherDistribution> {

	private String voucherId;
	private Code code;
	private double amount;
	private double discount;
	private double retention;
	private double paid;
	private String description;
	private Date date;
	
	public String getVoucherId() {
		return voucherId;
	}
	public void setVoucherId(String voucherId) {
		this.voucherId = voucherId;
	}
	public Code getCode() {
		return code;
	}
	public void setCode(Code code) {
		this.code = code;
	}
	public double getAmount() {
		return amount;
	}
	public void setAmount(double amount) {
		this.amount = amount;
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
	public double getPaid() {
		return paid;
	}
	public void setPaid(double paid) {
		this.paid = paid;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public Date getDate() {
		return date;
	}
	public int compareTo(VoucherDistribution arg0) {
		return date != null ? date.compareTo(arg0.getDate()) :
			code.compareTo(arg0.getCode());
	}
	
}
