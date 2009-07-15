package com.sinkluge.database;

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

public class Database {

	private static final long serialVersionUID = 1L;

	private Logger log = Logger.getLogger(Database.class);
	
	protected Connection con = null;
	
	public void disconnect() throws SQLException {
		if (con != null && !con.isClosed()) {
			con.close();
			con = null;
		}
	}
	
	@Deprecated
	public void disconnectFinal() {
		try {
			disconnect();
		} catch (SQLException e) {
			log.warn("disconnectFinal(): cannot close connection", e);
		}
	}

	public void connect() throws SQLException {
		if(con == null || con.isClosed()) {
			try {
				Context initContext = new InitialContext();
				Context envContext  = (Context) initContext.lookup("java:/comp/env");
				DataSource ds = (DataSource) envContext.lookup("jdbc/contrack");
				con = ds.getConnection();
			} catch (NamingException e) {
				log.error("connect(): error getting connection from pool", e);
				throw new SQLException("Error getting connection for pool " + e.getMessage());
			}
		}
	}
	
	public ResultSet dbQuery(String sql) throws SQLException {
		return dbQuery(sql, false);
	}
	
	public ResultSet dbQuery(String sql, boolean updateable) throws SQLException {
		ResultSet rs=null;
		connect();
		Statement stmt;
		if (updateable) stmt = con.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		else stmt = con.createStatement();
		rs = stmt.executeQuery(sql);
		return rs;
	}

	public int dbInsert(String sql) throws SQLException {
		int flags = 0;
		connect();
		Statement stmt = con.createStatement();
		flags = stmt.executeUpdate(sql);
		stmt.close();
		return flags;
	}

	public PreparedStatement preStmt(String sql) throws SQLException {
		PreparedStatement ps = null;
		connect();
		ps = con.prepareStatement(sql);
		return ps;
	}

}
