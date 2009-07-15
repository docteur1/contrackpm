package accounting.ce;

import accounting.ce.client.Jcjob;

public class Overhead {
	private double[] values;
	
	protected Overhead (Jcjob job) {
		values = new double[17];
		for (int i = 1; i <= 16; i++) {
			switch (i) {
			case 1:
				values[i] = job.getOverheadpcnt1()/100; 
				break;
			case 2:
				values[i] = job.getOverheadpcnt2()/100;
				break;
			case 3:
				values[i] = job.getOverheadpcnt3()/100;
				break;
			case 4:
				values[i] = job.getOverheadpcnt4()/100;
				break;
			case 5:
				values[i] = job.getOverheadpcnt5()/100;
				break;
			case 6:
				values[i] = job.getOverheadpcnt6()/100;
				break;
			case 7:
				values[i] = job.getOverheadpcnt7()/100;
				break;
			case 8:
				values[i] = job.getOverheadpcnt8()/100;
				break;
			case 9:
				values[i] = job.getOverheadpcnt9()/100;
				break;
			case 10:
				values[i] = job.getOverheadpcnt10()/100;
				break;
			case 11:
				values[i] = job.getOverheadpcnt11()/100;
				break;
			case 12:
				values[i] = job.getOverheadpcnt12()/100;
				break;
			case 13:
				values[i] = job.getOverheadpcnt13()/100;
				break;
			case 14:
				values[i] = job.getOverheadpcnt14()/100;
				break;
			case 15:
				values[i] = job.getOverheadpcnt15()/100;
				break;
			default:
				values[i] = job.getOverheadpcnt16()/100;
				break;
			}
		}
	}
	
	protected double get(int key) {
		return values[key];
	}
	
	protected void close() {
		values = null;
	}
}
