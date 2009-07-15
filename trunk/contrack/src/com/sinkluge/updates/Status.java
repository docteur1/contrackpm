package com.sinkluge.updates;

public enum Status {

	ERROR,
	COMPLETE,
	NOT_STARTED,
	NO_UPDATES,
	PROCESSING;
	
	private String message = null;

	public void setMessage(String message) {
		this.message = message;
	}

	public String getMessage() {
		return message;
	}
	
}
