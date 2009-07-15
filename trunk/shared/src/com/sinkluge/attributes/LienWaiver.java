package com.sinkluge.attributes;

import java.util.Date;

import com.sinkluge.Type;

public class LienWaiver {
	
	private String companyName;
	private double amount;
	private String address;
	private String city;
	private String state;
	private String zip;
	private String phone;
	private String fax;
	private Date date;
	private String jobCity;
	private String jobState;
	private String type;
	private String id;
	private Type t;
	
	public String getType() {
		return type;
	}
	
	public Type getDocType () {
		return t;
	}
	public void setDocType(Type t) {
		this.t = t;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public double getAmount() {
		return amount;
	}
	public void setAmount(double amount) {
		this.amount = amount;
	}
	public String getCity() {
		return city;
	}
	public void setCity(String city) {
		this.city = city;
	}
	public String getCompanyName() {
		return companyName;
	}
	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}
	public Date getDate() {
		return date;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	public String getFax() {
		return fax;
	}
	public void setFax(String fax) {
		this.fax = fax;
	}
	public String getJobCity() {
		return jobCity;
	}
	public void setJobCity(String jobCity) {
		this.jobCity = jobCity;
	}
	public String getJobState() {
		return jobState;
	}
	public void setJobState(String jobState) {
		this.jobState = jobState;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getZip() {
		return zip;
	}
	public void setZip(String zip) {
		this.zip = zip;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getId() {
		return id;
	}

}
