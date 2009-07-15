package accounting.ce;

import org.apache.cayenne.dba.JdbcAdapter;
import org.apache.cayenne.dba.PkGenerator;
import org.apache.log4j.Logger;

public class CEAdapter extends JdbcAdapter {

	private Logger log = Logger.getLogger(CEAdapter.class);
	
	public CEAdapter() {
		super();
		this.setSupportsFkConstraints(false);
		this.setSupportsGeneratedKeys(false);
		this.setSupportsBatchUpdates(true);
		log.debug("CEAdapter init " + pkGenerator);
	}
	
    protected PkGenerator createPkGenerator() {
        return new CEPkGenerator();
    }
}