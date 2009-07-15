package com.sinkluge;

import java.io.File;
import java.net.MalformedURLException;
import java.util.Enumeration;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import kf.KF;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import accounting.Accounting;

import com.sinkluge.updates.Updater;

public class ContextListener implements ServletContextListener {
	
	public void contextInitialized(ServletContextEvent sce) {
		Logger log = Logger.getLogger(ContextListener.class);
		ServletContext application = sce.getServletContext();
		try {
			if (System.getProperty("com.sinkluge.Test") != null) {
				PropertyConfigurator.configure(application.getResource("/WEB-INF/classes/log4j_test.properties"));
				log.debug("RUNNING IN TEST MODE");
			} 
		} catch (MalformedURLException e) {
			log.fatal("Cannot load log4j_test.properties", e);
		}
		log.info("Context Listener Started");
		try {
			String path = application.getRealPath("");
			Info in = new Info();
			//in.max_pwd_age = LdapPwd.getMaxPwdAge(in);
			in.startTime = new java.util.Date().getTime();
			in.path = path;
			File buildFile = new File(in.path + "/META-INF/build");
			if (buildFile.exists()) in.build = FileUtils.readFileToString(buildFile);
			in.testMode = System.getProperty("com.sinkluge.Test") != null;
			/* 
			 * Run in new thread and wait for return somewhere else
			 * otherwise tomcat will timeout on the startup
			 */
			Updater updater = new Updater(in);
			new Thread(updater).start();
			application.setAttribute("updater", updater);
			Scheduler scheduler = new Scheduler(in, application);
			scheduler.start();
			application.setAttribute("scheduler", scheduler);
			application.setAttribute("in", in);
		} catch (Exception e) {
			log.fatal("Error configuring context", e);
		}
	}
	
	@SuppressWarnings("unchecked")
	public void contextDestroyed(ServletContextEvent sce) {
		Enumeration attNames = sce.getServletContext().getAttributeNames();
		String attName;
		Object obj;
		Accounting acc;
		KF kf;
		//Destroy context bound cayenne stuff...
		while (attNames.hasMoreElements()) {
			attName = (String) attNames.nextElement();
			if (attName.indexOf("acc") != -1 || attName.indexOf("kf") != -1) {
				obj = sce.getServletContext().getAttribute(attName);
				if (obj instanceof Accounting) {
					acc = (Accounting) obj;
					acc.shutdown();
				} else if (obj instanceof KF) {
					kf = (KF) obj;
					kf.shutdown();
				}
			}
		}
		Scheduler scheduler = (Scheduler) sce.getServletContext().getAttribute("scheduler");
		scheduler.shutdown();
	}
	
	
}
