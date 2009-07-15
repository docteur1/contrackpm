package com.sinkluge.utilities;

import java.awt.image.BufferedImage;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

import javax.imageio.ImageIO;

import org.apache.log4j.Logger;

public class ImageUtils {
	
	public static void genJPEGThumb(InputStream in, OutputStream out, int x, int y) 
			throws IOException {
		genThumb(in, out, x, y, "jpeg");
	}
		
	public static void genThumb(InputStream in, OutputStream out, int x, int y, String type) 
			throws IOException {
		Logger log = Logger.getLogger(ImageUtils.class);
		BufferedImage source = ImageIO.read(in);
		in.close();
		float sx = source.getWidth();
		float sy = source.getHeight();
		// We have to scale more in the x direction than the y
		float rx = sx/x;
		float ry = sy/y;
		if(log.isDebugEnabled()) log.debug("Ratios " + Float.toString(rx) + "x" + Float.toString(ry));
		if (x > sx && y > sy) {
			x = source.getWidth();
			y = source.getHeight();
		} else {
			if (rx > ry) y = Math.round(sy/rx);
			else if (rx < ry) x = Math.round(sx/ry);
		}
		if(log.isDebugEnabled()) log.debug("Returning image with " + x + "x" + y + " orginally " 
			+ sx + "x" + sy + ".");
		BufferedImage image = new BufferedImage(x, y, BufferedImage.TYPE_INT_RGB);
		image.createGraphics().drawImage(source, 0, 0, x, y, null);
		ImageIO.write(image, type, out);
	}
	
}
