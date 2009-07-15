package com.sinkluge.asterisk;

import java.util.EventListener;

public interface CallEventListener extends EventListener {

	public void onStatusUpdate(CallEvent ce);
	
	public void onCallTerminate(CallEvent ce);
	
	public void onError(CallEvent ce);
}
