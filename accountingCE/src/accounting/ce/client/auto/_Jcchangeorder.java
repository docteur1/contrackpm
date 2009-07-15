package accounting.ce.client.auto;

import java.sql.Date;
import java.util.List;

import org.apache.cayenne.PersistentObject;

import accounting.ce.client.Jcchangeorderstep;

/**
 * A generated persistent class mapped as "Jcchangeorder" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jcchangeorder extends PersistentObject {

    public static final String CONUM_PROPERTY = "conum";
    public static final String DATE_PROPERTY = "date";
    public static final String DES_PROPERTY = "des";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String NOTES_PROPERTY = "notes";
    public static final String ORDERNUM_PROPERTY = "ordernum";
    public static final String TYPE_PROPERTY = "type";
    public static final String CHANGEORDERSTEPS_PROPERTY = "changeordersteps";

    protected String conum;
    protected Date date;
    protected String des;
    protected String jobnum;
    protected String notes;
    protected String ordernum;
    protected Integer type;
    protected List<Jcchangeorderstep> changeordersteps;

    public String getConum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "conum", false);
        }

        return conum;
    }
    public void setConum(String conum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "conum", false);
        }

        Object oldValue = this.conum;
        this.conum = conum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "conum", oldValue, conum);
        }
    }


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


    public String getDes() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des", false);
        }

        return des;
    }
    public void setDes(String des) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des", false);
        }

        Object oldValue = this.des;
        this.des = des;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "des", oldValue, des);
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


    public String getNotes() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "notes", false);
        }

        return notes;
    }
    public void setNotes(String notes) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "notes", false);
        }

        Object oldValue = this.notes;
        this.notes = notes;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "notes", oldValue, notes);
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


    public List<Jcchangeorderstep> getChangeordersteps() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "changeordersteps", true);
        }

        return changeordersteps;
    }
    public void addToChangeordersteps(Jcchangeorderstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "changeordersteps", true);
        }

        this.changeordersteps.add(object);
    }
    public void removeFromChangeordersteps(Jcchangeorderstep object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "changeordersteps", true);
        }

        this.changeordersteps.remove(object);
    }

}
