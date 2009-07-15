package com.sinkluge.asterisk;

public class Extension implements Comparable<Extension> {

	private String ext;
	private String channel;
	private String user = null;

	public Extension(String ext, String channel) {
		this.channel = channel;
		this.ext = ext;
	}

	public void setChannel(String channel) {
		this.channel = channel;
	}

	public String getChannel() {
		return channel;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getUser() {
		return user;
	}

	public int compareTo(Extension o) {
		return ext.compareTo(o.getExt());
	}

	public String toString() {
		return "[Extension ext='" + ext + "', channel='" + channel
				+ "', user='" + user + "']";
	}

	public void setExt(String ext) {
		this.ext = ext;
	}

	public String getExt() {
		return ext;
	}
}