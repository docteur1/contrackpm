package com.sinkluge;

public abstract class Group implements Runnable {

	public static Group getInstance(Info in) throws ClassNotFoundException, InstantiationException, 
			IllegalAccessException {
		return getInstance(in, in.default_group);
	}
	
	public static Group getInstance(Info in, String groupName) 
			throws ClassNotFoundException, InstantiationException, IllegalAccessException {
		UserData user = (UserData) Class.forName(in.user_class).newInstance();
		return user.getGroupInstance(in, groupName);
	}
	
}
