package kf.auto;

import java.util.List;

import org.apache.cayenne.CayenneDataObject;

import kf.Document;
import kf.Documentvalue;
import kf.Page;
import kf.Projectfield;
import kf.Workflow;
import kf.Workflowcomment;
import kf.Workflowreason;
import kf.Workflowstep;

/**
 * Class _Project was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Project extends CayenneDataObject {

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

    public static final String PROJECT_ID_PK_COLUMN = "ProjectID";

    public String getAccessMethod() {
        return (String)readProperty("accessMethod");
    }

    public String getBlockIPEnd() {
        return (String)readProperty("blockIPEnd");
    }

    public String getBlockIPStart() {
        return (String)readProperty("blockIPStart");
    }

    public Long getCreatedByID() {
        return (Long)readProperty("createdByID");
    }

    public Integer getDateCreated() {
        return (Integer)readProperty("dateCreated");
    }

    public Boolean getDeleted() {
        return (Boolean)readProperty("deleted");
    }

    public String getNetworkCachePath() {
        return (String)readProperty("networkCachePath");
    }

    public Long getProjectID() {
        return (Long)readProperty("projectID");
    }

    public String getProjectName() {
        return (String)readProperty("projectName");
    }

    public String getProjectPath() {
        return (String)readProperty("projectPath");
    }

    public String getRemotePassword() {
        return (String)readProperty("remotePassword");
    }

    public String getRemoteUsername() {
        return (String)readProperty("remoteUsername");
    }

    public Boolean getRemoveLookupRow() {
        return (Boolean)readProperty("removeLookupRow");
    }

    public String getWebCachePath() {
        return (String)readProperty("webCachePath");
    }

    public void addToDocuments(Document obj) {
        addToManyTarget("documents", obj, true);
    }
    public void removeFromDocuments(Document obj) {
        removeToManyTarget("documents", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Document> getDocuments() {
        return (List<Document>)readProperty("documents");
    }


    public void addToDocumentvalues(Documentvalue obj) {
        addToManyTarget("documentvalues", obj, true);
    }
    public void removeFromDocumentvalues(Documentvalue obj) {
        removeToManyTarget("documentvalues", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Documentvalue> getDocumentvalues() {
        return (List<Documentvalue>)readProperty("documentvalues");
    }


    public void addToPages(Page obj) {
        addToManyTarget("pages", obj, true);
    }
    public void removeFromPages(Page obj) {
        removeToManyTarget("pages", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Page> getPages() {
        return (List<Page>)readProperty("pages");
    }


    public void addToProjectfields(Projectfield obj) {
        addToManyTarget("projectfields", obj, true);
    }
    public void removeFromProjectfields(Projectfield obj) {
        removeToManyTarget("projectfields", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Projectfield> getProjectfields() {
        return (List<Projectfield>)readProperty("projectfields");
    }


    public void addToWorkflowcomments(Workflowcomment obj) {
        addToManyTarget("workflowcomments", obj, true);
    }
    public void removeFromWorkflowcomments(Workflowcomment obj) {
        removeToManyTarget("workflowcomments", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Workflowcomment> getWorkflowcomments() {
        return (List<Workflowcomment>)readProperty("workflowcomments");
    }


    public void addToWorkflowreasons(Workflowreason obj) {
        addToManyTarget("workflowreasons", obj, true);
    }
    public void removeFromWorkflowreasons(Workflowreason obj) {
        removeToManyTarget("workflowreasons", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Workflowreason> getWorkflowreasons() {
        return (List<Workflowreason>)readProperty("workflowreasons");
    }


    public void addToWorkflows(Workflow obj) {
        addToManyTarget("workflows", obj, true);
    }
    public void removeFromWorkflows(Workflow obj) {
        removeToManyTarget("workflows", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Workflow> getWorkflows() {
        return (List<Workflow>)readProperty("workflows");
    }


    public void addToWorkflowsteps(Workflowstep obj) {
        addToManyTarget("workflowsteps", obj, true);
    }
    public void removeFromWorkflowsteps(Workflowstep obj) {
        removeToManyTarget("workflowsteps", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Workflowstep> getWorkflowsteps() {
        return (List<Workflowstep>)readProperty("workflowsteps");
    }


}