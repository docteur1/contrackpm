package accounting;

public enum Action implements java.io.Serializable {
	BLOCKED("Action blocked"),
	CREATED("Created"),
	DELETED("Deleted"),
	NO_ACTION("No updates made"),
	NO_CODE("No code found, no action taken"),
	NOT_FOUND("Item not found"),
	NO_JOB("Project not found"),
	NO_SUBCONTRACT("Subcontract not found"),
	NO_COMPANY("Company not found"),
	UPDATED("Updated");
	
	private final String message;
	private Action(String message) {
		this.message = message;
	}
	public String getMessage() {
		return message;
	}
}
