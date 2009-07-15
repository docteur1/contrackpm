package com.sinkluge.reports;

import com.lowagie.text.Cell;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Font;
import com.lowagie.text.Element;
import com.lowagie.text.Rectangle;

import java.awt.Color;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DocHelper {

	public static void center (PdfPCell c) {
		c.setHorizontalAlignment(Element.ALIGN_CENTER);
	}

	public static void left (PdfPCell c) {
		c.setHorizontalAlignment(Element.ALIGN_LEFT);
	}

	public static void right (PdfPCell c) {
		c.setHorizontalAlignment(Element.ALIGN_RIGHT);
	}

	public static void justify (PdfPCell c) {
		c.setHorizontalAlignment(Element.ALIGN_JUSTIFIED);
	}

	public static void top (PdfPCell c) {
		c.setVerticalAlignment(Element.ALIGN_TOP);
	}

	public static void middle (PdfPCell c) {
		c.setVerticalAlignment(Element.ALIGN_MIDDLE);
	}

	public static void bottom (PdfPCell c) {
		c.setVerticalAlignment(Element.ALIGN_BOTTOM);
	}

	public static void center (Cell c) {
		c.setHorizontalAlignment(Element.ALIGN_CENTER);
	}

	public static void left (Cell c) {
		c.setHorizontalAlignment(Element.ALIGN_LEFT);
	}

	public static void right (Cell c) {
		c.setHorizontalAlignment(Element.ALIGN_RIGHT);
	}

	public static void justify (Cell c) {
		c.setHorizontalAlignment(Element.ALIGN_JUSTIFIED);
	}

	public static void top (Cell c) {
		c.setVerticalAlignment(Element.ALIGN_TOP);
	}

	public static void middle (Cell c) {
		c.setVerticalAlignment(Element.ALIGN_MIDDLE);
	}

	public static void bottom (Cell c) {
		c.setVerticalAlignment(Element.ALIGN_BOTTOM);
	}

	public static Font font(float size, int style) {
		Font f = null;
		if (style != 0) f = new Font(Font.TIMES_ROMAN, size, style);
		else f = new Font(Font.TIMES_ROMAN, size);
		return f;
	}

	public static Font font (float size) {
		return font (size, 0);
	}

	public static void gray (Cell c) {
		c.setBackgroundColor(new Color(191, 191, 191));
	}

	public static void bTop (Cell c) {
		c.setBorder(Rectangle.TOP);
	}

	public static void bBottom (Cell c) {
		c.setBorder(Rectangle.BOTTOM);
	}

	public static void gray (PdfPCell c) {
		c.setBackgroundColor(new Color(191, 191, 191));
	}

	public static void bTop (PdfPCell c) {
		c.setBorder(Rectangle.TOP);
	}

	public static void bBottom (PdfPCell c) {
		c.setBorder(Rectangle.BOTTOM);
	}
	
	public static String date(Date d) {
		if (d == null) return "";
		else {
			SimpleDateFormat sdf = new SimpleDateFormat("d MMM yy");
			return sdf.format(d);
		}
	}
	
	public static String longDate(Date d) {
		if (d == null) return "";
		else {
			SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
			return sdf.format(d);
		}
	}
	
	public static String string(String d) {
		if (d == null) return "";
		else return d;
	}
}