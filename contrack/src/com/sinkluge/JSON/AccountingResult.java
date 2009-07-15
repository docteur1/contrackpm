package com.sinkluge.JSON;

import java.io.Serializable;

public class AccountingResult implements Serializable {
	private static final long serialVersionUID = 1L;
	private String name;
	private String id;
	
	public AccountingResult (String id, String name) {
		this.name = name;
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
}