package kf.client.auto;

import java.util.Date;
import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Document;
import kf.client.Project;
import kf.client.Workflowcomment;
import kf.client.Workflowstep;

/**
 * A generated persistent class mapped as "Workflow" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Workflow extends PersistentObject {

    public static final String CREATED_PROPERTY = "created";
    public static final String DATE_COMPLETED_PROPERTY = "dateCompleted";
    public static final String IS_FINISHED_PROPERTY = "isFinished";
    public static final String DOCUMENT_PROPERTY = "document";
    public static final String PROJECT_PROPERTY = "project";
    public static final String WORKFLOWCOMMENTS_PROPERTY = "workflowcomments";
    public static final String WORKFLOWSTEPS_PROPERTY = "workflowsteps";

    protected Date created;
    protected Date dateCompleted;
    protected Boolean isFinished;
    protected ValueHolder document;
    protected ValueHolder project;
    protected List<Workflowcomment> workflowcomments;
    protected List<Workflowstep> workflowsteps;

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


    public Date getDateCompleted() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateCompleted", false);
        }

        return dateCompleted;
    }
    public void setDateCompleted(Date dateCompleted) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateCompleted", false);
        }

        Object oldValue = this.dateCompleted;
        this.dateCompleted = dateCompleted;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "dateCompleted", oldValue, dateCompleted);
        }
    }


    public Boolean getIsFinished() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "isFinished", false);
        }

        return isFinished;
    }
    public void setIsFinished(Boolean isFinished) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "isFinished", false);
        }

        Object oldValue = this.isFinished;
        this.isFinished = isFinished;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "isFinished", oldValue, isFinished);
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

    public Project getProject() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "project", true);
        }

        return (Project) project.getValue();
    }
    public void setProject(Project project) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "project", true);
        }

        this.project.setValue(project);
    }

    public List<Workflowcomment> getWorkflowcomments() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomments", true);
        }

        return workflowcomments;
    }
    public void addToWorkflowcomments(Workflowcomment object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomments", true);
        }

        this.workflowcomments.add(object);
    }
    public void removeFromWorkflowcomments(Workflowcomment object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomments", true);
        }

        this.workflowcomments.remove(object);
    }

    public List<Workflowstep> getWorkflowsteps() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowsteps", true);
        }

        return workflowsteps;
    }
    public void addToWorkflowsteps(Workflowstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowsteps", true);
        }

        this.workflowsteps.add(object);
    }
    public void removeFromWorkflowsteps(Workflowstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowsteps", true);
        }

        this.workflowsteps.remove(object);
    }

}
