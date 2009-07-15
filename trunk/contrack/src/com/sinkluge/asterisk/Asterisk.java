package com.sinkluge.asterisk;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.asteriskjava.live.AsteriskChannel;
import org.asteriskjava.live.AsteriskServer;
import org.asteriskjava.live.CallerId;
import org.asteriskjava.live.DefaultAsteriskServer;
import org.asteriskjava.live.ManagerCommunicationException;
import org.asteriskjava.live.NoSuchChannelException;
import org.asteriskjava.live.Voicemailbox;
import org.asteriskjava.manager.AuthenticationFailedException;
import org.asteriskjava.manager.ManagerConnection;
import org.asteriskjava.manager.ManagerEventListener;
import org.asteriskjava.manager.TimeoutException;
import org.asteriskjava.manager.action.SipPeersAction;
import org.asteriskjava.manager.event.ManagerEvent;
import org.asteriskjava.manager.event.PeerEntryEvent;
import org.asteriskjava.manager.event.PeerlistCompleteEvent;

import com.sinkluge.Info;


public class Asterisk implements Runnable, ManagerEventListener {

	private final Info in;
	private AsteriskServer as = null;	
	private Map<String, Extension> extMap = new HashMap<String, Extension>();
	private boolean peerListLoaded = false;
	private Logger log = Logger.getLogger(Asterisk.class);
	
	public Asterisk (Info in) {
		this.in = in;
	}
	
	private List<CallEventListener> eventListeners = new ArrayList<CallEventListener>();
	
	public void addEventListener(CallEventListener listener) {
		synchronized (eventListeners)
        {
            // only add it if its not already there
            if (!this.eventListeners.contains(listener))
            {
                this.eventListeners.add(listener);
            }
        }
	}
	
	public void removeEventListener(final CallEventListener listener)
    {
        synchronized (eventListeners)
        {
            if (this.eventListeners.contains(listener))
            {
                this.eventListeners.remove(listener);
            }
        }
    }
	
	protected void fireCallEvent(CallEvent event) {
		synchronized (eventListeners)
        {
            for (CallEventListener listener : eventListeners)
            {
                try
                {
                    listener.onStatusUpdate(event);
                }
                catch (RuntimeException e)
                {
                    log.warn("Unexpected exception in eventHandler " + listener.getClass().getName(), e);
                }
            }
        }
	}
	
	protected void fireCallTerminated(CallEvent event) {
		synchronized (eventListeners)
        {
            for (CallEventListener listener : eventListeners)
            {
                try
                {
                    listener.onCallTerminate(event);
                    log.debug("fired call Terminated event: " + event);
                }
                catch (RuntimeException e)
                {
                    log.warn("Unexpected exception in eventHandler " + listener.getClass().getName(), e);
                }
            }
        }
	}
	
	protected void fireErrorEvent(CallEvent event) {
		synchronized (eventListeners)
        {
            for (CallEventListener listener : eventListeners)
            {
                try
                {
                    listener.onError(event);
                }
                catch (RuntimeException e)
                {
                    log.warn("Unexpected exception in eventHandler " + listener.getClass().getName(), e);
                }
            }
        }
	}

	protected void connect() {
		/*
		 * We really really really need to pool these connections in case
		 * they get dumped...
		 */
		if (as == null)
			as = new  DefaultAsteriskServer(in.asterisk_host, in.asterisk_port,
				in.asterisk_user, in.asterisk_pass);
		if(log.isDebugEnabled()) log.debug("connect: " + as);
	}
	
	protected boolean isConnected() {
		return as != null;
	}
	
	protected void disconnect() {
		if (as != null) {
			log.debug("disconnect: disconnecting");
			as.shutdown();
			as = null;
		}
	}
	
	@Override
	protected void finalize() {
		disconnect();
	}
	
