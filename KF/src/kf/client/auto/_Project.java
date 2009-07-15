package kf.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;

import kf.client.Document;
import kf.client.Documentvalue;
import kf.client.Page;
import kf.client.Projectfield;
import kf.client.Workflow;
import kf.client.Workflowcomment;
import kf.client.Workflowreason;
import kf.client.Workflowstep;

/**
 * A generated persistent class mapped as "Project" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Project extends PersistentObject {

    public static final String ACCESS_METHOD_PROPERTY = "accessMethod";
    public static final String BLOCK_IPEND_PROPERTY = "blockIPEnd";
    public static final String BLOCK_IPSTART_PROPERTY = "blockIPStart";
    public static final String CREATED_BY_ID_PROPERTY = "createdByID";
    public static final String DATE_CREATED_PROPERTY = "dateCreated";
    public static final String DELETED_PROPERTY = "deleted";
    public static final String NETWORK_CACHE_PATH_PROPERTY = "networkCachePath";
    public static final String PROJECT_ID_PROPERTY = "projectID";
    public static final String PROJECT_NAME_PROPERTY = "projectName";
    public static final String PROJECT_PATH_PROPERTY = "projectPath";
    public static final String REMOTE_PASSWORD_PROPERTY = "remotePassword";
    public static final String REMOTE_USERNAME_PROPERTY = "remoteUsername";
    public static final String REMOVE_LOOKUP_ROW_PROPERTY = "removeLookupRow";
    public static final String WEB_CACHE_PATH_PROPERTY = "webCachePath";
    public static final String DOCUMENTS_PROPERTY = "documents";
    public static final String DOCUMENTVALUES_PROPERTY = "documentvalues";
    public static final String PAGES_PROPERTY = "pages";
    public static final String PROJECTFIELDS_PROPERTY = "projectfields";
    public static final String WORKFLOWCOMMENTS_PROPERTY = "workflowcomments";
    public static final String WORKFLOWREASONS_PROPERTY = "workflowreasons";
    public static final String WORKFLOWS_PROPERTY = "workflows";
    public static final String WORKFLOWSTEPS_PROPERTY = "workflowsteps";

    protected String accessMethod;
    protected String blockIPEnd;
    protected String blockIPStart;
    protected Long createdByID;
    protected Integer dateCreated;
    protected Boolean deleted;
    protected String networkCachePath;
    protected Long projectID;
    protected String projectName;
    protected String projectPath;
    protected String remotePassword;
    protected String remoteUsername;
    protected Boolean removeLookupRow;
    protected String webCachePath;
    protected List<Document> documents;
    protected List<Documentvalue> documentvalues;
    protected List<Page> pages;
    protected List<Projectfield> projectfields;
    protected List<Workflowcomment> workflowcomments;
    protected List<Workflowreason> workflowreasons;
    protected List<Workflow> workflows;
    protected List<Workflowstep> workflowsteps;

    public String getAccessMethod() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "accessMethod", false);
        }

        return accessMethod;
    }


    public String getBlockIPEnd() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "blockIPEnd", false);
        }

        return blockIPEnd;
    }


    public String getBlockIPStart() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "blockIPStart", false);
        }

        return blockIPStart;
    }


    public Long getCreatedByID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "createdByID", false);
        }

        return createdByID;
    }


    public Integer getDateCreated() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateCreated", false);
        }

        return dateCreated;
    }


    public Boolean getDeleted() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "deleted", false);
        }

        return deleted;
    }


    public String getNetworkCachePath() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "networkCachePath", false);
        }

        return networkCachePath;
    }


    public Long getProjectID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectID", false);
        }

        return projectID;
    }


    public String getProjectName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectName", false);
        }

        return projectName;
    }


    public String getProjectPath() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectPath", false);
        }

        return projectPath;
    }


    public String getRemotePassword() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "remotePassword", false);
        }

        return remotePassword;
    }


    public String getRemoteUsername() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "remoteUsername", false);
        }

        return remoteUsername;
    }


    public Boolean getRemoveLookupRow() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "removeLookupRow", false);
        }

        return removeLookupRow;
    }


    public String getWebCachePath() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCachePath", false);
        }

        return webCachePath;
    }


    public List<Document> getDocuments() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documents", true);
        }

        return documents;
    }
    public void addToDocuments(Document object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documents", true);
        }

        this.documents.add(object);
    }
    public void removeFromDocuments(Document object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "documents", true);
        }

        this.documents.remove(object);
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

    public List<Projectfield> getProjectfields() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectfields", true);
        }

        return projectfields;
    }
    public void addToProjectfields(Projectfield object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectfields", true);
        }

        this.projectfields.add(object);
    }
    public void removeFromProjectfields(Projectfield object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectfields", true);
        }

        this.projectfields.remove(object);
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

    public List<Workflowreason> getWorkflowreasons() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowreasons", true);
        }

        return workflowreasons;
    }
    public void addToWorkflowreasons(Workflowreason object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowreasons", true);
        }

        this.workflowreasons.add(object);
    }
    public void removeFromWorkflowreasons(Workflowreason object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowreasons", true);
        }

        this.workflowreasons.remove(object);
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
