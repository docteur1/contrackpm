package kf.client.auto;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Project;

/**
 * A generated persistent class mapped as "Workflowreason" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Workflowreason extends PersistentObject {

    public static final String REASON_PROPERTY = "reason";
    public static final String REASON_ID_PROPERTY = "reasonID";
    public static final String SHOW_ON_WORKFLOW_PROPERTY = "showOnWorkflow";
    public static final String TYPE_PROPERTY = "type";
    public static final String PROJECT_PROPERTY = "project";

    protected String reason;
    protected Long reasonID;
    protected Boolean showOnWorkflow;
    protected String type;
    protected ValueHolder project;

    public String getReason() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "reason", false);
        }

        return reason;
    }


    public Long getReasonID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "reasonID", false);
        }

        return reasonID;
    }


    public Boolean getShowOnWorkflow() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "showOnWorkflow", false);
        }

        return showOnWorkflow;
    }


    public String getType() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "type", false);
        }

        return type;
    }


    public Project getProject() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "project", true);
        }

        return (Project) project.getValue();
    }

}
