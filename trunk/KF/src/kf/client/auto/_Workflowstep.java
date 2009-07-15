package kf.client.auto;

import java.util.Date;
import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Document;
import kf.client.Project;
import kf.client.User;
import kf.client.Workflow;
import kf.client.Workflowcomment;

/**
 * A generated persistent class mapped as "Workflowstep" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Workflowstep extends PersistentObject {

    public static final String CREATED_PROPERTY = "created";
    public static final String DATE_FINISHED_PROPERTY = "dateFinished";
    public static final String IS_STEP_FINISHED_PROPERTY = "isStepFinished";
    public static final String REASON_PROPERTY = "reason";
    public static final String DOCUMENT_PROPERTY = "document";
    public static final String FROM_USER_PROPERTY = "fromUser";
    public static final String PROJECTS_PROPERTY = "projects";
    public static final String TO_USER_PROPERTY = "toUser";
    public static final String WORKFLOW_PROPERTY = "workflow";
    public static final String WORKFLOWCOMMENT_PROPERTY = "workflowcomment";

    protected Date created;
    protected Date dateFinished;
    protected Boolean isStepFinished;
    protected String reason;
    protected ValueHolder document;
    protected ValueHolder fromUser;
    protected ValueHolder projects;
    protected ValueHolder toUser;
    protected ValueHolder workflow;
    protected List<Workflowcomment> workflowcomment;

    public Date getCreated() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "created", false);
        }

        return created;
    }
    public void setCreated(Date created) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "created", false);
        }

        Object oldValue = this.created;
        this.created = created;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "created", oldValue, created);
        }
    }


    public Date getDateFinished() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateFinished", false);
        }

        return dateFinished;
    }
    public void setDateFinished(Date dateFinished) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateFinished", false);
        }

        Object oldValue = this.dateFinished;
        this.dateFinished = dateFinished;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "dateFinished", oldValue, dateFinished);
        }
    }


    public Boolean getIsStepFinished() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "isStepFinished", false);
        }

        return isStepFinished;
    }
    public void setIsStepFinished(Boolean isStepFinished) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "isStepFinished", false);
        }

        Object oldValue = this.isStepFinished;
        this.isStepFinished = isStepFinished;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "isStepFinished", oldValue, isStepFinished);
        }
    }


    public String getReason() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "reason", false);
        }

        return reason;
    }
    public void setReason(String reason) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "reason", false);
        }

        Object oldValue = this.reason;
        this.reason = reason;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "reason", oldValue, reason);
        }
    }


    public Document getDocument() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "document", true);
        }

        return (Document) document.getValue();
    }
    public void setDocument(Document document) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "document", true);
        }

        this.document.setValue(document);
    }

    public User getFromUser() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fromUser", true);
        }

        return (User) fromUser.getValue();
    }
    public void setFromUser(User fromUser) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fromUser", true);
        }

        this.fromUser.setValue(fromUser);
    }

    public Project getProjects() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projects", true);
        }

        return (Project) projects.getValue();
    }
    public void setProjects(Project projects) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projects", true);
        }

        this.projects.setValue(projects);
    }

    public User getToUser() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "toUser", true);
        }

        return (User) toUser.getValue();
    }
    public void setToUser(User toUser) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "toUser", true);
        }

        this.toUser.setValue(toUser);
    }

    public Workflow getWorkflow() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflow", true);
        }

        return (Workflow) workflow.getValue();
    }
    public void setWorkflow(Workflow workflow) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflow", true);
        }

        this.workflow.setValue(workflow);
    }

    public List<Workflowcomment> getWorkflowcomment() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomment", true);
        }

        return workflowcomment;
    }
    public void addToWorkflowcomment(Workflowcomment object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomment", true);
        }

        this.workflowcomment.add(object);
    }
    public void removeFromWorkflowcomment(Workflowcomment object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomment", true);
        }

        this.workflowcomment.remove(object);
    }

}
