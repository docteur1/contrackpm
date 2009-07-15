package com.sinkluge.JSON;

public class DialStatus {

	private String log;
	
	private boolean terminated;
	
	public String getLog() {
		return log;
	}

	public String getStatus() {
		return status;
	}

	private String status;
	
	public DialStatus(String log, String status, boolean terminated) {
		this.log = log;
		this.status = status;
		this.terminated = terminated;
	}

	public boolean isTerminated() {
		return terminated;
	}
	
	@Override
	public String toString() {
		return super.toString() + " log: " + log + " status: " + status + " terminated: " + terminated;
	}
	
}
