package com.sinkluge;

import org.apache.log4j.Logger;

import com.sinkluge.asterisk.Asterisk;

public class RunEveryFifteen implements Runnable {

	private Info in;
	
	protected RunEveryFifteen(Info in) {
		this.in = in;
	}
	
	Logger log = Logger.getLogger(RunEveryFifteen.class);
	
	public void run() {
		try {
			Group lg = Group.getInstance(in);
			lg.run();
			if (in.hasAsterisk) {
				Asterisk as = new Asterisk(in);
				as.run();
			}
		} catch (ClassNotFoundException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (InstantiationException e) {
			log.error("run: " + e.getMessage(), e);
		} catch (IllegalAccessException e) {
			log.error("run: " + e.getMessage(), e);
		}
	}

}
