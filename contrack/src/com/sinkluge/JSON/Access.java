package com.sinkluge.JSON;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

/**
 * Servlet Filter implementation class Access
 */
public class Access implements Filter {

	private Logger log;

	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {
	}

	/**
	 * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	 */
	public void doFilter(ServletRequest request, ServletResponse response, 
			FilterChain chain) throws IOException, ServletException {
		try {
			HttpServletRequest req = (HttpServletRequest) request;
			HttpSession session = req.getSession(false);
			if (session != null) {
				if (log.isTraceEnabled()) log.trace("Requested: " + 
						req.getServletPath());
				if (!req.getServletPath().matches("^/JSON-RPC$")) {
					session.setAttribute("lastAccessedTime", session.getLastAccessedTime());
				}
			}
		} catch (ClassCastException e) {
			e.printStackTrace();
		}
		chain.doFilter(request, response);
	}

	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig fConfig) throws ServletException {
		log = Logger.getLogger(Access.class);
	}

}
