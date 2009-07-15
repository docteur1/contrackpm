package accounting;

public class Check {

	private int checkNum;
	private String voucherNum;
	private double amount;
	private String name;
	
	public int getCheckNum() {
		return checkNum;
	}
	public void setCheckNum(int checkNum) {
		this.checkNum = checkNum;
	}
	public String getVoucherNum() {
		return voucherNum;
	}
	public void setVoucherNum(String voucherNum) {
		this.voucherNum = voucherNum;
	}
	public double getAmount() {
		return amount;
	}
	public void setAmount(double amount) {
		this.amount = amount;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	
}
