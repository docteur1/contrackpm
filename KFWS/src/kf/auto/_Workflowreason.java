package kf.auto;

import org.apache.cayenne.CayenneDataObject;

import kf.Project;

/**
 * Class _Workflowreason was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Workflowreason extends CayenneDataObject {

    public static final String REASON_PROPERTY = "reason";
    public static final String REASON_ID_PROPERTY = "reasonID";
    public static final String SHOW_ON_WORKFLOW_PROPERTY = "showOnWorkflow";
    public static final String TYPE_PROPERTY = "type";
    public static final String PROJECT_PROPERTY = "project";

    public static final String REASON_ID_PK_COLUMN = "ReasonID";

    public String getReason() {
        return (String)readProperty("reason");
    }

    public Long getReasonID() {
        return (Long)readProperty("reasonID");
    }

    public Boolean getShowOnWorkflow() {
        return (Boolean)readProperty("showOnWorkflow");
    }

    public String getType() {
        return (String)readProperty("type");
    }


    public Project getProject() {
        return (Project)readProperty("project");
    }


}