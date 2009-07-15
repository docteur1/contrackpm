package accounting.ce.client.auto;

import java.util.Date;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Jccat;
import accounting.ce.client.Jcjob;
import accounting.ce.client.Jcphase;

/**
 * A generated persistent class mapped as "Jcdetail" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jcdetail extends PersistentObject {

    public static final String CATNUM_PROPERTY = "catnum";
    public static final String COST_PROPERTY = "cost";
    public static final String DATE_PROPERTY = "date";
    public static final String DATEPOSTED_PROPERTY = "dateposted";
    public static final String DES1_PROPERTY = "des1";
    public static final String DES2_PROPERTY = "des2";
    public static final String GLPERIOD_PROPERTY = "glperiod";
    public static final String HOURS_PROPERTY = "hours";
    public static final String INVNUM_PROPERTY = "invnum";
    public static final String JCUNIQUE_PROPERTY = "jcunique";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String MINORTYPE_PROPERTY = "minortype";
    public static final String PHASENUM_PROPERTY = "phasenum";
    public static final String PONUM_PROPERTY = "ponum";
    public static final String SERIALNUM_PROPERTY = "serialnum";
    public static final String TYPE_PROPERTY = "type";
    public static final String WHO_PROPERTY = "who";
    public static final String CAT_PROPERTY = "cat";
    public static final String JOB_PROPERTY = "job";
    public static final String PHASE_PROPERTY = "phase";

    protected String catnum;
    protected Double cost;
    protected Date date;
    protected Date dateposted;
    protected String des1;
    protected String des2;
    protected Integer glperiod;
    protected Double hours;
    protected String invnum;
    protected Integer jcunique;
    protected String jobnum;
    protected Integer minortype;
    protected String phasenum;
    protected String ponum;
    protected Integer serialnum;
    protected Integer type;
    protected String who;
    protected ValueHolder cat;
    protected ValueHolder job;
    protected ValueHolder phase;

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


    public Date getDateposted() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateposted", false);
        }

        return dateposted;
    }
    public void setDateposted(Date dateposted) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "dateposted", false);
        }

        Object oldValue = this.dateposted;
        this.dateposted = dateposted;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "dateposted", oldValue, dateposted);
        }
    }


    public String getDes1() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des1", false);
        }

        return des1;
    }
    public void setDes1(String des1) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des1", false);
        }

        Object oldValue = this.des1;
        this.des1 = des1;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "des1", oldValue, des1);
        }
    }


    public String getDes2() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des2", false);
        }

        return des2;
    }
    public void setDes2(String des2) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des2", false);
        }

        Object oldValue = this.des2;
        this.des2 = des2;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "des2", oldValue, des2);
        }
    }


    public Integer getGlperiod() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "glperiod", false);
        }

        return glperiod;
    }
    public void setGlperiod(Integer glperiod) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "glperiod", false);
        }

        Object oldValue = this.glperiod;
        this.glperiod = glperiod;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "glperiod", oldValue, glperiod);
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


    public String getInvnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "invnum", false);
        }

        return invnum;
    }
    public void setInvnum(String invnum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "invnum", false);
        }

        Object oldValue = this.invnum;
        this.invnum = invnum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "invnum", oldValue, invnum);
        }
    }


    public Integer getJcunique() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "jcunique", false);
        }

        return jcunique;
    }
    public void setJcunique(Integer jcunique) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "jcunique", false);
        }

        Object oldValue = this.jcunique;
        this.jcunique = jcunique;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "jcunique", oldValue, jcunique);
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


    public Integer getMinortype() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "minortype", false);
        }

        return minortype;
    }
    public void setMinortype(Integer minortype) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "minortype", false);
        }

        Object oldValue = this.minortype;
        this.minortype = minortype;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "minortype", oldValue, minortype);
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


    public String getPonum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ponum", false);
        }

        return ponum;
    }
    public void setPonum(String ponum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ponum", false);
        }

        Object oldValue = this.ponum;
        this.ponum = ponum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "ponum", oldValue, ponum);
        }
    }


    public Integer getSerialnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "serialnum", false);
        }

        return serialnum;
    }
    public void setSerialnum(Integer serialnum) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "serialnum", false);
        }

        Object oldValue = this.serialnum;
        this.serialnum = serialnum;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "serialnum", oldValue, serialnum);
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


    public Jccat getCat() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cat", true);
        }

        return (Jccat) cat.getValue();
    }
    public void setCat(Jccat cat) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cat", true);
        }

        this.cat.setValue(cat);
    }

    public Jcjob getJob() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "job", true);
        }

        return (Jcjob) job.getValue();
    }
    public void setJob(Jcjob job) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "job", true);
        }

        this.job.setValue(job);
    }

    public Jcphase getPhase() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phase", true);
        }

        return (Jcphase) phase.getValue();
    }
    public void setPhase(Jcphase phase) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phase", true);
        }

        this.phase.setValue(phase);
    }

}
