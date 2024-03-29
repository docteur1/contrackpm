package kf.auto;

import java.util.List;

import org.apache.cayenne.CayenneDataObject;

import kf.Documentvalue;
import kf.Project;

/**
 * Class _Projectfield was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Projectfield extends CayenneDataObject {

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

    public static final String FIELD_ID_PK_COLUMN = "FieldID";

    public String getBarcodeCoords() {
        return (String)readProperty("barcodeCoords");
    }

    public String getDefaultValue() {
        return (String)readProperty("defaultValue");
    }

    public Long getDisplayOrder() {
        return (Long)readProperty("displayOrder");
    }

    public Long getFieldID() {
        return (Long)readProperty("fieldID");
    }

    public String getFieldName() {
        return (String)readProperty("fieldName");
    }

    public String getFieldParams() {
        return (String)readProperty("fieldParams");
    }

    public String getFieldType() {
        return (String)readProperty("fieldType");
    }

    public String getRequired() {
        return (String)readProperty("required");
    }

    public String getToolTip() {
        return (String)readProperty("toolTip");
    }

    public String getZoomCoords() {
        return (String)readProperty("zoomCoords");
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



    public Project getProject() {
        return (Project)readProperty("project");
    }


}
