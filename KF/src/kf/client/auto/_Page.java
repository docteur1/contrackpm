package kf.client.auto;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Document;
import kf.client.Project;
import kf.client.User;

/**
 * A generated persistent class mapped as "Page" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Page extends PersistentObject {

    public static final String BATCH_ID_PROPERTY = "batchID";
    public static final String DATE_CREATED_PROPERTY = "dateCreated";
    public static final String EXTENSION_PROPERTY = "extension";
    public static final String PAGE_ID_PROPERTY = "pageID";
    public static final String PAGE_ORDER_PROPERTY = "pageOrder";
    public static final String DOCUMENT_PROPERTY = "document";
    public static final String PROJECT_PROPERTY = "project";
    public static final String USERS_PROPERTY = "users";

    protected Integer batchID;
    protected Integer dateCreated;
    protected String extension;
    protected Long pageID;
    protected Integer pageOrder;
    protected ValueHolder document;
    protected ValueHolder project;
    protected ValueHolder users;

    public Integer getBatchID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "batchID", false);
        }

        return batchID;
    }


    public Integer getDateCreated() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateCreated", false);
        }

        return dateCreated;
    }


    public String getExtension() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "extension", false);
        }

        return extension;
    }


    public Long getPageID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pageID", false);
        }

        return pageID;
    }


    public Integer getPageOrder() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pageOrder", false);
        }

        return pageOrder;
    }


    public Document getDocument() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "document", true);
        }

        return (Document) document.getValue();
    }

    public Project getProject() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "project", true);
        }

        return (Project) project.getValue();
    }

    public User getUsers() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "users", true);
        }

        return (User) users.getValue();
    }

}
