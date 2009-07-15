package accounting;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class Result implements Serializable {

	private static final long serialVersionUID = 1L;
	private final Action action;
	private final String message;
	private final Map<String, String> map = new HashMap<String, String>(); 
	
	public Result(Action action, String message){
		this.action = action;
		this.message = message;
	}
	public Result(Action action) {
		this.action = action;
		this.message = null;
	}
	public Action getAction() {
		return action;
	}
	public String getMessage () {
		if (message == null && action != null) return action.getMessage();
		else if (message != null) return message;
		else return null;
	}
	public void setId(String key, String value) {
		map.put(key, value);
	}
	public String getId(String key) {
		return map.get(key);
	}
	
}
