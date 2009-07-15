package accounting;

import java.util.Date;


public class CRD implements java.io.Serializable {

	private static final long serialVersionUID = 1L;
	private double budget = 0;
	private CRD oldd = null;
	private double contract = 0;
	private Subcontract subc = null;
	private double owner = 0;
	private int subCANum = 0;
	private String caNum = null;
	private Code codec = null;
	private String crNum = null;
	private String title;
	private String text;
	private Date dateq;
	private boolean approved = false;
	private String caAltId = null;
	
	public String getCrNum() {
		return crNum;
	}

	public void setCrNum(String crNum) {
		this.crNum = crNum;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public int getSubCANum() {
		return subCANum;
	}
	
	public void setSubCANum(int subCANum) {
		this.subCANum = subCANum;
	}
	public Code getCode() {
		return codec;
	}
	public void setCode(Code code) {
		this.codec = code;
	}
	public double getContract() {
		return contract;
	}
	public void setContract(double contract) {
		this.contract = contract;
	}
	public double getBudget() {
		return budget;
	}
	public void setBudget(double budget) {
		this.budget = budget;
	}
	public double getOwner() {
		return owner;
	}
	public void setOwner(double owner) {
		this.owner = owner;
	}
	public void setOld(CRD old) {
		this.oldd = old;
	}
	public CRD getOld() {
		return oldd;
	}
	public void setSub(Subcontract sub) {
		this.subc = sub;
	}
	public Subcontract getSub() {
		return subc;
	}
	public void setText(String text) {
		this.text = text;
	}
	public String getText() {
		return text;
	}
	public void setDate(Date date) {
		this.dateq = date;
	}
	public Date getDate() {
		return dateq;
	}

	public void setCaNum(String caNum) {
		this.caNum = caNum;
	}

	public String getCaNum() {
		return caNum;
	}

	public void setApproved(boolean approved) {
		this.approved = approved;
	}

	public boolean isApproved() {
		return approved;
	}

	public void setCaAltId(String caAltId) {
		this.caAltId = caAltId;
	}

	public String getCaAltId() {
		return caAltId;
	}
	
}
