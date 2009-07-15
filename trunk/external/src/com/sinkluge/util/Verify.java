package com.sinkluge.util;

// Classes we will need
import java.util.regex.*;

public class Verify {

	public String message;



	public Verify () {
		message = "";
	}

	public boolean blank(String s) {
		if (s ==null || s.equals("")) return true;
		else if (s.matches("^\\s+$")) return true;
		else return false;
	}

	public boolean zip(String s) {
		 return s.matches("^\\d{5}([-]\\d{4})?$");
	}

	public boolean phone(String s) {
		if (s.matches("^\\(\\d{3}\\) \\d{3}[-]\\d{4}?") || blank(s)) return true;
		else return false;
	}

	public boolean email(String s) {
		if (s.matches("^[\\w-]+(\\.([\\w-]+))*@[\\w-]+(\\.([\\w-]+))*\\.[a-z]+$")) return true;
		else return false;
	}

	public boolean date(String s) {
		boolean valid = true;
		if (s.matches("^\\d{2}/\\d{2}/\\d{4}$")) {
			try {
				int year = Integer.parseInt(s.substring(6));
				int month = Integer.parseInt(s.substring(0,2));
				int day = Integer.parseInt(s.substring(3,5));
				if (day > 31 || month < 1 || month > 12) valid = false;
				else if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) valid = false;
				else if (month == 2) {
					if (year % 4 == 0 && day > 29) valid = false;
					else if (day > 28) valid = false;
				}
			} catch (Exception e) {
				valid = false;
			}
		} else valid = false;
		return valid;
	}

	public boolean integer(String s) {
		try {
			if (blank(s)) s = "0";
			s = s.replaceAll(",","");
			Integer.parseInt(s);
			return true;
		} catch (NumberFormatException e) {
			return false;
		}
	}

	public boolean cur(String s) {
		try {
			if (blank(s)) s = "0";
			s = s.replaceAll(",","");
			Float.parseFloat(s);
			return true;
		} catch (NumberFormatException e) {
			return false;
		}
	}

	public void msg(String append) {
		if (!blank(message)) message += ", ";
		message += append;
	}

	public boolean password (String s, String s2) {
		if (!blank(s)) {
			if (s2 == null) s2 = "";
			if (!s.equals(s2)){
				msg("Passwords do not match");
				return false;
			} else if (s.length() < 6) {
				msg("Passwords must contain at least 6 characters");
				return false;
			} else {
				Matcher a = Pattern.compile("[a-zA-Z]").matcher(s);
				Matcher ns = Pattern.compile("[\\d\\W]").matcher(s);
				if (!a.find() || !ns.find()) {
					msg("Passwords must contain at least one letter and one number or symbol");
					return false;
				}
			}
		}
		return true;
	}
}