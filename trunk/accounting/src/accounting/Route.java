package accounting;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class Route implements java.io.Serializable {

	private static final long serialVersionUID = 1L;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	private String id;
	private String voucherId;
	private int status;
	
	public String getCurNotes() {
		return curNotes;
	}

	public void setCurNotes(String curNotes) {
		this.curNotes = curNotes;
	}
	
	public void addNote(String note, String user) {
		Note n = new Note(note, user);
		allNotes.add(n);
	}
	
	public Iterator<Note> getNotes() {
		return allNotes.iterator();
	}

	public void setVoucherId(String voucherId) {
		this.voucherId = voucherId;
	}

	public String getVoucherId() {
		return voucherId;
	}

	private String curNotes;
	private List<Note> allNotes = new ArrayList<Note>();
	
	public final static int STATUS_APPROVE = 1;
	public final static int STATUS_PENDING = 2;
	public final static int STATUS_REJECT = 3;
	
	public class Note implements java.io.Serializable {
		private static final long serialVersionUID = 1L;
		private String note;
		public String getUser() {
			return user;
		}
		public void setUser(String user) {
			this.user = user;
		}
		public String getNote() {
			return note;
		}
		public void setNote(String note) {
			this.note = note;
		}
		private String user;
		public Note(String note, String user) {
			this.note = note;
			this.user = user;
		}
	}
	
}
