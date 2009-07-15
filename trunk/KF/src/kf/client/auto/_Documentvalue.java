package kf.client.auto;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Document;
import kf.client.Project;
import kf.client.Projectfield;

/**
 * A generated persistent class mapped as "Documentvalue" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Documentvalue extends PersistentObject {

    public static final String FIELD_ID_PROPERTY = "fieldID";
    public static final String FIELD_VALUE_PROPERTY = "fieldValue";
    public static final String DOCUMENT_PROPERTY = "document";
    public static final String PROJECT_PROPERTY = "project";
    public static final String PROJECTFIELD_PROPERTY = "projectfield";

    protected Long fieldID;
    protected String fieldValue;
    protected ValueHolder document;
    protected ValueHolder project;
    protected ValueHolder projectfield;

    public Long getFieldID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldID", false);
        }

        return fieldID;
    }
    public void setFieldID(Long fieldID) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldID", false);
        }

        Object oldValue = this.fieldID;
        this.fieldID = fieldID;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "fieldID", oldValue, fieldID);
        }
    }


    public String getFieldValue() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldValue", false);
        }

        return fieldValue;
    }
    public void setFieldValue(String fieldValue) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldValue", false);
        }

        Object oldValue = this.fieldValue;
        this.fieldValue = fieldValue;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "fieldValue", oldValue, fieldValue);
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

    public Projectfield getProjectfield() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectfield", true);
        }

        return (Projectfield) projectfield.getValue();
    }
    public void setProjectfield(Projectfield projectfield) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectfield", true);
        }

        this.projectfield.setValue(projectfield);
    }

}
