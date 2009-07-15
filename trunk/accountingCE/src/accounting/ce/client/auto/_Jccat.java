package accounting.ce.client.auto;

import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Apvoucherdist;
import accounting.ce.client.Jcdetail;
import accounting.ce.client.Jcjob;
import accounting.ce.client.Jcphase;

/**
 * A generated persistent class mapped as "Jccat" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Jccat extends PersistentObject {

    public static final String BUDGET0AMOUNT_PROPERTY = "budget0Amount";
    public static final String BUDGET0HOURS_PROPERTY = "budget0Hours";
    public static final String BUDGET10AMOUNT_PROPERTY = "budget10Amount";
    public static final String BUDGET10HOURS_PROPERTY = "budget10Hours";
    public static final String BUDGET11AMOUNT_PROPERTY = "budget11Amount";
    public static final String BUDGET11HOURS_PROPERTY = "budget11Hours";
    public static final String BUDGET12AMOUNT_PROPERTY = "budget12Amount";
    public static final String BUDGET12HOURS_PROPERTY = "budget12Hours";
    public static final String BUDGET13AMOUNT_PROPERTY = "budget13Amount";
    public static final String BUDGET13HOURS_PROPERTY = "budget13Hours";
    public static final String BUDGET14AMOUNT_PROPERTY = "budget14Amount";
    public static final String BUDGET14HOURS_PROPERTY = "budget14Hours";
    public static final String BUDGET15AMOUNT_PROPERTY = "budget15Amount";
    public static final String BUDGET15HOURS_PROPERTY = "budget15Hours";
    public static final String BUDGET16AMOUNT_PROPERTY = "budget16Amount";
    public static final String BUDGET16HOURS_PROPERTY = "budget16Hours";
    public static final String BUDGET1AMOUNT_PROPERTY = "budget1Amount";
    public static final String BUDGET1HOURS_PROPERTY = "budget1Hours";
    public static final String BUDGET2AMOUNT_PROPERTY = "budget2Amount";
    public static final String BUDGET2HOURS_PROPERTY = "budget2Hours";
    public static final String BUDGET3AMOUNT_PROPERTY = "budget3Amount";
    public static final String BUDGET3HOURS_PROPERTY = "budget3Hours";
    public static final String BUDGET4AMOUNT_PROPERTY = "budget4Amount";
    public static final String BUDGET4HOURS_PROPERTY = "budget4Hours";
    public static final String BUDGET5AMOUNT_PROPERTY = "budget5Amount";
    public static final String BUDGET5HOURS_PROPERTY = "budget5Hours";
    public static final String BUDGET6AMOUNT_PROPERTY = "budget6Amount";
    public static final String BUDGET6HOURS_PROPERTY = "budget6Hours";
    public static final String BUDGET7AMOUNT_PROPERTY = "budget7Amount";
    public static final String BUDGET7HOURS_PROPERTY = "budget7Hours";
    public static final String BUDGET8AMOUNT_PROPERTY = "budget8Amount";
    public static final String BUDGET8HOURS_PROPERTY = "budget8Hours";
    public static final String BUDGET9AMOUNT_PROPERTY = "budget9Amount";
    public static final String BUDGET9HOURS_PROPERTY = "budget9Hours";
    public static final String CATNUM_PROPERTY = "catnum";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String NAME_PROPERTY = "name";
    public static final String PHASENUM_PROPERTY = "phasenum";
    public static final String SEQUENCE_PROPERTY = "sequence";
    public static final String DETAIL_PROPERTY = "detail";
    public static final String JOB_PROPERTY = "job";
    public static final String PHASE_PROPERTY = "phase";
    public static final String VOUCHERDIST_PROPERTY = "voucherdist";

    protected Double budget0Amount;
    protected Double budget0Hours;
    protected Double budget10Amount;
    protected Double budget10Hours;
    protected Double budget11Amount;
    protected Double budget11Hours;
    protected Double budget12Amount;
    protected Double budget12Hours;
    protected Double budget13Amount;
    protected Double budget13Hours;
    protected Double budget14Amount;
    protected Double budget14Hours;
    protected Double budget15Amount;
    protected Double budget15Hours;
    protected Double budget16Amount;
    protected Double budget16Hours;
    protected Double budget1Amount;
    protected Double budget1Hours;
    protected Double budget2Amount;
    protected Double budget2Hours;
    protected Double budget3Amount;
    protected Double budget3Hours;
    protected Double budget4Amount;
    protected Double budget4Hours;
    protected Double budget5Amount;
    protected Double budget5Hours;
    protected Double budget6Amount;
    protected Double budget6Hours;
    protected Double budget7Amount;
    protected Double budget7Hours;
    protected Double budget8Amount;
    protected Double budget8Hours;
    protected Double budget9Amount;
    protected Double budget9Hours;
    protected String catnum;
    protected String jobnum;
    protected String name;
    protected String phasenum;
    protected Integer sequence;
    protected List<Jcdetail> detail;
    protected ValueHolder job;
    protected ValueHolder phase;
    protected List<Apvoucherdist> voucherdist;

    public Double getBudget0Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget0Amount", false);
        }

        return budget0Amount;
    }
    public void setBudget0Amount(Double budget0Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget0Amount", false);
        }

        Object oldValue = this.budget0Amount;
        this.budget0Amount = budget0Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget0Amount", oldValue, budget0Amount);
        }
    }


    public Double getBudget0Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget0Hours", false);
        }

        return budget0Hours;
    }
    public void setBudget0Hours(Double budget0Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget0Hours", false);
        }

        Object oldValue = this.budget0Hours;
        this.budget0Hours = budget0Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget0Hours", oldValue, budget0Hours);
        }
    }


    public Double getBudget10Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget10Amount", false);
        }

        return budget10Amount;
    }
    public void setBudget10Amount(Double budget10Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget10Amount", false);
        }

        Object oldValue = this.budget10Amount;
        this.budget10Amount = budget10Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget10Amount", oldValue, budget10Amount);
        }
    }


    public Double getBudget10Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget10Hours", false);
        }

        return budget10Hours;
    }
    public void setBudget10Hours(Double budget10Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget10Hours", false);
        }

        Object oldValue = this.budget10Hours;
        this.budget10Hours = budget10Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget10Hours", oldValue, budget10Hours);
        }
    }


    public Double getBudget11Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget11Amount", false);
        }

        return budget11Amount;
    }
    public void setBudget11Amount(Double budget11Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget11Amount", false);
        }

        Object oldValue = this.budget11Amount;
        this.budget11Amount = budget11Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget11Amount", oldValue, budget11Amount);
        }
    }


    public Double getBudget11Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget11Hours", false);
        }

        return budget11Hours;
    }
    public void setBudget11Hours(Double budget11Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget11Hours", false);
        }

        Object oldValue = this.budget11Hours;
        this.budget11Hours = budget11Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget11Hours", oldValue, budget11Hours);
        }
    }


    public Double getBudget12Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget12Amount", false);
        }

        return budget12Amount;
    }
    public void setBudget12Amount(Double budget12Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget12Amount", false);
        }

        Object oldValue = this.budget12Amount;
        this.budget12Amount = budget12Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget12Amount", oldValue, budget12Amount);
        }
    }


    public Double getBudget12Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget12Hours", false);
        }

        return budget12Hours;
    }
    public void setBudget12Hours(Double budget12Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget12Hours", false);
        }

        Object oldValue = this.budget12Hours;
        this.budget12Hours = budget12Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget12Hours", oldValue, budget12Hours);
        }
    }


    public Double getBudget13Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget13Amount", false);
        }

        return budget13Amount;
    }
    public void setBudget13Amount(Double budget13Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget13Amount", false);
        }

        Object oldValue = this.budget13Amount;
        this.budget13Amount = budget13Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget13Amount", oldValue, budget13Amount);
        }
    }


    public Double getBudget13Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget13Hours", false);
        }

        return budget13Hours;
    }
    public void setBudget13Hours(Double budget13Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget13Hours", false);
        }

        Object oldValue = this.budget13Hours;
        this.budget13Hours = budget13Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget13Hours", oldValue, budget13Hours);
        }
    }


    public Double getBudget14Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget14Amount", false);
        }

        return budget14Amount;
    }
    public void setBudget14Amount(Double budget14Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget14Amount", false);
        }

        Object oldValue = this.budget14Amount;
        this.budget14Amount = budget14Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget14Amount", oldValue, budget14Amount);
        }
    }


    public Double getBudget14Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget14Hours", false);
        }

        return budget14Hours;
    }
    public void setBudget14Hours(Double budget14Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget14Hours", false);
        }

        Object oldValue = this.budget14Hours;
        this.budget14Hours = budget14Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget14Hours", oldValue, budget14Hours);
        }
    }


    public Double getBudget15Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget15Amount", false);
        }

        return budget15Amount;
    }
    public void setBudget15Amount(Double budget15Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget15Amount", false);
        }

        Object oldValue = this.budget15Amount;
        this.budget15Amount = budget15Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget15Amount", oldValue, budget15Amount);
        }
    }


    public Double getBudget15Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget15Hours", false);
        }

        return budget15Hours;
    }
    public void setBudget15Hours(Double budget15Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget15Hours", false);
        }

        Object oldValue = this.budget15Hours;
        this.budget15Hours = budget15Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget15Hours", oldValue, budget15Hours);
        }
    }


    public Double getBudget16Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget16Amount", false);
        }

        return budget16Amount;
    }
    public void setBudget16Amount(Double budget16Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget16Amount", false);
        }

        Object oldValue = this.budget16Amount;
        this.budget16Amount = budget16Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget16Amount", oldValue, budget16Amount);
        }
    }


    public Double getBudget16Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget16Hours", false);
        }

        return budget16Hours;
    }
    public void setBudget16Hours(Double budget16Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget16Hours", false);
        }

        Object oldValue = this.budget16Hours;
        this.budget16Hours = budget16Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget16Hours", oldValue, budget16Hours);
        }
    }


    public Double getBudget1Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget1Amount", false);
        }

        return budget1Amount;
    }
    public void setBudget1Amount(Double budget1Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget1Amount", false);
        }

        Object oldValue = this.budget1Amount;
        this.budget1Amount = budget1Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget1Amount", oldValue, budget1Amount);
        }
    }


    public Double getBudget1Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget1Hours", false);
        }

        return budget1Hours;
    }
    public void setBudget1Hours(Double budget1Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget1Hours", false);
        }

        Object oldValue = this.budget1Hours;
        this.budget1Hours = budget1Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget1Hours", oldValue, budget1Hours);
        }
    }


    public Double getBudget2Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget2Amount", false);
        }

        return budget2Amount;
    }
    public void setBudget2Amount(Double budget2Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget2Amount", false);
        }

        Object oldValue = this.budget2Amount;
        this.budget2Amount = budget2Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget2Amount", oldValue, budget2Amount);
        }
    }


    public Double getBudget2Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget2Hours", false);
        }

        return budget2Hours;
    }
    public void setBudget2Hours(Double budget2Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget2Hours", false);
        }

        Object oldValue = this.budget2Hours;
        this.budget2Hours = budget2Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget2Hours", oldValue, budget2Hours);
        }
    }


    public Double getBudget3Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget3Amount", false);
        }

        return budget3Amount;
    }
    public void setBudget3Amount(Double budget3Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget3Amount", false);
        }

        Object oldValue = this.budget3Amount;
        this.budget3Amount = budget3Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget3Amount", oldValue, budget3Amount);
        }
    }


    public Double getBudget3Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget3Hours", false);
        }

        return budget3Hours;
    }
    public void setBudget3Hours(Double budget3Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget3Hours", false);
        }

        Object oldValue = this.budget3Hours;
        this.budget3Hours = budget3Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget3Hours", oldValue, budget3Hours);
        }
    }


    public Double getBudget4Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget4Amount", false);
        }

        return budget4Amount;
    }
    public void setBudget4Amount(Double budget4Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget4Amount", false);
        }

        Object oldValue = this.budget4Amount;
        this.budget4Amount = budget4Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget4Amount", oldValue, budget4Amount);
        }
    }


    public Double getBudget4Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget4Hours", false);
        }

        return budget4Hours;
    }
    public void setBudget4Hours(Double budget4Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget4Hours", false);
        }

        Object oldValue = this.budget4Hours;
        this.budget4Hours = budget4Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget4Hours", oldValue, budget4Hours);
        }
    }


    public Double getBudget5Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget5Amount", false);
        }

        return budget5Amount;
    }
    public void setBudget5Amount(Double budget5Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget5Amount", false);
        }

        Object oldValue = this.budget5Amount;
        this.budget5Amount = budget5Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget5Amount", oldValue, budget5Amount);
        }
    }


    public Double getBudget5Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget5Hours", false);
        }

        return budget5Hours;
    }
    public void setBudget5Hours(Double budget5Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget5Hours", false);
        }

        Object oldValue = this.budget5Hours;
        this.budget5Hours = budget5Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget5Hours", oldValue, budget5Hours);
        }
    }


    public Double getBudget6Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget6Amount", false);
        }

        return budget6Amount;
    }
    public void setBudget6Amount(Double budget6Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget6Amount", false);
        }

        Object oldValue = this.budget6Amount;
        this.budget6Amount = budget6Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget6Amount", oldValue, budget6Amount);
        }
    }


    public Double getBudget6Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget6Hours", false);
        }

        return budget6Hours;
    }
    public void setBudget6Hours(Double budget6Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget6Hours", false);
        }

        Object oldValue = this.budget6Hours;
        this.budget6Hours = budget6Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget6Hours", oldValue, budget6Hours);
        }
    }


    public Double getBudget7Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget7Amount", false);
        }

        return budget7Amount;
    }
    public void setBudget7Amount(Double budget7Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget7Amount", false);
        }

        Object oldValue = this.budget7Amount;
        this.budget7Amount = budget7Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget7Amount", oldValue, budget7Amount);
        }
    }


    public Double getBudget7Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget7Hours", false);
        }

        return budget7Hours;
    }
    public void setBudget7Hours(Double budget7Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget7Hours", false);
        }

        Object oldValue = this.budget7Hours;
        this.budget7Hours = budget7Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget7Hours", oldValue, budget7Hours);
        }
    }


    public Double getBudget8Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget8Amount", false);
        }

        return budget8Amount;
    }
    public void setBudget8Amount(Double budget8Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget8Amount", false);
        }

        Object oldValue = this.budget8Amount;
        this.budget8Amount = budget8Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget8Amount", oldValue, budget8Amount);
        }
    }


    public Double getBudget8Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget8Hours", false);
        }

        return budget8Hours;
    }
    public void setBudget8Hours(Double budget8Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget8Hours", false);
        }

        Object oldValue = this.budget8Hours;
        this.budget8Hours = budget8Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget8Hours", oldValue, budget8Hours);
        }
    }


    public Double getBudget9Amount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget9Amount", false);
        }

        return budget9Amount;
    }
    public void setBudget9Amount(Double budget9Amount) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget9Amount", false);
        }

        Object oldValue = this.budget9Amount;
        this.budget9Amount = budget9Amount;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget9Amount", oldValue, budget9Amount);
        }
    }


    public Double getBudget9Hours() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget9Hours", false);
        }

        return budget9Hours;
    }
    public void setBudget9Hours(Double budget9Hours) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "budget9Hours", false);
        }

        Object oldValue = this.budget9Hours;
        this.budget9Hours = budget9Hours;

        // notify objectContext about simple property change
        if(objectContext != null) {
            objectContext.propertyChanged(this, "budget9Hours", oldValue, budget9Hours);
        }
    }


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
