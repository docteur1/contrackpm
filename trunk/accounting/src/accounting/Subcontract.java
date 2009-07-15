package accounting;

import java.util.Date;

public class Subcontract implements java.io.Serializable {
	
	private static final long serialVersionUID = 1L;
	private Code codes;
	private String descriptions;
	private Date dates;
	private String altCompanyIds = null;
	private String texts;
	private int companyIds;
	private int contractId = 0;
	private String altContractIds;
	private double amounts;
	private double retention;
	private Subcontract olds;

	public String getDescription() {
		return descriptions;
	}
	public void setDescription(String description) {
		this.descriptions = description;
	}
	public Date getDate() {
		return dates;
	}
	public void setDate(Date date) {
		this.dates = date;
	}
	public double getAmount() {
		return amounts;
	}
	public void setAmount(double amount) {
		this.amounts = amount;
	}
	public String getAltCompanyId() {
		return altCompanyIds;
	}
	public void setAltCompanyId(String altCompanyId) {
		this.altCompanyIds = altCompanyId;
	}
	public void setCompanyId(int companyId) {
		this.companyIds = companyId;
	}
	public int getCompanyId() {
		return companyIds;
	}
	public Code getCode() {
		return codes;
	}
	public void setCode(Code code) {
		this.codes = code;
	}
	public void setContractId(int contractId) {
		this.contractId = contractId;
	}
	public int getContractId() {
		return contractId;
	}
	public void setText(String text) {
		this.texts = text;
	}
	public String getText() {
		return texts;
	}
	public void setRetention(double retention) {
		this.retention = retention;
	}
	public double getRetention() {
		return retention;
	}
	public void setAltContractId(String altContractId) {
		this.altContractIds = altContractId;
	}
	public String getAltContractId() {
		return altContractIds;
	}
	public void setOld(Subcontract old) {
		this.olds = old;
	}
	public Subcontract getOld() {
		return olds;
	}
}
