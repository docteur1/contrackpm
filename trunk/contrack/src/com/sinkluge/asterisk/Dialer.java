package com.sinkluge.asterisk;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.asteriskjava.live.AsteriskChannel;
import org.asteriskjava.live.ManagerCommunicationException;
import org.asteriskjava.live.NoSuchChannelException;

import com.sinkluge.Info;

public class Dialer implements Serializable {

	private static final long serialVersionUID = 1L;
	private Asterisk asterisk = null;
	private AsteriskChannel ac = null;
	private List<String> log = new ArrayList<String>();
	private String status;
	private Logger logger = Logger.getLogger(Dialer.class);
	
	public Dialer(Info in) {
		asterisk = new Asterisk(in);
	}
	
	public void dial(Extension e, String number, String clid) {
		asterisk.connect();
		asterisk.addEventListener(new DialerEvents(this));
		changeStatus("Ringing the specified extension");
		number = number.replaceAll("\\(|\\)|-|\\s", "");
		ac = asterisk.placeCall(e, number, clid);
		logger.debug("dial: dialing " + number);
	}
	
	public void changeStatus(String status) {
		this.status = status;
		if (status != null) if (!log.contains(status)) log.add(status);
		if (logger.isDebugEnabled()) logger.debug("updated status: " + status);
	}
	
	public List<String> getLog() {
		return log;
	}
	
	public String getStatus() {
		return status;
	}
	
	public boolean isFinished() {
		return !asterisk.isConnected();
	}
	
	protected void log(String message, Exception e) {
		logger.error(message, e);
		for(StackTraceElement ste : e.getStackTrace()) 
			log.add(ste.toString());
	}

	
	public class DialerEvents implements CallEventListener {

		public final Dialer dialer;
		
		public DialerEvents(Dialer dialer) {
			this.dialer = dialer;
		}
		

		public void onError(CallEvent ce) {
			dialer.changeStatus(ce.getMessage());
			dialer.disconnect();
			Exception e = (Exception) ce.getSource();
			dialer.log("An ERROR event occured", e);
		}

		public void onStatusUpdate(CallEvent ce) {
			dialer.changeStatus(ce.getMessage());
		}
		
		public void onCallTerminate(CallEvent ce) {
			logger.debug("onCallTerminate: disconnecting");
			dialer.changeStatus(ce.getMessage());
			dialer.disconnect();
		}

	}

	
	public void hangup() {
		try {
			ac.hangup();
		} catch (ManagerCommunicationException e) {
			log("ERROR on hangup", e);
		} catch (NoSuchChannelException e) {
			log("ERROR on hangup", e);
		} finally {
			disconnect();
		}
	}
	
	public void disconnect() {
		if (asterisk != null) {
			logger.debug("disconnect: disconnecting");
			asterisk.disconnect();
		}
	}
	
	@Override
	protected void finalize() {
		disconnect();
	}

}
