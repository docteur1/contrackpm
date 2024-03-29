package accounting.ce.auto;

import java.util.List;

import org.apache.cayenne.CayenneDataObject;

import accounting.ce.Apvoucherdist;
import accounting.ce.Jccat;
import accounting.ce.Jcdetail;
import accounting.ce.Jcjob;

/**
 * Class _Jcphase was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Jcphase extends CayenneDataObject {

    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String NAME_PROPERTY = "name";
    public static final String PHASENUM_PROPERTY = "phasenum";
    public static final String SEQUENCE_PROPERTY = "sequence";
    public static final String CATS_PROPERTY = "cats";
    public static final String DETAIL_PROPERTY = "detail";
    public static final String JOB_PROPERTY = "job";
    public static final String VOUCHERDIST_PROPERTY = "voucherdist";

    public static final String JOBNUM_PK_COLUMN = "jobnum";
    public static final String PHASENUM_PK_COLUMN = "phasenum";

    public void setJobnum(String jobnum) {
        writeProperty("jobnum", jobnum);
    }
    public String getJobnum() {
        return (String)readProperty("jobnum");
    }

    public void setName(String name) {
        writeProperty("name", name);
    }
    public String getName() {
        return (String)readProperty("name");
    }

    public void setPhasenum(String phasenum) {
        writeProperty("phasenum", phasenum);
    }
    public String getPhasenum() {
        return (String)readProperty("phasenum");
    }

    public void setSequence(Integer sequence) {
        writeProperty("sequence", sequence);
    }
    public Integer getSequence() {
        return (Integer)readProperty("sequence");
    }

    public void addToCats(Jccat obj) {
        addToManyTarget("cats", obj, true);
    }
    public void removeFromCats(Jccat obj) {
        removeToManyTarget("cats", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Jccat> getCats() {
        return (List<Jccat>)readProperty("cats");
    }


    public void addToDetail(Jcdetail obj) {
        addToManyTarget("detail", obj, true);
    }
    public void removeFromDetail(Jcdetail obj) {
        removeToManyTarget("detail", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Jcdetail> getDetail() {
        return (List<Jcdetail>)readProperty("detail");
    }


    public void setJob(Jcjob job) {
        setToOneTarget("job", job, true);
    }

    public Jcjob getJob() {
        return (Jcjob)readProperty("job");
    }


    public void addToVoucherdist(Apvoucherdist obj) {
        addToManyTarget("voucherdist", obj, true);
    }
    public void removeFromVoucherdist(Apvoucherdist obj) {
        removeToManyTarget("voucherdist", obj, true);
    }
    @SuppressWarnings("unchecked")
    public List<Apvoucherdist> getVoucherdist() {
        return (List<Apvoucherdist>)readProperty("voucherdist");
    }


}
