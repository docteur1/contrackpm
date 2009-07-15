package com.sinkluge;

import java.net.MalformedURLException;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

public class ContextListener implements ServletContextListener {

	public void contextDestroyed(ServletContextEvent sce) {

	}

	public void contextInitialized(ServletContextEvent sce) {
		try {
			if (System.getProperty("com.sinkluge.Test") != null) 
				PropertyConfigurator.configure(sce.getServletContext().getResource(
					"/WEB-INF/classes/log4j_test.properties"));
		} catch (MalformedURLException e) {
			Logger.getLogger(ContextListener.class).fatal("Cannot load log4j_test.properties", e);
		}
	}

}
