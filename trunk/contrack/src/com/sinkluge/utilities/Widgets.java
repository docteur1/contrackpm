package com.sinkluge.utilities;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import kf.KF;
import kf.client.Document;

import com.sinkluge.Info;
import com.sinkluge.Type;
import com.sinkluge.User;
import com.sinkluge.asterisk.Extension;
import com.sinkluge.attributes.Attributes;
import com.sinkluge.database.Database;
import com.sinkluge.security.Name;
import com.sinkluge.security.Permission;
import com.sinkluge.security.Security;

public class Widgets {
	
	public static String fontSizeStyle(HttpSession session) {
		Attributes attr = (Attributes) session.getAttribute("attr");
		return fontSizeStyle(attr);
	}
	
	public static String fontSizeStyle(Attributes attr) {
		return "<style>input,body,td,select,button,textarea{font-size:" + attr.getFontSize() + "pt;}</style>";
	}

	public static String logLinkWithId(String id, Type type, HttpServletRequest request) {
		return logLinkWithId(id, type, "window", request);
	}
	
	public static String logLinkWithId(String id, Type type, String jsWinRef, HttpServletRequest request) {
		return logLinkJS(id, type, jsWinRef, type.getCode() + id, request);
	}
	
	public static String logLink(String id, Type type, String jsWinRef, HttpServletRequest request) {
		return logLinkJS(id, type, jsWinRef, "Log", request);
	}
	
	private static String logLinkJS(String id, Type type, String jsWinRef, String text, HttpServletRequest request) {
		return "<div class=\"link\" onclick=\"" + jsWinRef + ".location='" + request.getContextPath() + "/jsp/"
		+ "utils/log.jsp?id=" + id + "&type=" + type.name() + "&loc='+escape(" + jsWinRef + ".location);\">"
		+ text + "</div>";
	}

	public static String logLinkWithId(String id, Type type, String jsWinRef, String returnUrl, 
			HttpServletRequest request) throws UnsupportedEncodingException {
		return logLinkURL(id, type, jsWinRef, returnUrl, type.getCode() + id, request);
	}
	
	public static String logLink(String id, Type type, String jsWinRef, String returnUrl, 
			HttpServletRequest request) throws UnsupportedEncodingException {
		return logLinkURL(id, type, jsWinRef, returnUrl, "Log", request);
	}
	
	private static String logLinkURL(String id, Type type, String jsWinRef, String returnUrl, 
			String text, HttpServletRequest request) throws UnsupportedEncodingException {
		return "<div class=\"link\" onclick=\"" + jsWinRef + ".location='" + request.getContextPath() + "/jsp/"
			+ "utils/log.jsp?id=" + id + "&type=" + type.name() + "&loc=" + 
			URLEncoder.encode(request.getContextPath() + "/jsp/" + returnUrl, "UTF-8") + "';\">"
			+ text + "</div>";
	}
	
	public static String eSubmit(String id, Type type, String jsWinRef, HttpServletRequest request) 
			throws Exception {
		return eSubmit(id, type, jsWinRef, null, request);
	}
	
	public static String eSubmit(String id, Type type, String jsWinRef, String className, HttpServletRequest request) 
			throws Exception {
		int contactId = ESubmit.geteSubmitContactId(Integer.parseInt(id), type);
		return "<input type=\"button\" " + (className == null ? "" : "class=\"" 
			+ className + "\" ") + "onclick=\"" + jsWinRef + ".location='" + request.getContextPath() + "/jsp/"
			+ "utils/eSubmit.jsp?id=" + id + "&type=" + type.name() + "&loc='+escape(" + jsWinRef 
			+ ".location);\" value=\"eSubmit\" " + (contactId == 0 ? "disabled" : "") + ">";
	}
	
	public static String docsButton(String id, Type type, HttpServletRequest request) throws Exception {
		return docsButton(id, type, null, request);
	}
	
	public static String docsButton(String id, Type type, String className,
			HttpServletRequest request) throws Exception {
		int count = getDocCount(id, type, request.getSession());
		return "<input type=\"button\" " + (className == null ? "" : "class=\"" 
			+ className + "\" ") + "onClick=\"" + getDocsURL(id, type, request)
			+ "\" value=\"Files"	+ (count > 0 ? "(" + count + ")" : "") + "\">";
	}
	
	private static int getDocCount(String id, Type type, HttpSession session) throws Exception {
		int count = 0;
		Database db = new Database();
		ResultSet rs = db.dbQuery("select count(*) from files where id = " + id + " and type = '"
				+ type.getCode() + "'");
		if (rs.first()) count = rs.getInt(1);
		rs.getStatement().close();
		rs = null;
		db.disconnect();
		KF kf = KF.getKF(session);
		if (kf != null) {
			List<Document> docs = kf.getProjectDocuments(type.getCode() + id);
			if (docs != null) count += docs.size();
			docs.clear();
		}
		return count;
	}
	
	private static String getDocsURL(String id, Type type, HttpServletRequest request) {
		return "var msgWin=window.open('" + request.getContextPath()
			+ "/jsp/utils/upload.jsp?id=" + id + "&type=" + type.name() + "','docs',"
			+ "'directories=no,height=500,width=700,left=25,location=no,menubar=no,top=25,resizable=yes,"
			+ "status=no,scrollbars=yes');msgWin.focus();";
	}
	
	public static String docsLink(String id, Type type, 
			HttpServletRequest request) throws Exception {
		int count = getDocCount(id, type, request.getSession());
		return "<div class=\"link\" onclick=\"" + getDocsURL(id, type, request) + "\">Files" +
			(count > 0 ? "(" + count + ")" : "") + "</div>";
	}
	
