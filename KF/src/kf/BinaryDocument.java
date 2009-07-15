package kf;

import org.apache.commons.io.output.ByteArrayOutputStream;

public class BinaryDocument {

	protected ByteArrayOutputStream baos;
	protected String contentType;
	public ByteArrayOutputStream getStream() {
		return baos;
	}
	public String getContentType() {
		return contentType;
	}
	
}
