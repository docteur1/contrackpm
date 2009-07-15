package com.sinkluge.reports;

import com.lowagie.text.Cell;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Font;
import com.lowagie.text.Element;
import com.lowagie.text.Rectangle;

import java.awt.Color;
import java.text.DecimalFormat;
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
	
	public static String numberToText(double num){
		String pretty = "";
		String cents="";
		if (num>999999){
			pretty = threeDigits((int)(num/1000000));
			pretty += " million";
		}
		if (num%1000000>999){
			pretty += threeDigits((int)(num%1000000)/1000);
			pretty += " thousand";
		}
		pretty += threeDigits((int)(num%1000));
		pretty += " dollars";
		if (num%1!=0){
			cents = Double.toString(num);
			cents = cents.substring(cents.indexOf(".") + 1);
			if (cents.length() < 2) cents += "0";
			pretty += " and" + threeDigits((int)Long.parseLong(cents)) + " cents";
		}
		//pretty += " (" + df.format(num) + ")";
		return pretty.substring(1).toUpperCase();
	}
	
	public static String numberAndText(double num){
		DecimalFormat df = new DecimalFormat("$#,##0.00");
		return df.format(num) + " (" + numberToText(num) + ")";
	}
	
	private static String threeDigits(int num){
		String pushback="";
		if (num>99){
			switch((int)(num/100)){
			case 1: pushback +=" one"; break;
			case 2: pushback +=" two"; break;
			case 3: pushback +=" three"; break;
			case 4: pushback +=" four"; break;
			case 5: pushback +=" five"; break;
			case 6: pushback +=" six"; break;
			case 7: pushback +=" seven"; break;
			case 8: pushback +=" eight"; break;
			case 9: pushback +=" nine"; break;
			}
			pushback += " hundred";
		}
		if (num%100>19 || num%100<10){
			switch((int)(num%100)/10){
				case 2: pushback += " twenty"; break;
				case 3: pushback += " thirty"; break;
				case 4: pushback += " forty"; break;
				case 5: pushback += " fifty"; break;
				case 6: pushback += " sixty"; break;
				case 7: pushback += " seventy"; break;
				case 8: pushback += " eighty"; break;
				case 9: pushback += " ninety"; break;
			}
			switch((int) num%10){
				case 1: pushback += " one"; break;
				case 2: pushback += " two"; break;
				case 3: pushback += " three"; break;
				case 4: pushback += " four"; break;
				case 5: pushback += " five"; break;
				case 6: pushback += " six"; break;
				case 7: pushback += " seven"; break;
				case 8: pushback += " eight"; break;
				case 9: pushback += " nine"; break;
			}
		}//end if
		else{
			switch(num%100){
				case 10: pushback += " ten"; break;
				case 11: pushback += " eleven"; break;
				case 12: pushback += " twelve"; break;
				case 13: pushback += " thirteen"; break;
				case 14: pushback += " fourteen"; break;
				case 15: pushback += " fifteen"; break;
				case 16: pushback += " sixteen"; break;
				case 17: pushback += " seventeen"; break;
				case 18: pushback += " eighteen"; break;
				case 19: pushback += " nineteen"; break;
			}
		}
		return pushback;
	}
}