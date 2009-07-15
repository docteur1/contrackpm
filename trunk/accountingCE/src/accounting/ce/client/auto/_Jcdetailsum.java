package accounting.ce.client.auto;

import org.apache.cayenne.PersistentObject;

/**
 * A generated persistent class mapped as "Jcdetailsum" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jcdetailsum extends PersistentObject {

    public static final String CATNUM_PROPERTY = "catnum";
    public static final String COST_PROPERTY = "cost";
    public static final String HOURS_PROPERTY = "hours";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String PHASENUM_PROPERTY = "phasenum";
    public static final String TYPE_PROPERTY = "type";

    protected String catnum;
    protected Double cost;
    protected Double hours;
    protected String jobnum;
    protected String phasenum;
    protected Integer type;

    public String getCatnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "catnum", false);
        }

        return catnum;
    }
    public void setCatnum(String catnum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "catnum", false);
        }

        Object oldValue = this.catnum;
        this.catnum = catnum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "catnum", oldValue, catnum);
        }
    }


    public Double getCost() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cost", false);
        }

        return cost;
    }
    public void setCost(Double cost) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cost", false);
        }

        Object oldValue = this.cost;
        this.cost = cost;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "cost", oldValue, cost);
        }
    }


    public Double getHours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "hours", false);
        }

        return hours;
    }
    public void setHours(Double hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "hours", false);
        }

        Object oldValue = this.hours;
        this.hours = hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "hours", oldValue, hours);
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


    public String getPhasenum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phasenum", false);
        }

        return phasenum;
    }
    public void setPhasenum(String phasenum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phasenum", false);
        }

        Object oldValue = this.phasenum;
        this.phasenum = phasenum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "phasenum", oldValue, phasenum);
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


}
