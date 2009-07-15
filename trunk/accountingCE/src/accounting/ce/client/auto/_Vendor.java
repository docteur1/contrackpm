package accounting.ce.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;

import accounting.ce.client.Apvoucher;

/**
 * A generated persistent class mapped as "Vendor" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Vendor extends PersistentObject {

    public static final String ADDRESS1_PROPERTY = "address1";
    public static final String ADDRESSCITY_PROPERTY = "addresscity";
    public static final String ADDRESSSTATE_PROPERTY = "addressstate";
    public static final String ADDRESSZIP_PROPERTY = "addresszip";
    public static final String COSTTYPE_PROPERTY = "costtype";
    public static final String EMAIL_PROPERTY = "email";
    public static final String FAXNUM_PROPERTY = "faxnum";
    public static final String ID_PROPERTY = "id";
    public static final String MEMO_PROPERTY = "memo";
    public static final String NAME_PROPERTY = "name";
    public static final String NOTES1_PROPERTY = "notes1";
    public static final String NOTES2_PROPERTY = "notes2";
    public static final String PHONENUM_PROPERTY = "phonenum";
    public static final String VENNUM_PROPERTY = "vennum";
    public static final String WEB_PROPERTY = "web";
    public static final String VOUCHERS_PROPERTY = "vouchers";

    protected String address1;
    protected String addresscity;
    protected String addressstate;
    protected String addresszip;
    protected Integer costtype;
    protected String email;
    protected String faxnum;
    protected String id;
    protected String memo;
    protected String name;
    protected String notes1;
    protected String notes2;
    protected String phonenum;
    protected String vennum;
    protected String web;
    protected List<Apvoucher> vouchers;

    public String getAddress1() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "address1", false);
        }

        return address1;
    }


    public String getAddresscity() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "addresscity", false);
        }

        return addresscity;
    }


    public String getAddressstate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "addressstate", false);
        }

        return addressstate;
    }


    public String getAddresszip() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "addresszip", false);
        }

        return addresszip;
    }


    public Integer getCosttype() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "costtype", false);
        }

        return costtype;
    }


    public String getEmail() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "email", false);
        }

        return email;
    }


    public String getFaxnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "faxnum", false);
        }

        return faxnum;
    }


    public String getId() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "id", false);
        }

        return id;
    }


    public String getMemo() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "memo", false);
        }

        return memo;
    }


    public String getName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "name", false);
        }

        return name;
    }


    public String getNotes1() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "notes1", false);
        }

        return notes1;
    }


    public String getNotes2() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "notes2", false);
        }

        return notes2;
    }


    public String getPhonenum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phonenum", false);
        }

        return phonenum;
    }


    public String getVennum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vennum", false);
        }

        return vennum;
    }


    public String getWeb() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "web", false);
        }

        return web;
    }


    public List<Apvoucher> getVouchers() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vouchers", true);
        }

        return vouchers;
    }
    public void addToVouchers(Apvoucher object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vouchers", true);
        }

        this.vouchers.add(object);
    }
    public void removeFromVouchers(Apvoucher object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vouchers", true);
        }

        this.vouchers.remove(object);
    }

}
