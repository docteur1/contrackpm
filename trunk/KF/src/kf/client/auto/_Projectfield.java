package kf.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import kf.client.Documentvalue;
import kf.client.Project;

/**
 * A generated persistent class mapped as "Projectfield" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Projectfield extends PersistentObject {

    public static final String BARCODE_COORDS_PROPERTY = "barcodeCoords";
    public static final String DEFAULT_VALUE_PROPERTY = "defaultValue";
    public static final String DISPLAY_ORDER_PROPERTY = "displayOrder";
    public static final String FIELD_ID_PROPERTY = "fieldID";
    public static final String FIELD_NAME_PROPERTY = "fieldName";
    public static final String FIELD_PARAMS_PROPERTY = "fieldParams";
    public static final String FIELD_TYPE_PROPERTY = "fieldType";
    public static final String REQUIRED_PROPERTY = "required";
    public static final String TOOL_TIP_PROPERTY = "toolTip";
    public static final String ZOOM_COORDS_PROPERTY = "zoomCoords";
    public static final String DOCUMENTVALUES_PROPERTY = "documentvalues";
    public static final String PROJECT_PROPERTY = "project";

    protected String barcodeCoords;
    protected String defaultValue;
    protected Long displayOrder;
    protected Long fieldID;
    protected String fieldName;
    protected String fieldParams;
    protected String fieldType;
    protected String required;
    protected String toolTip;
    protected String zoomCoords;
    protected List<Documentvalue> documentvalues;
    protected ValueHolder project;

    public String getBarcodeCoords() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "barcodeCoords", false);
        }

        return barcodeCoords;
    }


    public String getDefaultValue() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "defaultValue", false);
        }

        return defaultValue;
    }


    public Long getDisplayOrder() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "displayOrder", false);
        }

        return displayOrder;
    }


    public Long getFieldID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldID", false);
        }

        return fieldID;
    }


    public String getFieldName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldName", false);
        }

        return fieldName;
    }


    public String getFieldParams() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldParams", false);
        }

        return fieldParams;
    }


    public String getFieldType() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "fieldType", false);
        }

        return fieldType;
    }


    public String getRequired() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "required", false);
        }

        return required;
    }


    public String getToolTip() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "toolTip", false);
        }

        return toolTip;
    }


    public String getZoomCoords() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "zoomCoords", false);
        }

        return zoomCoords;
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

    public Project getProject() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "project", true);
        }

        return (Project) project.getValue();
    }

}
