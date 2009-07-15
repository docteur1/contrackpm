package com.sinkluge;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletContext;

public class Scheduler {
	
	private Info in;
	private ServletContext application;
	
	public Scheduler(Info in, ServletContext application) {
		this.in = in;
		this.application = application;
	}
	
	public void start() throws ClassNotFoundException, 
			InstantiationException, IllegalAccessException {
		everyFifteenService();
		startIndexService();
		if (!in.testMode) errorPollerService();
	}
	
	public void startIndexService() {
		if (!in.testMode) indexService();
	}
	
	public void stopIndexService() {
		if (!in.testMode && idxHandle != null) idxHandle.cancel(true);
	}
	
	private final ScheduledExecutorService scheduler = 
		Executors.newScheduledThreadPool(1);
	
	private ScheduledFuture<?> lgHandle;
	
	private void everyFifteenService() throws ClassNotFoundException, 
			InstantiationException, IllegalAccessException {
		final RunEveryFifteen ref = new RunEveryFifteen(in);
		lgHandle = scheduler.scheduleAtFixedRate(ref, 0, 15*60, TimeUnit.SECONDS);
	}
	
	private ScheduledFuture<?> epHandle;
	
	private void errorPollerService() {
		final ErrorPoller ep = new ErrorPoller(in);
		epHandle = scheduler.scheduleAtFixedRate(ep, 1*60, 60*60, TimeUnit.SECONDS);
	}
	
	private ScheduledFuture<?> idxHandle;
	
	private void indexService() {
		final CacheAndIndexService idx = new CacheAndIndexService(application);
		idxHandle = scheduler.scheduleAtFixedRate(idx, 2*60, 30*60, TimeUnit.SECONDS);
	}
	
	public void shutdown () {
		if (lgHandle != null) {
			lgHandle.cancel(true);
		}
		stopIndexService();
		if (epHandle != null) {
			epHandle.cancel(true);
		}
		scheduler.shutdown();
	}
}

