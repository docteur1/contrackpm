
package com.sinkluge.database;

// Classes we will need
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;


public class Database {

	private Connection con;
	private final String classpath = "com.sinkluge.database.Database";
	public int contract_id = 0;
	public String msg = "";
	public int contact_id = 0;
	public int company_id = 0;
	public String contact_name = "No User";
	public String email = null;
	public int job_id = 0;
	public String job_name;
	public String company_name;
	public int font_size = 10;
	public int site_id = 1;
	private HashMap<String, String> ht = null;

	public Database() {}

	public void disconnectFinal() {
		disconnect();
	}
	
	public void load() throws SQLException {
		connect();
		ResultSet rs = dbQuery("select name, val from settings where id = 'site" + site_id + "'");
		if (ht == null) ht = new HashMap<String, String>();
		while (rs.next()) ht.put(rs.getString(1), rs.getString(2));
		if (rs != null) rs.getStatement().close();
		rs = null;
	}
	
	public String get(String key) {
		return ht.get(key);
	}
	
	public void disconnect() {
		try {
			if (con != null) con.close();
			else msg = classpath + ".disconnect(): No connection exists!";
		} catch (SQLException e) {
			e.printStackTrace();
			msg = classpath + ".disconnect() SQLException: " + e.getMessage();
		}
		con = null;
	}

	public void connect() {
		try {
			if(con == null) {
				Context initContext = new InitialContext();
				Context envContext  = (Context) initContext.lookup("java:/comp/env");
				DataSource ds = (DataSource) envContext.lookup("jdbc/sinkluge");
				con = ds.getConnection();
			}
		} catch (SQLException e) {
			msg = classpath + ".connect() SQLException: " + e.getMessage();
			msg = classpath + ".connect() SQLState: " + e.getSQLState();
		} catch (Exception e) {
			msg = classpath + ".connect() Exception: " + e.getMessage();
		}
	}

	public Statement getStatement() throws SQLException {
		if (con == null) connect();
		return con.createStatement();
	}

	public Statement getStatement(int scroll, int updatable) throws SQLException {
		return con.createStatement(scroll, updatable);
	}
	
	public ResultSet dbQuery(String query, boolean updateable) throws SQLException {
		if (con == null) connect();
		if (updateable) return getStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE).executeQuery(query);
		else return getStatement().executeQuery(query);
	}
	
	public ResultSet dbQuery(String query) throws SQLException {
		return dbQuery(query, false);
	}

	public PreparedStatement preStmt(String sql) throws SQLException {
		return con.prepareStatement(sql);
	}

}
