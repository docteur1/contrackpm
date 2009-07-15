package com.sinkluge;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.apache.log4j.Logger;

public class CEDatabase {

	private Connection con = null;
	private Logger log = Logger.getLogger(CEDatabase.class);
	
	public CEDatabase() throws SQLException {
		connect();
	}
	
	private void connect() throws SQLException {
		if(con == null) {
			try {
				Context initContext = new InitialContext();
				Context envContext  = (Context) initContext.lookup("java:/comp/env");
				DataSource ds = (DataSource) envContext.lookup("odbc/ce");
				con = ds.getConnection();
			} catch (NamingException e) {
				log.error("Could not get connection", e);
				throw new SQLException ("Could not get connection: " + e.getMessage());
			}
		}
	}
	
	public ResultSet dbQuery(String sql) throws SQLException {
		return dbQuery(sql, false);
	}
	
	public ResultSet dbQuery(String sql, boolean updateable) throws SQLException {
		ResultSet rs=null;
		Statement stmt;
		connect();
		if (updateable) stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
		else stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
		if (log.isDebugEnabled()) log.debug("Performing (dbQuery): " + sql);
		rs = stmt.executeQuery(sql);
		if (log.isDebugEnabled()) {
			rs.last();
			log.debug("Found: " + rs.getRow() + " rows");
			rs.beforeFirst();
		}
		return rs;
	}

	public int dbInsert(String sql) throws SQLException {
		int flags = 0;
		connect();
		Statement stmt = con.createStatement();
		if (log.isDebugEnabled()) log.debug("Performing (dbInsert): " + sql);
		flags = stmt.executeUpdate(sql);
		stmt.close();
		return flags;
	}

	public PreparedStatement preStmt(String sql) throws SQLException {
		PreparedStatement ps = null;
		connect();
		if (log.isDebugEnabled()) log.debug("Performing (preStmt): " + sql);
		ps = con.prepareStatement(sql);
		return ps;
	}

	public void disconnect() throws SQLException {
		if (con != null) {
			log.debug("Closing database connection");
			con.close();
		} else log.debug("Database already closed");
		con = null;
	}
	
	
}
