package com.sinkluge;

import com.sinkluge.security.Name;

public enum Type {
	
	MY_TRANSMITTAL("TR", true, true, null, null),
	TRANSMITTAL ("TR", true, true, Name.TRANSMITTALS, null),
	RFI ("RF", true, true, Name.RFIS, null),
	SUBMITTAL ("SL", true, true, Name.SUBMITTALS, "Submittal"),
	CR ("CR", true, true, Name.CHANGES, null),
	CO ("CO", true, true, Name.CHANGES, null),
	CRD ("CD", true, true, Name.CHANGES, null),
	COMPANY ("CP", false, false, null, null),
	CONTACT ("CN", false, false, null, null),
	PROJECT ("PJ", false, false, Name.PROJECT, null),
	SUBCONTRACT ("SA", false, false, Name.SUBCONTRACTS, null),
	PR ("PR", true, true, Name.SUBCONTRACTS, null),
	OPR ("OP", true, true, Name.SUBCONTRACTS, null),
	LETTER ("LT", true, true, Name.LETTERS, null),
	COMPANY_COMMENT("CC", false, false, null, null),
	COSTS ("CS", false, false, Name.COSTS, null),
	NONE (null, false, false, null, null);

	private final String code;
	private final boolean canEmail;
	private final boolean canPrint;
	private final Name name;
	private final String friendly;
	private Type (String code, boolean canEmail, boolean canPrint, Name name, String friendly) {
		this.code = code;
		this.canEmail = canEmail;
		this.canPrint = canPrint;
		this.name = name;
		this.friendly = friendly;
	}
	public String getFriendlyName() {
		return friendly == null ? this.name() : friendly;
	}
	public String getCode() {
		return code;
	}
	public Name getSecurityName() {
		return name;
	}

	public boolean canEmail() {
		return canEmail;
	}

	public boolean canPrint() {
		return canPrint;
	}
	
}
