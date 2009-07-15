package accounting;

public class Code implements java.io.Serializable, Comparable<Code> {

	private static final long serialVersionUID = 1L;
	private String jobNum;
	private String costCode;
	private String phaseCode;
	private String division;
	private String name;
	private double amount;
	
	public String getJobNum() {
		return jobNum;
	}
	public void setJobNum(String jobNum) {
		this.jobNum = jobNum;
	}
	public String getCostCode() {
		return costCode;
	}
	public void setCostCode(String costCode) {
		this.costCode = costCode;
	}
	public String getPhaseCode() {
		return phaseCode;
	}
	public void setPhaseCode(String phaseCode) {
		this.phaseCode = phaseCode;
	}
	public String getDivision() {
		return division;
	}
	public void setDivision(String division) {
		this.division = division;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public double getAmount() {
		return amount;
	}
	public void setAmount(double amount) {
		this.amount = amount;
	}
	public int compareTo(Code o) {
		int comp = this.getJobNum().compareTo(o.getJobNum());
		if (comp == 0) {
			 comp = this.getDivision().compareTo(o.getDivision());
			 if (comp == 0) {
				 comp = this.getCostCode().compareTo(o.getCostCode());
				 if (comp == 0) comp = this.getPhaseCode().compareTo(o.getPhaseCode());
			 }
		} 
		return comp;
	}
	
}
