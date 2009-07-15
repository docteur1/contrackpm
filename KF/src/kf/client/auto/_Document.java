package kf.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Documentvalue;
import kf.client.Page;
import kf.client.Project;
import kf.client.Workflow;
import kf.client.Workflowcomment;
import kf.client.Workflowstep;

/**
 * A generated persistent class mapped as "Document" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Document extends PersistentObject {

    public static final String ARCHIVE_DATE_PROPERTY = "archiveDate";
    public static final String ARCHIVE_PATH_PROPERTY = "archivePath";
    public static final String ARCHIVE_TYPE_PROPERTY = "archiveType";
    public static final String DATE_CREATED_PROPERTY = "dateCreated";
    public static final String DOCUMENT_ID_PROPERTY = "documentID";
    public static final String DOCUMENT_NAME_PROPERTY = "documentName";
    public static final String NEEDS_UPDATE_PROPERTY = "needsUpdate";
    public static final String OWNER_ID_PROPERTY = "ownerID";
    public static final String STATUS_PROPERTY = "status";
    public static final String DOCUMENTVALUES_PROPERTY = "documentvalues";
    public static final String PAGES_PROPERTY = "pages";
    public static final String PROJECT_PROPERTY = "project";
    public static final String WORKFLOWCOMMENTS_PROPERTY = "workflowcomments";
    public static final String WORKFLOWS_PROPERTY = "workflows";
    public static final String WORKFLOWSTEPS_PROPERTY = "workflowsteps";

    protected Integer archiveDate;
    protected String archivePath;
    protected String archiveType;
    protected Integer dateCreated;
    protected Long documentID;
    protected String documentName;
    protected Boolean needsUpdate;
    protected Integer ownerID;
    protected String status;
    protected List<Documentvalue> documentvalues;
    protected List<Page> pages;
    protected ValueHolder project;
    protected List<Workflowcomment> workflowcomments;
    protected List<Workflow> workflows;
    protected List<Workflowstep> workflowsteps;

    public Integer getArchiveDate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "archiveDate", false);
        }

        return archiveDate;
    }
    public void setArchiveDate(Integer archiveDate) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "archiveDate", false);
        }

        Object oldValue = this.archiveDate;
        this.archiveDate = archiveDate;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "archiveDate", oldValue, archiveDate);
        }
    }


    public String getArchivePath() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "archivePath", false);
        }

        return archivePath;
    }
    public void setArchivePath(String archivePath) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "archivePath", false);
        }

        Object oldValue = this.archivePath;
        this.archivePath = archivePath;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "archivePath", oldValue, archivePath);
        }
    }


    public String getArchiveType() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "archiveType", false);
        }

        return archiveType;
    }
    public void setArchiveType(String archiveType) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "archiveType", false);
        }

        Object oldValue = this.archiveType;
        this.archiveType = archiveType;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "archiveType", oldValue, archiveType);
        }
    }


    public Integer getDateCreated() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateCreated", false);
        }

        return dateCreated;
    }
    public void setDateCreated(Integer dateCreated) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateCreated", false);
        }

        Object oldValue = this.dateCreated;
        this.dateCreated = dateCreated;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "dateCreated", oldValue, dateCreated);
        }
    }


    public Long getDocumentID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentID", false);
        }

        return documentID;
    }
    public void setDocumentID(Long documentID) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentID", false);
        }

        Object oldValue = this.documentID;
        this.documentID = documentID;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "documentID", oldValue, documentID);
        }
    }


    public String getDocumentName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentName", false);
        }

        return documentName;
    }
    public void setDocumentName(String documentName) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentName", false);
        }

        Object oldValue = this.documentName;
        this.documentName = documentName;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "documentName", oldValue, documentName);
        }
    }


    public Boolean getNeedsUpdate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "needsUpdate", false);
        }

        return needsUpdate;
    }
    public void setNeedsUpdate(Boolean needsUpdate) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "needsUpdate", false);
        }

        Object oldValue = this.needsUpdate;
        this.needsUpdate = needsUpdate;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "needsUpdate", oldValue, needsUpdate);
        }
    }


    public Integer getOwnerID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ownerID", false);
        }

        return ownerID;
    }
    public void setOwnerID(Integer ownerID) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ownerID", false);
        }

        Object oldValue = this.ownerID;
        this.ownerID = ownerID;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "ownerID", oldValue, ownerID);
        }
    }


    public String getStatus() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "status", false);
        }

        return status;
    }
    public void setStatus(String status) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "status", false);
        }

        Object oldValue = this.status;
        this.status = status;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "status", oldValue, status);
        }
    }


    public List<Documentvalue> getDocumentvalues() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentvalues", true);
        }

        return documentvalues;
    }
    public void addToDocumentvalues(Documentvalue object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentvalues", true);
        }

        this.documentvalues.add(object);
    }
    public void removeFromDocumentvalues(Documentvalue object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documentvalues", true);
        }

        this.documentvalues.remove(object);
    }

    public List<Page> getPages() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pages", true);
        }

        return pages;
    }
    public void addToPages(Page object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pages", true);
        }

        this.pages.add(object);
    }
    public void removeFromPages(Page object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pages", true);
        }

        this.pages.remove(object);
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

    public List<Workflow> getWorkflows() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflows", true);
        }

        return workflows;
    }
    public void addToWorkflows(Workflow object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflows", true);
        }

        this.workflows.add(object);
    }
    public void removeFromWorkflows(Workflow object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflows", true);
        }

        this.workflows.remove(object);
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
