package kf.client.auto;

import java.util.Date;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Document;
import kf.client.Project;
import kf.client.User;
import kf.client.Workflow;
import kf.client.Workflowstep;

/**
 * A generated persistent class mapped as "Workflowcomment" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Workflowcomment extends PersistentObject {

    public static final String COMMENT_PROPERTY = "comment";
    public static final String DATE_PROPERTY = "date";
    public static final String DOCUMENT_PROPERTY = "document";
    public static final String PROJECT_PROPERTY = "project";
    public static final String USER_PROPERTY = "user";
    public static final String WORKFLOW_PROPERTY = "workflow";
    public static final String WORKFLOWSTEP_PROPERTY = "workflowstep";

    protected String comment;
    protected Date date;
    protected ValueHolder document;
    protected ValueHolder project;
    protected ValueHolder user;
    protected ValueHolder workflow;
    protected ValueHolder workflowstep;

    public String getComment() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "comment", false);
        }

        return comment;
    }
    public void setComment(String comment) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "comment", false);
        }

        Object oldValue = this.comment;
        this.comment = comment;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "comment", oldValue, comment);
        }
    }


    public Date getDate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "date", false);
        }

        return date;
    }
    public void setDate(Date date) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "date", false);
        }

        Object oldValue = this.date;
        this.date = date;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "date", oldValue, date);
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

    public User getUser() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "user", true);
        }

        return (User) user.getValue();
    }
    public void setUser(User user) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "user", true);
        }

        this.user.setValue(user);
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

    public Workflowstep getWorkflowstep() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowstep", true);
        }

        return (Workflowstep) workflowstep.getValue();
    }
    public void setWorkflowstep(Workflowstep workflowstep) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowstep", true);
        }

        this.workflowstep.setValue(workflowstep);
    }

}