	public static String accImagesButton(String id, HttpServletRequest request) 
	throws Exception {
		HttpSession session = request.getSession();
		Info in = (Info) session.getServletContext().getAttribute("in");
		if (in.hasKF) {
			Security sec = (Security) session.getAttribute("sec");
			KF kf = KF.getKF(session);
			List<Document> docs = kf.getAccountDocuments(id, sec.ok(Name.ACCOUNTING, Permission.READ));
			if (docs != null && docs.size() > 0) {
				String out = "<input type=\"button\" onClick=\"var msgWin = window.open('" 
					+ request.getContextPath()
					+ "/jsp/utils/print.jsp?doc=imageAcc.pdf?id=" + docs.get(0).getDocumentID() + "&add=" + id + "' ,'docs');"
					+ "msgWin.focus();\" value=\"Img(" + docs.size() + ")\" />";
				return out;
			}
			else return "";
		} else return "";
	}
	
	public static String accImagesLink(String id, HttpServletRequest request)
		throws Exception {
		HttpSession session = request.getSession();
		Info in = (Info) session.getServletContext().getAttribute("in");
		if (in.hasKF) {
			Security sec = (Security) session.getAttribute("sec");
			KF kf = KF.getKF(session);
			List<Document> docs = kf.getAccountDocuments(id, sec.ok(Name.ACCOUNTING, Permission.READ));
			if (docs != null && docs.size() > 0) {
				String out = "<a href=\"javascript:var msgWin=window.open('" 
					+ request.getContextPath()
					+ "/jsp/utils/print.jsp?doc=imageAcc.pdf?id=" + docs.get(0).getDocumentID() + "&add=" + id + "' ,'docs');"
					+ "msgWin.focus();\">Images(" + docs.size() + ")</a>";
				return out;
			}
			else return "";
		} else return "";
	}
	
	public static String checkmark(boolean val, HttpServletRequest request) {
		if (val) return "<img src=\"" + request.getContextPath() + "/jsp/images/checkmark.gif\">";
		else return "&nbsp;";
	}
	
	public static String userList(int id, String name) throws Exception {
		return userList(id, name, null);
	}
	
	public static String userList(int id, String name, String add) throws Exception {
		String out = "<select name=\"" + name + "\"" + (add != null ? " " + add : "") + ">";
		List<User> users = User.getUserList(id);
		User user;
		for (Iterator<User> i = users.iterator(); i.hasNext(); ) {
			user = i.next();
			out += "<option value=\"" + user.getId() + "\" " + (user.isFlagged() ? "selected" : "");
			out += ">" + user.getListName() + "</option>";
		}
		users.clear();
		user = null;
		out += "</select>";
		return out;
	}
	
	public static String list(String id, String val, Database db) throws Exception {
		return list(id, val, id, db);
	}
	
	public static String list(String id, String val, String name, Database db) throws Exception {
		String sql = "select * from lists where id = '" + id + "' order by val";
		ResultSet rs = db.dbQuery(sql);
		String out = "<select name=\"" + name + "\">";
		while (rs.next()) out += "<option " + FormHelper.sel(val, rs.getString("val")) + ">" +
			rs.getString("val") + "</option>";
		rs.getStatement().close();
		rs = null;
		out += "</select>";
		return out;
	}
	
	public static String map(String address, String city, String state, String zip) 
			throws UnsupportedEncodingException {
		String map = "";
		if (address != null && !address.equals("")) map = address + ", ";
		map += city + ", " + state + ", " + zip;
		map = "http://maps.google.com/maps?q=" + URLEncoder.encode(map, "UTF-8");
		if (city == null || city.equals("")) map = "Address:";
		else map = "<a href=\"" + map + "\" target=\"_blank\">Address:</a>";
		return map;
	}
	
	public static String phone(String number, String clid, HttpServletRequest request) 
			throws UnsupportedEncodingException {
		return phone (number, null, clid, request);
	}
	
	public static String phone(String number, String label, String clid, HttpServletRequest request) 
			throws UnsupportedEncodingException {
		Info in = (Info) request.getSession().getServletContext().getAttribute("in");
		if (in.hasAsterisk && !Verify.blank(number)) {
			return "<div class=\"link\" onclick=\"openInlineWindow('"
				+ request.getContextPath() + "/jsp/utils/phone.jsp?phone="
				+ URLEncoder.encode(number, "UTF-8") + (clid != null ?"&clid="
				+ URLEncoder.encode(clid, "UTF-8") : "") + "', 50, 50);\">" + (label == null ?
				number : label) + "</div>";
		} else if (label != null) return label;
		else return "&nbsp;";
	}
	
	public static String extList(String channel, String name, String id, Info in)
			throws InterruptedException {
		String list = "";
		if (in.hasAsterisk) {
			int count = 0;
			while (!in.asteriskEndpointsReady && count < 5) {
				Thread.sleep(1000);
				count ++;
			}
			if (in.asterisk_endpoints.size() > 0) {
				List<Extension> exts = new ArrayList<Extension>(in.asterisk_endpoints.size());
				// grab a copy due to updates
				exts.addAll(in.asterisk_endpoints);
				list += "<select name=\"" + name + "\" id=\"" + id + "\">";
				for (Extension e : exts) {
					list +="<option value=\"" + e.getChannel() + "\" "
						+ FormHelper.sel(channel, e.getChannel()) + ">" + e.getExt()
						+ (e.getUser() != null ? " " + e.getUser() : "")
						+ "</option>";
				}
				list += "</select>";
				exts.clear();
				exts = null;
			}
		}
		return list;
	}
}
