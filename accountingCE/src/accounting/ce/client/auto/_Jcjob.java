package accounting.ce.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;

import accounting.ce.client.Apvoucherdist;
import accounting.ce.client.Jccat;
import accounting.ce.client.Jcdetail;
import accounting.ce.client.Jcphase;

/**
 * A generated persistent class mapped as "Jcjob" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jcjob extends PersistentObject {

    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String OVERHEADPCNT1_PROPERTY = "overheadpcnt1";
    public static final String OVERHEADPCNT10_PROPERTY = "overheadpcnt10";
    public static final String OVERHEADPCNT11_PROPERTY = "overheadpcnt11";
    public static final String OVERHEADPCNT12_PROPERTY = "overheadpcnt12";
    public static final String OVERHEADPCNT13_PROPERTY = "overheadpcnt13";
    public static final String OVERHEADPCNT14_PROPERTY = "overheadpcnt14";
    public static final String OVERHEADPCNT15_PROPERTY = "overheadpcnt15";
    public static final String OVERHEADPCNT16_PROPERTY = "overheadpcnt16";
    public static final String OVERHEADPCNT2_PROPERTY = "overheadpcnt2";
    public static final String OVERHEADPCNT3_PROPERTY = "overheadpcnt3";
    public static final String OVERHEADPCNT4_PROPERTY = "overheadpcnt4";
    public static final String OVERHEADPCNT5_PROPERTY = "overheadpcnt5";
    public static final String OVERHEADPCNT6_PROPERTY = "overheadpcnt6";
    public static final String OVERHEADPCNT7_PROPERTY = "overheadpcnt7";
    public static final String OVERHEADPCNT8_PROPERTY = "overheadpcnt8";
    public static final String OVERHEADPCNT9_PROPERTY = "overheadpcnt9";
    public static final String CATS_PROPERTY = "cats";
    public static final String DETAIL_PROPERTY = "detail";
    public static final String PHASES_PROPERTY = "phases";
    public static final String VOUCHERDIST_PROPERTY = "voucherdist";

    protected String jobnum;
    protected Float overheadpcnt1;
    protected Float overheadpcnt10;
    protected Float overheadpcnt11;
    protected Float overheadpcnt12;
    protected Float overheadpcnt13;
    protected Float overheadpcnt14;
    protected Float overheadpcnt15;
    protected Float overheadpcnt16;
    protected Float overheadpcnt2;
    protected Float overheadpcnt3;
    protected Float overheadpcnt4;
    protected Float overheadpcnt5;
    protected Float overheadpcnt6;
    protected Float overheadpcnt7;
    protected Float overheadpcnt8;
    protected Float overheadpcnt9;
    protected List<Jccat> cats;
    protected List<Jcdetail> detail;
    protected List<Jcphase> phases;
    protected List<Apvoucherdist> voucherdist;

    public String getJobnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "jobnum", false);
        }

        return jobnum;
    }


    public Float getOverheadpcnt1() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt1", false);
        }

        return overheadpcnt1;
    }


    public Float getOverheadpcnt10() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt10", false);
        }

        return overheadpcnt10;
    }


    public Float getOverheadpcnt11() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt11", false);
        }

        return overheadpcnt11;
    }


    public Float getOverheadpcnt12() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt12", false);
        }

        return overheadpcnt12;
    }


    public Float getOverheadpcnt13() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt13", false);
        }

        return overheadpcnt13;
    }


    public Float getOverheadpcnt14() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt14", false);
        }

        return overheadpcnt14;
    }


    public Float getOverheadpcnt15() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt15", false);
        }

        return overheadpcnt15;
    }


    public Float getOverheadpcnt16() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt16", false);
        }

        return overheadpcnt16;
    }


    public Float getOverheadpcnt2() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt2", false);
        }

        return overheadpcnt2;
    }


    public Float getOverheadpcnt3() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt3", false);
        }

        return overheadpcnt3;
    }


    public Float getOverheadpcnt4() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt4", false);
        }

        return overheadpcnt4;
    }


    public Float getOverheadpcnt5() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt5", false);
        }

        return overheadpcnt5;
    }


    public Float getOverheadpcnt6() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt6", false);
        }

        return overheadpcnt6;
    }


    public Float getOverheadpcnt7() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt7", false);
        }

        return overheadpcnt7;
    }


    public Float getOverheadpcnt8() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt8", false);
        }

        return overheadpcnt8;
    }


    public Float getOverheadpcnt9() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "overheadpcnt9", false);
        }

        return overheadpcnt9;
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

    public List<Jcphase> getPhases() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phases", true);
        }

        return phases;
    }
    public void addToPhases(Jcphase object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phases", true);
        }

        this.phases.add(object);
    }
    public void removeFromPhases(Jcphase object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "phases", true);
        }

        this.phases.remove(object);
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
