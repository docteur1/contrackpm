package com.sinkluge.reports;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import org.apache.commons.io.output.ByteArrayOutputStream;

import com.lowagie.text.pdf.RandomAccessFileOrArray;

public class RandomAccessArray extends RandomAccessFileOrArray {

	public RandomAccessArray(String arg0) throws IOException {
		super(arg0);
	}

	public RandomAccessArray(URL arg0) throws IOException {
		super(arg0);
	}

	public RandomAccessArray(InputStream arg0) throws IOException {
		super(arg0);
	}

	public RandomAccessArray(byte[] arg0) {
		super(arg0);
	}

	public RandomAccessArray(RandomAccessFileOrArray arg0) {
		super(arg0);
	}

	public RandomAccessArray(String arg0, boolean arg1, boolean arg2)
			throws IOException {
		super(arg0, arg1, arg2);
	}
	
	public RandomAccessArray(ByteArrayOutputStream os) {
		super(os.toByteArray());
	}

}
