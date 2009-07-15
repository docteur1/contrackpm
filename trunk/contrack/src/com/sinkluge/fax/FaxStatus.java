package com.sinkluge.fax;

public class FaxStatus implements java.io.Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private boolean hasError = false;
	private int inQueue = 0;
	private String message = null;
	private boolean resetMessage = false;
	
	public FaxStatus(String message) {
		inQueue = 1;
		this.message = message;
	}
	
	public boolean hasError() {
		return hasError;
	}
	public void setHasError(boolean hasError) {
		this.hasError = hasError;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public boolean resetMessage() {
		return resetMessage;
	}
	public void setResetMessage(boolean resetMessage) {
		this.resetMessage = resetMessage;
	}
	public int getQueue() {
		return inQueue;
	}
	public void setQueue(int queue) {
		inQueue = queue;
	}
	public void decrementQueue() {
		inQueue--;
	}
	
	public void incrementQueue() {
		inQueue++;
	}
	
}
