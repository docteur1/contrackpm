package com.sinkluge.JSON;

import java.io.Serializable;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.servlet.http.HttpSession;

import com.sinkluge.database.Database;

public class Search implements Serializable {

	private static final long serialVersionUID = 6058875088632391741L;

	public static SearchResult[] searchEmail(HttpSession session, String search) throws Exception {
		ArrayList<SearchResult> result = new ArrayList<SearchResult>();
		if (search != null && search.length() > 0) {
			String query = "select company_name, name, email from company join contacts using (company_id) where name like ? and email is not null and email != '' order by name limit 50";
			Database db = new Database();
			if (db == null) {
				db = new Database();
				session.setAttribute("db", db);
			}
			PreparedStatement ps = db.preStmt(query);
			ps.setString(1, search + "%");
			ResultSet rs = ps.executeQuery();
			SearchResult r;
			while (rs.next()) {
				r = new SearchResult();
				r.setCompanyName(rs.getString("company_name"));
				r.setEmail(rs.getString("email"));
				r.setName(rs.getString("name"));
				result.add(r);
			}
			if (rs != null) rs.close();
			rs = null;
			if (ps != null) ps.close();
			ps = null;
			db.disconnect();
		}
		return result.toArray(new SearchResult[0]);
	}
	
	public static SearchResult[] searchLetter(HttpSession session, String search) throws Exception {
		ArrayList<SearchResult> result = new ArrayList<SearchResult>();
		if (search != null && search.length() > 0) {
			String query = "select company_name, name, email, company.fax, contacts.fax, contact_id, "
				+ "company.company_id from company left join contacts using (company_id) where company_name like ? "
				+ "order by company_name, name limit 20";
			Database db = new Database();
			if (db == null) {
				db = new Database();
				session.setAttribute("db", db);
			}
			PreparedStatement ps = db.preStmt(query);
			ps.setString(1, search + "%");
			ResultSet rs = ps.executeQuery();
			SearchResult r;
			while (rs.next()) {
				r = new SearchResult();
				r.setCompanyName(rs.getString("company_name"));
				r.setEmail(rs.getString("email"));
				r.setName(rs.getString("name"));
				r.setCompanyId(rs.getInt("company_id"));
				r.setContactId(rs.getInt("contact_id"));
				if (r.getContactId() == 0) r.setFax(rs.getString("company.fax"));
				else r.setFax(rs.getString("contacts.fax"));
				result.add(r);
			}
			if (rs != null) rs.close();
			rs = null;
			if (ps != null) ps.close();
			ps = null;
			db.disconnect();
		}
		return result.toArray(new SearchResult[0]);		
	}
	
}
