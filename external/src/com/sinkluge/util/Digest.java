package com.sinkluge.util;

import java.security.MessageDigest;

public class Digest {

	public Digest () {}

	private static String convert(byte bytes[]) {

		StringBuffer sb = new StringBuffer(bytes.length * 2);
		for (int i = 0; i < bytes.length; i++) {
			sb.append(convertDigit((int) (bytes[i] >> 4)));
			sb.append(convertDigit((int) (bytes[i] & 0x0f)));
		}
		return (sb.toString());
	}

    private static char convertDigit(int value) {

        value &= 0x0f;
        if (value >= 10)
            return ((char) (value - 10 + 'a'));
        else
            return ((char) (value + '0'));

    }

    public final static String digest(String credentials) throws Exception {

        //try {
            // Obtain a new message digest with "digest" encryption
            MessageDigest md = (MessageDigest) MessageDigest.getInstance("MD5").clone();
            // encode the credentials
            md.update(credentials.getBytes());
            // Digest the credentials and return as hexadecimal
            return (convert(md.digest()));
        //} catch(Exception ex) {
        //    ex.printStackTrace();
        //    return credentials;
        //}

    }



}