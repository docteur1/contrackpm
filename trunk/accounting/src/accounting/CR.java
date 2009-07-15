package accounting;

import java.sql.Date;

public class CR implements java.io.Serializable {

	private static final long serialVersionUID = 1L;
	private String title;
	private String description;
	private String num;
	private String jobNumr;
	private Date dater;
	private Date submitDate;
	private Date approvedDate;
	private String signer;
	private String recipient;
	private String coNum;
	private CR oldcr;
	
	public Date getDate() {
		return dater;
	}
	public void setDate(Date date) {
		this.dater = date;
	}
	public Date getSubmitDate() {
		return submitDate;
	}
	public void setSubmitDate(Date submitDate) {
		this.submitDate = submitDate;
	}
	public Date getApprovedDate() {
		return approvedDate;
	}
	public void setApprovedDate(Date approvedDate) {
		this.approvedDate = approvedDate;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getNum() {
		return num;
	}
	public void setNum(String num) {
		this.num = num;
	}
	public String getJobNum() {
		return jobNumr;
	}
	public void setJobNum(String jobNum) {
		this.jobNumr = jobNum;
	}
	public String getSigner() {
		return signer;
	}
	public void setSigner(String signer) {
		this.signer = signer;
	}
	public String getRecipient() {
		return recipient;
	}
	public void setRecipient(String recipient) {
		this.recipient = recipient;
	}
	public String getCoNum() {
		return coNum;
	}
	public void setCoNum(String coNum) {
		this.coNum = coNum;
	}
	public void setOld(CR old) {
		this.oldcr = old;
	}
	public CR getOld() {
		return oldcr;
	}
}
