package accounting.ce.client.auto;

import org.apache.cayenne.PersistentObject;

/**
 * A generated persistent class mapped as "Glinfo" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Glinfo extends PersistentObject {

    public static final String GLPERIOD_PROPERTY = "glperiod";
    public static final String STARTMONTH_PROPERTY = "startmonth";

    protected Integer glperiod;
    protected Integer startmonth;

    public Integer getGlperiod() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "glperiod", false);
        }

        return glperiod;
    }


    public Integer getStartmonth() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "startmonth", false);
        }

        return startmonth;
    }


}