	protected AsteriskChannel placeCall(Extension e, String phone, String clid) {
		AsteriskChannel ac = null;
		try {
			ac = as.originateToExtension(e.getChannel(), 
				in.asterisk_context, in.asterisk_prefix + phone, 1, 30000, 
				new CallerId(clid != null ? clid : "Contrack", in.asterisk_prefix + phone), null);
			ac.addPropertyChangeListener(new PCL(this));
			/*
			 * The event listener should track this from here on out
			 */
		} catch (ManagerCommunicationException e1) {
			log.warn("placeCall: exception caught", e1);
			CallEvent event = new CallEvent(e1);
			event.setMessage("Error placing call: " + e1.getMessage());
			fireErrorEvent(event);
		} catch (NoSuchChannelException e1) {
			if (e1.getMessage().indexOf("not available") != -1) {
				log.debug("placeCall: user didn't answer own extension");
				CallEvent event = new CallEvent(e1);
				event.setMessage("The specified extension was not answered");
				fireCallTerminated(event);
			} else {
				log.warn("placeCall: specified channel is not found: " + e.getChannel(), e1);
				CallEvent event = new CallEvent(e1);
				event.setMessage("Specified extension is not found! (" + e.getExt()
					+ ") Error: " + e1.getMessage());
				fireErrorEvent(event);
			}
		}
		return ac;
	}
	
	private class PCL implements PropertyChangeListener {
		private final Asterisk asterisk;
		protected PCL (Asterisk asterisk) {
			this.asterisk = asterisk;
		}
		public void propertyChange(PropertyChangeEvent pce) {
			AsteriskChannel ac = (AsteriskChannel) pce.getSource();
			CallEvent ce = new CallEvent(ac);
			if (pce.getPropertyName().equals(AsteriskChannel.PROPERTY_STATE)) {
				log.debug("ended call: " + pce.getNewValue());
				ce.setMessage("Call hungup");
				asterisk.fireCallTerminated(ce);
			} else if (pce.getPropertyName()
					.equals(AsteriskChannel.PROPERTY_DIALED_CHANNEL)) {
				ce.setMessage("Dialing " + ac.getFirstExtension().getExtension());
				asterisk.fireCallEvent(ce);
			} else if (pce.getPropertyName()
					.equals(AsteriskChannel.PROPERTY_LINKED_CHANNEL)) {
				if (ac.getLinkedChannel() != null) {
					ce.setMessage("Connected to " + ac.getFirstExtension().getExtension()
						+ " via " + ac.getLinkedChannel().getName());
				} else ce.setMessage("Disconnected");
				asterisk.fireCallEvent(ce);
			}			
		}	
	}
	
	public void run() {
		connect();
		log.debug("run: start update ext list");
		ManagerConnection mc = as.getManagerConnection();
		log.debug("run: got manager connection");
		mc.addEventListener(this);
		try {
			log.debug("run: login to asterisk manager");
			mc.login();
			log.debug("run: login successful");
			in.asteriskEndpointsReady = false;
			log.debug("starting run\nrun: loading sip peers");
			SipPeersAction spa = new SipPeersAction();
			mc.sendAction(spa, 10000);
			peerListLoaded = false;
			// Wait for 0.5 secs and see if the list as load to continue;
			while (!peerListLoaded) Thread.sleep(500);
			log.debug("run: finished loading sip peers, now loading mailboxes");
			Extension e;
			for (Voicemailbox vm : as.getVoicemailboxes()) {
				if (vm != null) {
					log.debug("run: got vmbox " + vm);
					e = extMap.get(vm.getMailbox());
					if (e != null) e.setUser(vm.getUser());
				}
			}
			in.asterisk_endpoints = new ArrayList<Extension>(extMap.values());
			Collections.sort(in.asterisk_endpoints);
			in.asteriskEndpointsReady = true;
			log.debug("run: end update ext list");
		} catch (NullPointerException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (IllegalStateException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (IOException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (AuthenticationFailedException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (TimeoutException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (InterruptedException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (ManagerCommunicationException e) {
			log.error("run: " + e.getMessage(), e);
		} finally {
			mc.removeEventListener(this);
			disconnect();
		}
	}

	public void onManagerEvent(ManagerEvent event) {
		if (event instanceof PeerEntryEvent) {
			PeerEntryEvent p = (PeerEntryEvent) event;
			if (p.getStatus().indexOf("OK") != -1) {
				log.debug("onManagerEvent: got sip peer " + p);
				extMap.put(p.getObjectName(), 
					new Extension(p.getObjectName(),
						p.getChannelType() + "/" + p.getObjectName()));
			}
		} else if (event instanceof PeerlistCompleteEvent) {
			log.debug("onManagerEvent: finished peerlist loading " + event);
			peerListLoaded = true;
		}
		
	}

}
