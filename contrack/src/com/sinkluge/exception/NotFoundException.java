package com.sinkluge.exception;

public class NotFoundException extends RuntimeException {

	private static final long serialVersionUID = 1L;
	
	public NotFoundException () {
		super("The item was not found");
	}
	
	public NotFoundException(Throwable t) {
		super("The item was not found", t);
	}
	
	public NotFoundException(NotFoundException e) {
		super(e.getMessage(), e);
	}
	
	public NotFoundException(String message) {
		super(message);
	}
	
	public NotFoundException(String message, Throwable t) {
		super(message, t);
	}

}
