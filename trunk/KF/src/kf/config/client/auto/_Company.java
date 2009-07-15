package kf.config.client.auto;

import org.apache.cayenne.PersistentObject;

/**
 * A generated persistent class mapped as "Company" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Company extends PersistentObject {

    public static final String COMPANY_ID_PROPERTY = "companyId";
    public static final String COMPANY_NAME_PROPERTY = "companyName";
    public static final String D_BNAME_PROPERTY = "dBName";
    public static final String D_BPASSWORD_PROPERTY = "dBPassword";
    public static final String D_BSERVER_PROPERTY = "dBServer";
    public static final String D_BUSERNAME_PROPERTY = "dBUsername";
    public static final String KEY_NAME_PROPERTY = "keyName";
    public static final String LICENSES_PROPERTY = "licenses";
    public static final String REGISTRATION_KEY_PROPERTY = "registrationKey";

    protected Long companyId;
    protected String companyName;
    protected String dBName;
    protected String dBPassword;
    protected String dBServer;
    protected String dBUsername;
    protected String keyName;
    protected Integer licenses;
    protected String registrationKey;

    public Long getCompanyId() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "companyId", false);
        }

        return companyId;
    }


    public String getCompanyName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "companyName", false);
        }

        return companyName;
    }


    public String getDBName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dBName", false);
        }

        return dBName;
    }


    public String getDBPassword() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dBPassword", false);
        }

        return dBPassword;
    }


    public String getDBServer() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dBServer", false);
        }

        return dBServer;
    }


    public String getDBUsername() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dBUsername", false);
        }

        return dBUsername;
    }


    public String getKeyName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "keyName", false);
        }

        return keyName;
    }


    public Integer getLicenses() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "licenses", false);
        }

        return licenses;
    }


    public String getRegistrationKey() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "registrationKey", false);
        }

        return registrationKey;
    }


}
