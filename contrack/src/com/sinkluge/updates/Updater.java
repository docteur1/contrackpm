package com.sinkluge.updates;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.StringTokenizer;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import com.sinkluge.Info;
import com.sinkluge.utilities.Verify;

public class Updater implements Runnable {
	
	private Logger log = Logger.getLogger(Updater.class);
	private Info in;
	private Status status = Status.NOT_STARTED;
	private String message = "";
	private Connection rollback = null;
	private Connection commit = null;

	public Updater(Info in) {
		this.in = in;
	}
	
	private Connection getConnection() throws NamingException, SQLException {
		Context initContext = new InitialContext();
		Context envContext  = (Context) initContext.lookup("java:/comp/env");
		DataSource ds = (DataSource) envContext.lookup("jdbc/contrack");
		return ds.getConnection();
	}
	
	
	private void log(String msg) {
		log(msg, null);
	}
	
	private void log(String msg, Throwable t) {
		if (t != null) log.error(msg, t);
		else log.warn(msg);
		message += msg + "\n";
	}
	
	public void updateDB(File updateSQL) throws IOException, SQLException {
		// You can lose your update file and screw the database if you're not careful here.
		Statement stmt = rollback.createStatement();
		Statement ddl = commit.createStatement();
		String sql = FileUtils.readFileToString(updateSQL);
		// Remove the file now that we are updating...
		log("Updating Database");
		StringTokenizer st = new StringTokenizer(sql, ";");
		String sql2;
		while (st.hasMoreTokens()) {
			sql2 = st.nextToken();
			sql = sql2.toLowerCase();
			if (!Verify.blank(sql)) {
				log("QUERY: \"" + sql2 + "\"");
				// MySQL can't rollback data defition stuff;
				if (sql.indexOf("alter") != -1 | sql.indexOf("create") != -1 | sql.indexOf("drop") != -1) {
					try {
						ddl.executeUpdate(sql2);
						log ("SUCCESSFUL data definition statement");
					} catch (SQLException e) {
						log("FAIL: " + e.getMessage());
					}
				} else log("SUCCESSFUL (rows updated: " + stmt.executeUpdate(sql2) + ")");
			}
		}
		stmt.close();
		ddl.close();
		st = null;
	}

	public void run() {
		status = Status.PROCESSING;
		try {
			if (in.build == null) {
				status = Status.ERROR;
				log("No version found");
				return;
			}
			int build = Integer.parseInt(in.build);
			commit = getConnection();
			Statement stmt = commit.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
			ResultSet rs = stmt.executeQuery("select val, id, name from settings where name = 'build' and id = 'build'");
			if (!rs.first()) {
				status = Status.ERROR;
				log("Version not found in database");
				rs.close();
				stmt.close();
				commit.close();
				return;
			} else if (build > rs.getInt(1)) {
				int current = rs.getInt(1) + 1;
				File file = null;
				Runnable update;
				rollback = getConnection();
				rollback.setAutoCommit(false);
				// Cycle through the version differences
				for (int i = current; i <= build; i++) {
					file = new File(in.path + "/WEB-INF/sql/" + i + ".sql");
					if (file.exists()) updateDB(file);
					try {
						update = (Runnable) Class.forName("com.sinkluge.updates.versions." + i).newInstance();
						update.run();
					} catch (ClassNotFoundException e) {
						// Do nothing, there isn't an update class
					} 
					rollback.commit();
					log("Updated Contrack to build " + i);
					if (!in.testMode) {
						rs.updateInt(1, i);
						rs.updateRow();
						in.build = Integer.toString(i);
					}	
				}
				status = Status.COMPLETE;
				stmt.close();
			} else {
				log("No new updates needed");
				rs.close();
				stmt.close();
				status = Status.COMPLETE;
			}
		} catch (ClassCastException e) {
			handleException("Update class does not implement java.lang.Runnable", e);
		} catch (SQLException e) {
			handleException("SQL Exception", e);
		} catch (InstantiationException e) {
			handleException("", e);
		} catch (IllegalAccessException e) {
			handleException("", e);
		} catch (IOException e) {
			handleException("Error Opening file", e);
		} catch (NamingException e) {
			handleException("Error finding database connection " + e.getExplanation(), e);
		} finally {
			try {
				if (rollback != null && !rollback.isClosed()) {
					rollback.close();
					rollback = null;
				}
				if (commit != null && !commit.isClosed()) {
					commit.close();
					commit = null;
				}
			} catch (SQLException e) {
				log("Failed to clean up/commit " + e.getMessage(), e);
				status = Status.ERROR;
			}
		}
	}
	
	private void handleException(String msg, Throwable t) {
		status = Status.ERROR;
		log(msg + " " + t.getMessage(), t instanceof SQLException ? null : t);
		if (rollback != null) {
			try {
				log("Rolling Back changes");
				rollback.rollback();
			} catch (SQLException se) {
				log("Rollback Failed " + se.getMessage(), se);
			}
		}
	}
	
	public Status getStatus() {
		status.setMessage(message);
		return status;
	}
	
}
