package kf.config.client.auto;

import org.apache.cayenne.PersistentObject;

/**
 * A generated persistent class mapped as "Customerconfig" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Customerconfig extends PersistentObject {

    public static final String CUSTOMER_ID_PROPERTY = "customerID";
    public static final String CUSTOMER_NAME_PROPERTY = "customerName";
    public static final String DEFAULT_ACCESS_METHOD_PROPERTY = "defaultAccessMethod";
    public static final String ID_PROPERTY = "id";
    public static final String NETWORK_CACHE_PROPERTY = "networkCache";
    public static final String PROJECT_ROOT_PROPERTY = "projectRoot";
    public static final String REGISTRATION_KEY_PROPERTY = "registrationKey";
    public static final String S_MTPPASSWORD_PROPERTY = "sMTPPassword";
    public static final String S_MTPSERVER_PROPERTY = "sMTPServer";
    public static final String S_MTPUSERNAME_PROPERTY = "sMTPUsername";
    public static final String SERVER_IP_PROPERTY = "serverIP";
    public static final String WEB_CACHE_FOLDER_PROPERTY = "webCacheFolder";
    public static final String WEB_CACHE_METHOD_PROPERTY = "webCacheMethod";
    public static final String WEB_CACHE_PASSWORD_PROPERTY = "webCachePassword";
    public static final String WEB_CACHE_PATH_PROPERTY = "webCachePath";
    public static final String WEB_CACHE_SERVER_PROPERTY = "webCacheServer";
    public static final String WEB_CACHE_USERNAME_PROPERTY = "webCacheUsername";

    protected Integer customerID;
    protected String customerName;
    protected String defaultAccessMethod;
    protected Long id;
    protected String networkCache;
    protected String projectRoot;
    protected String registrationKey;
    protected String sMTPPassword;
    protected String sMTPServer;
    protected String sMTPUsername;
    protected String serverIP;
    protected String webCacheFolder;
    protected String webCacheMethod;
    protected String webCachePassword;
    protected String webCachePath;
    protected String webCacheServer;
    protected String webCacheUsername;

    public Integer getCustomerID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "customerID", false);
        }

        return customerID;
    }


    public String getCustomerName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "customerName", false);
        }

        return customerName;
    }


    public String getDefaultAccessMethod() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "defaultAccessMethod", false);
        }

        return defaultAccessMethod;
    }


    public Long getId() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "id", false);
        }

        return id;
    }


    public String getNetworkCache() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "networkCache", false);
        }

        return networkCache;
    }


    public String getProjectRoot() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "projectRoot", false);
        }

        return projectRoot;
    }


    public String getRegistrationKey() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "registrationKey", false);
        }

        return registrationKey;
    }


    public String getSMTPPassword() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sMTPPassword", false);
        }

        return sMTPPassword;
    }


    public String getSMTPServer() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sMTPServer", false);
        }

        return sMTPServer;
    }


    public String getSMTPUsername() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sMTPUsername", false);
        }

        return sMTPUsername;
    }


    public String getServerIP() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "serverIP", false);
        }

        return serverIP;
    }


    public String getWebCacheFolder() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCacheFolder", false);
        }

        return webCacheFolder;
    }


    public String getWebCacheMethod() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCacheMethod", false);
        }

        return webCacheMethod;
    }


    public String getWebCachePassword() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCachePassword", false);
        }

        return webCachePassword;
    }


    public String getWebCachePath() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCachePath", false);
        }

        return webCachePath;
    }


    public String getWebCacheServer() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCacheServer", false);
        }

        return webCacheServer;
    }


    public String getWebCacheUsername() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "webCacheUsername", false);
        }

        return webCacheUsername;
    }


}
