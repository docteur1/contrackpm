package com.sinkluge.JSON;

public class Message {

	private String message = null;
	private String faxMessage = null;
	private boolean kick = false;
	private boolean prekick = false;
	
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public String getFaxMessage() {
		return faxMessage;
	}
	public void setFaxMessage(String faxMessage) {
		this.faxMessage = faxMessage;
	}
	public boolean isKick() {
		return kick;
	}
	public void setKick(boolean kick) {
		this.kick = kick;
	}
	public void setPrekick(boolean prekick) {
		this.prekick = prekick;
	}
	public boolean isPrekick() {
		return prekick;
	}
	
}
