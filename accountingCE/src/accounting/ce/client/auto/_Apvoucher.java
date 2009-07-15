package accounting.ce.client.auto;

import java.util.Date;
import java.util.List;

import org.apache.cayenne.PersistentObject;
import org.apache.cayenne.ValueHolder;

import accounting.ce.client.Apcheck;
import accounting.ce.client.Apvoucherdist;
import accounting.ce.client.Vendor;

/**
 * A generated persistent class mapped as "Apvoucher" Cayenne entity. It is a good idea to
 * avoid changing this class manually, since it will be overwritten next time code is
 * regenerated. If you need to make any customizations, put them in a subclass.
 */
public abstract class _Apvoucher extends PersistentObject {

    public static final String AMOUNT_PROPERTY = "amount";
    public static final String DES_PROPERTY = "des";
    public static final String DISCTAKEN_PROPERTY = "disctaken";
    public static final String INVDATE_PROPERTY = "invdate";
    public static final String INVNUM_PROPERTY = "invnum";
    public static final String MEMO_PROPERTY = "memo";
    public static final String PONUM_PROPERTY = "ponum";
    public static final String PTD_PROPERTY = "ptd";
    public static final String RETHELD_PROPERTY = "retheld";
    public static final String VENNAME_PROPERTY = "venname";
    public static final String VENNUM_PROPERTY = "vennum";
    public static final String VOUCHERNUM_PROPERTY = "vouchernum";
    public static final String CHECKS_PROPERTY = "checks";
    public static final String DISTRIBUTION_PROPERTY = "distribution";
    public static final String VENDOR_PROPERTY = "vendor";

    protected Double amount;
    protected String des;
    protected Double disctaken;
    protected Date invdate;
    protected String invnum;
    protected String memo;
    protected String ponum;
    protected Double ptd;
    protected Double retheld;
    protected String venname;
    protected String vennum;
    protected Integer vouchernum;
    protected List<Apcheck> checks;
    protected List<Apvoucherdist> distribution;
    protected ValueHolder vendor;

    public Double getAmount() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "amount", false);
        }

        return amount;
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


    public Date getInvdate() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "invdate", false);
        }

        return invdate;
    }


    public String getInvnum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "invnum", false);
        }

        return invnum;
    }


    public String getMemo() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "memo", false);
        }

        return memo;
    }


    public String getPonum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "ponum", false);
        }

        return ponum;
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


    public String getVenname() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "venname", false);
        }

        return venname;
    }


    public String getVennum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vennum", false);
        }

        return vennum;
    }


    public Integer getVouchernum() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vouchernum", false);
        }

        return vouchernum;
    }


    public List<Apcheck> getChecks() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "checks", true);
        }

        return checks;
    }
    public void addToChecks(Apcheck object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "checks", true);
        }

        this.checks.add(object);
    }
    public void removeFromChecks(Apcheck object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "checks", true);
        }

        this.checks.remove(object);
    }

    public List<Apvoucherdist> getDistribution() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "distribution", true);
        }

        return distribution;
    }
    public void addToDistribution(Apvoucherdist object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "distribution", true);
        }

        this.distribution.add(object);
    }
    public void removeFromDistribution(Apvoucherdist object) {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "distribution", true);
        }

        this.distribution.remove(object);
    }

    public Vendor getVendor() {
        if(objectContext != null) {
            objectContext.prepareForAccess(this, "vendor", true);
        }

        return (Vendor) vendor.getValue();
    }

}
