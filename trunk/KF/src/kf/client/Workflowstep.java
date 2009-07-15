package kf.client;

import kf.client.auto._Workflowstep;

/**
 * A persistent class mapped as "Workflowstep" Cayenne entity.
 */
public class Workflowstep extends _Workflowstep {

	public Long getStepID() {
		return (getObjectId() != null && !getObjectId().isTemporary()) 
        ? (Long) getObjectId().getIdSnapshot().get("StepID") 
        : null;
	}
	
}
