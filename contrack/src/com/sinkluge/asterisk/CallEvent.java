package com.sinkluge.asterisk;

import java.util.EventObject;

public class CallEvent extends EventObject {

	private static final long serialVersionUID = 1L;

	private String message;
	
	public CallEvent(Object object) {
		super(object);
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
}
