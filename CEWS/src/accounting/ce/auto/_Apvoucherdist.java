package accounting.ce.auto;

import org.apache.cayenne.CayenneDataObject;

import accounting.ce.Apvoucher;
import accounting.ce.Jccat;
import accounting.ce.Jcjob;
import accounting.ce.Jcphase;

/**
 * Class _Apvoucherdist was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Apvoucherdist extends CayenneDataObject {

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

    public static final String SEQUENCE_PK_COLUMN = "sequence";
    public static final String VOUCHERNUM_PK_COLUMN = "vouchernum";

    public Double getAmount() {
        return (Double)readProperty("amount");
    }

    public String getCatnum() {
        return (String)readProperty("catnum");
    }

    public Short getCosttype() {
        return (Short)readProperty("costtype");
    }

    public String getDes() {
        return (String)readProperty("des");
    }

    public Double getDisctaken() {
        return (Double)readProperty("disctaken");
    }

    public String getJobnum() {
        return (String)readProperty("jobnum");
    }

    public String getPhasenum() {
        return (String)readProperty("phasenum");
    }

    public Double getPtd() {
        return (Double)readProperty("ptd");
    }

    public Double getRetheld() {
        return (Double)readProperty("retheld");
    }

    public String getVennum() {
        return (String)readProperty("vennum");
    }


    public Jccat getCat() {
        return (Jccat)readProperty("cat");
    }



    public Jcjob getJob() {
        return (Jcjob)readProperty("job");
    }



    public Jcphase getPhase() {
        return (Jcphase)readProperty("phase");
    }



    public Apvoucher getVoucher() {
        return (Apvoucher)readProperty("voucher");
    }


}
