package com.sinkluge.JSON;

import java.sql.ResultSet;

import javax.servlet.http.HttpSession;

import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;

public class List {

	public static ListItem[] getCodesAndContracts(HttpSession session) throws Exception {
		Database db = new Database();
		Attributes attr = (Attributes) session.getAttribute("attr");
		ListItem[] list = null;
		ResultSet rs = db.dbQuery("select contract_id, cost_code_id, division, cost_code, phase_code, "
			+ "code_description, company_name from job_cost_detail as jcd left join contracts "
			+ "using(cost_code_id) left join company using(company_id) where jcd.job_id = " 
			+ attr.getJobId() + " order by costorder(division), costorder(cost_code), "
			+ "costorder(phase_code)");
		if (rs.last()) {
			list = new ListItem[rs.getRow()];
			rs.beforeFirst();
			ListItem item;
			String temp;
			for (int i = 0; rs.next(); i++) {
				item = new ListItem();
				temp = rs.getString("code_description") != null ? rs.getString("code_description") : "Unknown";
				if (rs.getInt("contract_id") != 0) item.setId(rs.getString("cost_code_id") + "n" +
						rs.getString("contract_id"));
				else item.setId(rs.getString("cost_code_id"));
				item.setText(rs.getString("division") + " " + rs.getString("cost_code")
					+ " " + rs.getString("phase_code") + " " + temp.replaceAll("'","")
					+ (rs.getInt("contract_id") == 0 ? "" : ": " + rs.getString("company_name").replaceAll("'","")));
				list[i] = item;
			}
		}
		rs.getStatement().close();
		db.disconnect();
		return list;
	}
	
}
