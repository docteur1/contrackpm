package com.sinkluge.utilities;

// Classes we will need
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Verify {

	public String message;

	public Verify () {
		message = "";
	}

	public static boolean blank(String s) {
		if (s ==null || s.equals("")) return true;
		else if (s.matches("^\\s+$")) return true;
		else return false;
	}

	public static boolean zip(String s) {
		 return s.matches("^\\d{5}([-]\\d{4})?$");
	}
	
	public static boolean phone(String s) {
		if (s != null && (
			s.matches("^(1-)?\\d{3}[-]\\d{3}[-]\\d{4}$") ||
			s.matches("^(1\\s)?\\(\\d{3}\\)\\s\\d{3}[-]\\d{4}$"))) return true;
		else return false;
	}

	public static boolean email(String s) {
		if (s != null && s.matches("^[\\w-]+(\\.([\\w-]+))*@[\\w-]+(\\.([\\w-]+))*\\.[a-z]+$")) return true;
		else return false;
	}

	public static boolean date(String s) {
		if (s == null) return true;
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

	public static boolean integer(String s) {
		try {
			if (blank(s)) s = "0";
			Integer.parseInt(s);
			return true;
		} catch (NumberFormatException e) {
			return false;
		}
	}

	public static boolean cur(String s) {
		try {
			if (blank(s)) s = "0";
			Double.parseDouble(s);
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
			if (s2 != null && !s.equals(s2)){
				msg("Passwords do not match");
				return false;
			} else if (s.length() < 6) {
				msg("Passwords must contain 6 characters");
				return false;
			} else {
				Matcher a = Pattern.compile("[a-zA-Z]").matcher(s);
				Matcher ns = Pattern.compile("[\\d\\W]").matcher(s);
				if (!a.find() || !ns.find()) {
					msg("Passwords must contain at least one letter and one number or symbol");
					return false;
				}
			}
		} else {
			msg("Password cannot be empty");
			return false;
		}
		return true;
	}
}