package accounting.ce.auto;

import java.sql.Date;

import org.apache.cayenne.CayenneDataObject;

import accounting.ce.Jcchangeorder;

/**
 * Class _Jcchangeorderstep was generated by Cayenne.
 * It is probably a good idea to avoid changing this class manually,
 * since it may be overwritten next time code is regenerated.
 * If you need to make any customizations, please use subclass.
 */
public abstract class _Jcchangeorderstep extends CayenneDataObject {

    public static final String DATE_PROPERTY = "date";
    public static final String JOBNUM_PROPERTY = "jobnum";
    public static final String ORDERNUM_PROPERTY = "ordernum";
    public static final String TYPE_PROPERTY = "type";
    public static final String WHO_PROPERTY = "who";
    public static final String CHANGEORDER_PROPERTY = "changeorder";

    public static final String JOBNUM_PK_COLUMN = "jobnum";
    public static final String ORDERNUM_PK_COLUMN = "ordernum";
    public static final String TYPE_PK_COLUMN = "type";

    public void setDate(Date date) {
        writeProperty("date", date);
    }
    public Date getDate() {
        return (Date)readProperty("date");
    }

    public void setJobnum(String jobnum) {
        writeProperty("jobnum", jobnum);
    }
    public String getJobnum() {
        return (String)readProperty("jobnum");
    }

    public void setOrdernum(String ordernum) {
        writeProperty("ordernum", ordernum);
    }
    public String getOrdernum() {
        return (String)readProperty("ordernum");
    }

    public void setType(Integer type) {
        writeProperty("type", type);
    }
    public Integer getType() {
        return (Integer)readProperty("type");
    }

    public void setWho(String who) {
        writeProperty("who", who);
    }
    public String getWho() {
        return (String)readProperty("who");
    }

    public void setChangeorder(Jcchangeorder changeorder) {
        setToOneTarget("changeorder", changeorder, true);
    }

    public Jcchangeorder getChangeorder() {
        return (Jcchangeorder)readProperty("changeorder");
    }


}
