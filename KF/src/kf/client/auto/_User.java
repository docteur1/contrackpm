package kf.client.auto;

import java.util.Date;
import java.util.List;

import org.apache.cayenne.PersistentObject;

import kf.client.Page;
import kf.client.Workflowcomment;
import kf.client.Workflowstep;

/**
 * A generated persistent class mapped as "User" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _User extends PersistentObject {

    public static final String EMAIL_PROPERTY = "email";
    public static final String FIRST_NAME_PROPERTY = "firstName";
    public static final String IMG_URL_PROPERTY = "imgUrl";
    public static final String LAST_ACTIVITY_DATE_PROPERTY = "lastActivityDate";
    public static final String LAST_IP_PROPERTY = "lastIP";
    public static final String LAST_LOGIN_DATE_PROPERTY = "lastLoginDate";
    public static final String LAST_NAME_PROPERTY = "lastName";
    public static final String LOGGED_IN_PROPERTY = "loggedIn";
    public static final String PASSWORD_PROPERTY = "password";
    public static final String PHONE_PROPERTY = "phone";
    public static final String START_PAGE_PROPERTY = "startPage";
    public static final String STATUS_PROPERTY = "status";
    public static final String TIME_ZONE_PROPERTY = "timeZone";
    public static final String USER_ID_PROPERTY = "userID";
    public static final String USERNAME_PROPERTY = "username";
    public static final String PAGES_PROPERTY = "pages";
    public static final String RECEIVED_WORKFLOWSTEPS_PROPERTY = "receivedWorkflowsteps";
    public static final String SENT_WORKFLOWSTEPS_PROPERTY = "sentWorkflowsteps";
    public static final String WORKFLOWCOMMENTS_PROPERTY = "workflowcomments";

    protected String email;
    protected String firstName;
    protected String imgUrl;
    protected Date lastActivityDate;
    protected String lastIP;
    protected Date lastLoginDate;
    protected String lastName;
    protected Boolean loggedIn;
    protected String password;
    protected String phone;
    protected String startPage;
    protected String status;
    protected Integer timeZone;
    protected Long userID;
    protected String username;
    protected List<Page> pages;
    protected List<Workflowstep> receivedWorkflowsteps;
    protected List<Workflowstep> sentWorkflowsteps;
    protected List<Workflowcomment> workflowcomments;

    public String getEmail() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "email", false);
        }

        return email;
    }


    public String getFirstName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "firstName", false);
        }

        return firstName;
    }


    public String getImgUrl() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "imgUrl", false);
        }

        return imgUrl;
    }


    public Date getLastActivityDate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "lastActivityDate", false);
        }

        return lastActivityDate;
    }


    public String getLastIP() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "lastIP", false);
        }

        return lastIP;
    }


    public Date getLastLoginDate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "lastLoginDate", false);
        }

        return lastLoginDate;
    }


    public String getLastName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "lastName", false);
        }

        return lastName;
    }


    public Boolean getLoggedIn() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "loggedIn", false);
        }

        return loggedIn;
    }


    public String getPassword() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "password", false);
        }

        return password;
    }


    public String getPhone() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phone", false);
        }

        return phone;
    }


    public String getStartPage() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "startPage", false);
        }

        return startPage;
    }


    public String getStatus() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "status", false);
        }

        return status;
    }


    public Integer getTimeZone() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "timeZone", false);
        }

        return timeZone;
    }


    public Long getUserID() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "userID", false);
        }

        return userID;
    }


    public String getUsername() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "username", false);
        }

        return username;
    }


    public List<Page> getPages() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pages", true);
        }

        return pages;
    }
    public void addToPages(Page object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pages", true);
        }

        this.pages.add(object);
    }
    public void removeFromPages(Page object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "pages", true);
        }

        this.pages.remove(object);
    }

    public List<Workflowstep> getReceivedWorkflowsteps() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "receivedWorkflowsteps", true);
        }

        return receivedWorkflowsteps;
    }
    public void addToReceivedWorkflowsteps(Workflowstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "receivedWorkflowsteps", true);
        }

        this.receivedWorkflowsteps.add(object);
    }
    public void removeFromReceivedWorkflowsteps(Workflowstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "receivedWorkflowsteps", true);
        }

        this.receivedWorkflowsteps.remove(object);
    }

    public List<Workflowstep> getSentWorkflowsteps() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sentWorkflowsteps", true);
        }

        return sentWorkflowsteps;
    }
    public void addToSentWorkflowsteps(Workflowstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sentWorkflowsteps", true);
        }

        this.sentWorkflowsteps.add(object);
    }
    public void removeFromSentWorkflowsteps(Workflowstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sentWorkflowsteps", true);
        }

        this.sentWorkflowsteps.remove(object);
    }

    public List<Workflowcomment> getWorkflowcomments() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomments", true);
        }

        return workflowcomments;
    }
    public void addToWorkflowcomments(Workflowcomment object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomments", true);
        }

        this.workflowcomments.add(object);
    }
    public void removeFromWorkflowcomments(Workflowcomment object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "workflowcomments", true);
        }

        this.workflowcomments.remove(object);
    }

}
