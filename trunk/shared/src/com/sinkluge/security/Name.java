package com.sinkluge.security;

public enum Name implements java.io.Serializable {
	ADMIN ("Administration", true),
	PROJECT ("Project"), 
	PERMISSIONS ("Permissions"), 
	COSTS ("Costs"),
	ACCOUNTING_DATA ("Accounting Data"),
	CHANGES ("Changes"),
	SUBCONTRACTS("Subcontracts"),
	RFIS("RFIs"),
	SUBMITTALS("Submittals"),
	TRANSMITTALS("Transmittals"),
	LETTERS("Letters"),
	ACCOUNTING("Accounting", true),
	NOT_USED(null, true),
	LABOR_ACCOUNTING_DATA("Labor Accounting Data"),
	UNLOCK_BUDGET("Unlock Budget", true),
	APPROVE_PAYMENT("Approve Payment");
	
	private boolean adminOnly;
	private String name;  
	private Name(String name) {
		this.name = name;
		adminOnly = false;
	}
	private Name(String name, boolean adminOnly) {
		this.name = name;
		this.adminOnly = adminOnly;
	}
	public boolean isAdminOnly() {
		return adminOnly;
	}
	public String getName() {
		return name;
	}
	
}
