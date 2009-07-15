package com.sinkluge.security;

import java.util.Comparator;

public class NameComparator implements Comparator<Name> {

	public int compare(Name arg0, Name arg1) {
		try {
		if (arg0.getName() != null && arg1.getName() != null) return arg0.getName().compareTo(arg1.getName());
		else if (arg0.getName() != null) return 1;
		else return -1;
		} catch (NullPointerException e) {
			System.out.println(arg0.getName() + " " + arg1.getName());
			return 0;
		}
	}

}
