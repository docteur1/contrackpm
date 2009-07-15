package accounting.ce.client.auto;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Apvoucher;

/**
 * A generated persistent class mapped as "Apcheck" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Apcheck extends PersistentObject {

    public static final String APAMT_PROPERTY = "apamt";
    public static final String CHECKNUM_PROPERTY = "checknum";
    public static final String NAME_PROPERTY = "name";
    public static final String VOUCHER_PROPERTY = "voucher";

    protected Double apamt;
    protected Integer checknum;
    protected String name;
    protected ValueHolder voucher;

    public Double getApamt() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "apamt", false);
        }

        return apamt;
    }


    public Integer getChecknum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "checknum", false);
        }

        return checknum;
    }


    public String getName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "name", false);
        }

        return name;
    }


    public Apvoucher getVoucher() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "voucher", true);
        }

        return (Apvoucher) voucher.getValue();
    }

}
