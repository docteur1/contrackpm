package accounting.ce;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Collection;
import java.util.Iterator;

import org.apache.cayenne.CayenneException;
import org.apache.cayenne.access.DataNode;
import org.apache.cayenne.access.QueryLogger;
import org.apache.cayenne.dba.JdbcPkGenerator;
import org.apache.cayenne.map.DbAttribute;
import org.apache.cayenne.map.DbEntity;

public class CEPkGenerator extends JdbcPkGenerator {
	
	protected long longPkFromDatabase(DataNode node, DbEntity entity) throws Exception {
	
		String key = null;
		//List pks = entity.getPrimaryKey();
		Collection<DbAttribute> col = entity.getPrimaryKeys();
		DbAttribute a = null;
		if (col != null) {
			if (col.size() == 1) {
				a = col.iterator().next();
				if (a != null) key = a.getName();
			} else {
				for (Iterator<DbAttribute> i = col.iterator(); i.hasNext(); ) {
					a = i.next();
					if (a != null && ("serialnum".equals(a.getName()) || "serial".equals(a.getName()))) {
						key = a.getName();
						break;
					}
				}
			}
		}
		if (key == null) throw new CayenneException("Cannot find a valid PK for: " 
			+ entity.getName());

		String query = "SELECT MAX(" + key + ") FROM " + entity.getName();
        if (QueryLogger.isLoggable()) {
            QueryLogger.logQuery(query, null);
        }

        Connection c = node.getDataSource().getConnection();

        try {
            Statement select = c.createStatement();
            ResultSet rs = select.executeQuery(query);

            if (!rs.next()) {
                throw new CayenneException("PK lookup failed for table: "
                        + entity.getName());
            }

            long nextId = rs.getInt(1) + 1;
            
            rs.close();
            select.close();

            return nextId;
        }
        finally {
            c.close();
        }
    }
}
