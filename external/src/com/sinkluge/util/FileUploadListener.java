package com.sinkluge.util;

import org.apache.commons.fileupload.ProgressListener;

public class FileUploadListener implements ProgressListener {
	
   private volatile long
   	  kBytesReadX10 = 0L,
      bytesRead = 0L,
      contentLength = 0L,
      item = 0L;

	public FileUploadListener() {
      super();
   }

   public void update(long aBytesRead, long aContentLength, int anItem) {
	  long kBytesX10 = aBytesRead / 100;
	  if (aBytesRead != aContentLength) {
		  if (kBytesX10 == kBytesReadX10) return;
		  kBytesReadX10 = kBytesX10;
	      bytesRead = aBytesRead;
	      contentLength = aContentLength;
	      item = anItem;
	  } else {
		  // We're done...
		  bytesRead = contentLength;
	  }
   }

   public long getBytesRead() {
      return bytesRead;
   }

   public long getContentLength() {
      return contentLength;
   }

   public long getItem() {
      return item;
   }


}
