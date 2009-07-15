package accounting.ce.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Apvoucherdist;
import accounting.ce.client.Jccat;
import accounting.ce.client.Jcdetail;
import accounting.ce.client.Jcjob;

/**
 * A generated persistent class mapped as "Jcphase" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jcphase extends PersistentObject {

    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String NAME_PROPERTY = "name";
    public static final String PHASENUM_PROPERTY = "phasenum";
    public static final String SEQUENCE_PROPERTY = "sequence";
    public static final String CATS_PROPERTY = "cats";
    public static final String DETAIL_PROPERTY = "detail";
    public static final String JOB_PROPERTY = "job";
    public static final String VOUCHERDIST_PROPERTY = "voucherdist";

    protected String jobnum;
    protected String name;
    protected String phasenum;
    protected Integer sequence;
    protected List<Jccat> cats;
    protected List<Jcdetail> detail;
    protected ValueHolder job;
    protected List<Apvoucherdist> voucherdist;

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


    public String getName() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "name", false);
        }

        return name;
    }
    public void setName(String name) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "name", false);
        }

        Object oldValue = this.name;
        this.name = name;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "name", oldValue, name);
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


    public Integer getSequence() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sequence", false);
        }

        return sequence;
    }
    public void setSequence(Integer sequence) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "sequence", false);
        }

        Object oldValue = this.sequence;
        this.sequence = sequence;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "sequence", oldValue, sequence);
        }
    }


    public List<Jccat> getCats() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cats", true);
        }

        return cats;
    }
    public void addToCats(Jccat object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cats", true);
        }

        this.cats.add(object);
    }
    public void removeFromCats(Jccat object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cats", true);
        }

        this.cats.remove(object);
    }

    public List<Jcdetail> getDetail() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "detail", true);
        }

        return detail;
    }
    public void addToDetail(Jcdetail object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "detail", true);
        }

        this.detail.add(object);
    }
    public void removeFromDetail(Jcdetail object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "detail", true);
        }

        this.detail.remove(object);
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

    public List<Apvoucherdist> getVoucherdist() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "voucherdist", true);
        }

        return voucherdist;
    }
    public void addToVoucherdist(Apvoucherdist object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "voucherdist", true);
        }

        this.voucherdist.add(object);
    }
    public void removeFromVoucherdist(Apvoucherdist object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "voucherdist", true);
        }

        this.voucherdist.remove(object);
    }

}
