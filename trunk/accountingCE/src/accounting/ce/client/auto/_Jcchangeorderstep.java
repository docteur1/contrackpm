package accounting.ce.client.auto;

import java.sql.Date;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Jcchangeorder;

/**
 * A generated persistent class mapped as "Jcchangeorderstep" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jcchangeorderstep extends PersistentObject {

    public static final String DATE_PROPERTY = "date";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String ORDERNUM_PROPERTY = "ordernum";
    public static final String TYPE_PROPERTY = "type";
    public static final String WHO_PROPERTY = "who";
    public static final String CHANGEORDER_PROPERTY = "changeorder";

    protected Date date;
    protected String jobnum;
    protected String ordernum;
    protected Integer type;
    protected String who;
    protected ValueHolder changeorder;

    public Date getDate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "date", false);
        }

        return date;
    }
    public void setDate(Date date) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "date", false);
        }

        Object oldValue = this.date;
        this.date = date;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "date", oldValue, date);
        }
    }


    public String getJobnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "jobnum", false);
        }

        return jobnum;
    }
    public void setJobnum(String jobnum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "jobnum", false);
        }

        Object oldValue = this.jobnum;
        this.jobnum = jobnum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "jobnum", oldValue, jobnum);
        }
    }


    public String getOrdernum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ordernum", false);
        }

        return ordernum;
    }
    public void setOrdernum(String ordernum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ordernum", false);
        }

        Object oldValue = this.ordernum;
        this.ordernum = ordernum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "ordernum", oldValue, ordernum);
        }
    }


    public Integer getType() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "type", false);
        }

        return type;
    }
    public void setType(Integer type) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "type", false);
        }

        Object oldValue = this.type;
        this.type = type;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "type", oldValue, type);
        }
    }


    public String getWho() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "who", false);
        }

        return who;
    }
    public void setWho(String who) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "who", false);
        }

        Object oldValue = this.who;
        this.who = who;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "who", oldValue, who);
        }
    }


    public Jcchangeorder getChangeorder() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "changeorder", true);
        }

        return (Jcchangeorder) changeorder.getValue();
    }
    public void setChangeorder(Jcchangeorder changeorder) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "changeorder", true);
        }

        this.changeorder.setValue(changeorder);
    }

}
