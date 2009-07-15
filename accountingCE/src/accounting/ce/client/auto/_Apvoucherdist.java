package accounting.ce.client.auto;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Apvoucher;
import accounting.ce.client.Jccat;
import accounting.ce.client.Jcjob;
import accounting.ce.client.Jcphase;

/**
 * A generated persistent class mapped as "Apvoucherdist" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Apvoucherdist extends PersistentObject {

    public static final String AMOUNT_PROPERTY = "amount";
    public static final String CATNUM_PROPERTY = "catnum";
    public static final String COSTTYPE_PROPERTY = "costtype";
    public static final String DES_PROPERTY = "des";
    public static final String DISCTAKEN_PROPERTY = "disctaken";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String PHASENUM_PROPERTY = "phasenum";
    public static final String PTD_PROPERTY = "ptd";
    public static final String RETHELD_PROPERTY = "retheld";
    public static final String VENNUM_PROPERTY = "vennum";
    public static final String CAT_PROPERTY = "cat";
    public static final String JOB_PROPERTY = "job";
    public static final String PHASE_PROPERTY = "phase";
    public static final String VOUCHER_PROPERTY = "voucher";

    protected Double amount;
    protected String catnum;
    protected Short costtype;
    protected String des;
    protected Double disctaken;
    protected String jobnum;
    protected String phasenum;
    protected Double ptd;
    protected Double retheld;
    protected String vennum;
    protected ValueHolder cat;
    protected ValueHolder job;
    protected ValueHolder phase;
    protected ValueHolder voucher;

    public Double getAmount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "amount", false);
        }

        return amount;
    }


    public String getCatnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "catnum", false);
        }

        return catnum;
    }


    public Short getCosttype() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "costtype", false);
        }

        return costtype;
    }


    public String getDes() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "des", false);
        }

        return des;
    }


    public Double getDisctaken() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "disctaken", false);
        }

        return disctaken;
    }


    public String getJobnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "jobnum", false);
        }

        return jobnum;
    }


    public String getPhasenum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phasenum", false);
        }

        return phasenum;
    }


    public Double getPtd() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ptd", false);
        }

        return ptd;
    }


    public Double getRetheld() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "retheld", false);
        }

        return retheld;
    }


    public String getVennum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vennum", false);
        }

        return vennum;
    }


    public Jccat getCat() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "cat", true);
        }

        return (Jccat) cat.getValue();
    }

    public Jcjob getJob() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "job", true);
        }

        return (Jcjob) job.getValue();
    }

    public Jcphase getPhase() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phase", true);
        }

        return (Jcphase) phase.getValue();
    }

    public Apvoucher getVoucher() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "voucher", true);
        }

        return (Apvoucher) voucher.getValue();
    }

}
