package kf;

import org.apache.commons.io.IOUtils;
import org.apache.commons.io.output.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import kf.client.Document;
import kf.client.Documentvalue;
import kf.client.Project;
import kf.client.User;
import kf.client.Workflowreason;
import kf.client.Workflowstep;

import org.apache.cayenne.CayenneContext;
import org.apache.cayenne.CayenneRuntimeException;
import org.apache.cayenne.DataChannel;
import org.apache.cayenne.DataObjectUtils;
import org.apache.cayenne.ObjectId;
import org.apache.cayenne.Persistent;
import org.apache.cayenne.event.EventManager;
import org.apache.cayenne.exp.Expression;
import org.apache.cayenne.exp.ExpressionFactory;
import org.apache.cayenne.query.ObjectIdQuery;
import org.apache.cayenne.query.Query;
import org.apache.cayenne.query.SelectQuery;
import org.apache.cayenne.remote.ClientChannel;
import org.apache.cayenne.remote.hessian.HessianConnection;
import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.log4j.Logger;

import com.caucho.hessian.client.HessianProxyFactory;
import com.sinkluge.Info;
import com.sinkluge.attributes.Attributes;

public class KF {

	private CayenneContext context;
	private String configId;
	private String companyId;
	private String url;
	private String username;
	private String password;
	private Attributes attr;
	private Logger log;
	private HessianConnection connection;
	private HessianProxyFactory hpf;
	
	public KF(Info in, Attributes attr) {
		log = Logger.getLogger(KF.class);
		if (log.isDebugEnabled()) {
			log.debug("Opening connection to: " + in.kf_endpoint);
		}
		url = in.kf_endpoint;
		username = in.kf_username;
		password = in.kf_password;
		hpf = new HessianProxyFactory();
		hpf.setUser(username);
		hpf.setPassword(password);
		if (username != null) connection = new 
				HessianConnection(url + "cayenne-service", username, password, null);
		DataChannel channel = new ClientChannel(connection);
		context = new CayenneContext(channel);
		try {
			configId = attr.get("kf_config_id");
			companyId = attr.get("kf_company_id");
		} catch (NumberFormatException e) {
			log.error("KF mapping fields error", e);
		}
		this.attr = attr;
	}
	
	@SuppressWarnings("unchecked")
	public void prepareForAccess() throws Exception {
		List test = null;
		try {
			SelectQuery query = new SelectQuery(Document.class);
			query.setFetchLimit(1);
			test = context.performQuery(query);
		} catch (CayenneRuntimeException e) {
			DataChannel channel = context.getChannel();
			if (channel instanceof ClientChannel) {
				// Try resetting the channel
				EventManager ev = channel.getEventManager();
				if (ev != null) ev.shutdown();
				connection = new HessianConnection(connection.getUrl(), connection.getUserName(), 
						connection.getPassword(), connection.getSharedSessionName());
				channel = new ClientChannel(connection);
				context = new CayenneContext(channel);
			}
		} finally {
			if (test != null) {
				test.clear();
				test = null;
			}
		}
	}
	
	/**
	 * This is only intended to expose a KF with a different set of <code>Attributes</code>
	 * than are associated with the current session. Usually it would be more appropriate
	 * to use {@link #getKF(HttpSession)}.
	 * @param session Current <code>HttpSession</code>
	 * @return KF from the <code>HttpSession</code> associated with <code>Attributes</code>
	 * 			(<code>siteId</code>) or creates a new one.
	 */
	public static KF getKF(HttpSession session, Attributes attr) throws Exception {
		KF kf = null;
		if (attr != null) {
			kf = getKF(session.getServletContext(), attr);
		}
		return kf;
	}
	

	/**
	 * @param session Current <code>HttpSession</code>
	 * @return KF from the <code>HttpSession</code> or creates a new one.
	 */
	public static KF getKF(HttpSession session) throws Exception {
		Attributes attr = (Attributes) session.getAttribute("attr");
		return getKF(session, attr);
	}
	
	/**
	 * @param sc			<code>ServletContext</code> holding or to hold <code>KF</code> object
	 * @param attr			<code>Attributes</code> (<code>siteId</code>)
	 * @return				<code>KF</code> object associated with the <code>ServletContext</code> and 
	 * 						 	<code>Attributes</code> (<code>siteId</code>)
	 * @throws Exception
	 */
	public static KF getKF(ServletContext sc, Attributes attr) throws Exception {
		KF kf = null;
		kf = (KF) sc.getAttribute("kf" + attr.getSiteId());
		if (kf == null) {
			Info in = (Info) sc.getAttribute("in");
			if (in != null && in.hasKF) {
				kf = new KF(in, attr);
				sc.setAttribute("kf" + attr.getSiteId(), kf);
			}
		} else kf.prepareForAccess();
		return kf;
	}
	
	/**
	 * Returns <code>KF</code> associated with the <code>ServletContext</code> and the siteId.<p>
	 * This creates a <code>Attributes</code> instance so it is more desirable to use 
	 * {@link #getKF(ServletContext, Attributes)} when possible.</p>
	 * @param sc			<code>ServletContext</code> holding or to hold <code>KF</code> object
	 * @param siteId		<code>siteId</code> (<code>Attributes</code>)
	 * @return				<code>KF</code> object associated with the <code>ServletContext</code> and 
	 * 						 	<code>siteId</code>.
	 * @throws Exception
	 */
	public static KF getKF(ServletContext sc, int siteId) throws Exception {
		KF kf = null;
		kf = (KF) sc.getAttribute("kf" + siteId);
		if (kf == null) {
			Info in = (Info) sc.getAttribute("in");
			if (in != null && in.hasKF) {
				Attributes attr = new Attributes(siteId);
				kf = getKF(sc, attr);
			}
		}
		return kf;
	}
	
	@Deprecated
	public void close() {
		// Does nothing now
	}
	
	public void shutdown() {
		log.debug("Cleaning up resources");
		if (attr != null) attr.close();
		attr = null;
		DataChannel channel = context.getChannel();
		if (channel != null) {
			EventManager events = channel.getEventManager();
			if (events != null) events.shutdown();
			channel = null;
		}
		context = null;
	}
	
	public void commit () {
		context.commitChanges();
	}
	
	@SuppressWarnings("unchecked")
	public Persistent createObject(Class c) {
		return (Persistent) context.newObject(c);
	}
	
	@SuppressWarnings("unchecked")
	public Collection getUncommittedObjects() {
		return context.uncommittedObjects();
	}
	
	@SuppressWarnings("unchecked")
	public Iterator getIterator(Class c) {
		return getList(c).iterator();
	}
	
	@SuppressWarnings("unchecked")
	public List getList(Class c) {
		SelectQuery s = new SelectQuery(c);
		return context.performQuery(s);
	}
	
	public Persistent getObject(String object, String key, Object id) {
		return (Persistent) DataObjectUtils.objectForQuery(context, new ObjectIdQuery(
				new ObjectId(object, key, id)));
	}
	
	@SuppressWarnings("unchecked")
	public Iterator<Workflowreason> getWorkflowreasons(boolean complete, Project proj) {
		HashMap map = new HashMap();
		map.put("Type", complete ? "completing" : "sending");
		map.put("ProjectID", proj.getProjectID());
		Expression e = ExpressionFactory.matchAllDbExp(map, Expression.EQUAL_TO);	
		SelectQuery s = new SelectQuery(Workflowreason.class, e);
		return (Iterator<Workflowreason>) context.performQuery(s).iterator();		
	}
	
	@SuppressWarnings("unchecked")
	public Workflowstep getWorkflowstep(String docId) {
		Document doc = (Document) getObject("Document", "DocumentID", docId);
		Workflowstep w = null;
		if (doc != null) {
			if (log.isDebugEnabled()) {
				log.debug("Current doc: " + doc);
				log.debug("Workflowsteps found: " + doc.getWorkflowsteps().size());
			}
			/*Workflowreason app = (Workflowreason) 
				getObject("Workflowreason", "ReasonID", attr.get("kf_app_workflowreason_id"));
			*/
			User user = null;
			for (Iterator i = doc.getWorkflowsteps().iterator(); i.hasNext(); ) {
				w = (Workflowstep) i.next();
				if (!w.getIsStepFinished()) {
					user = w.getToUser();
					if (user.getUserID().toString().equals(attr.get("kf_workflow_user_id"))) /* && 
							w.getReason().equals(app.getReason())) */ {
						return w;
					}
				}
			}
		}
		return null;
	}
	
	@SuppressWarnings("unchecked")
	public List<kf.client.Document> getAccountDocuments(String id, boolean pro) {
		if (log.isDebugEnabled()) {
			log.debug("Looking for account documents with id " + id + " that are protected? " + pro);
			log.debug("using kf_acc_field_id: " + attr.get("kf_acc_field_id") + " from site "
					+ attr.getSiteId());
		}
		HashMap map = new HashMap();
		if (attr == null) log.debug("attr is null... bad");
		map.put("FieldID", attr.get("kf_acc_field_id"));
		map.put("FieldValue", id);
		return getDocuments(map, pro);
	}
	
	@SuppressWarnings("unchecked")
	public List<kf.client.Document> getProjectDocuments(String id) {
		log.debug("Looking for project documents with id " + id);
		HashMap map = new HashMap();
		map.put("FieldID", attr.get("kf_proj_field_id"));
		map.put("FieldValue", id);
		return getDocuments(map, true);
	}
	
	@SuppressWarnings("unchecked")
	public List query (Query q) {
		return context.performQuery(q);
	}
	
	private List<kf.client.Document> getDocuments(Map<String, String> map, boolean pro) {
		Expression e = ExpressionFactory.matchAllDbExp(map, Expression.EQUAL_TO);
		SelectQuery s = new SelectQuery(Documentvalue.class, e);
		List<?> vals = context.performQuery(s);
		List<kf.client.Document> rets = new ArrayList<kf.client.Document>();
		kf.client.Document doc;
		Documentvalue dv = null;
		if (vals != null) {
			if (log.isDebugEnabled()) {
				log.debug("getDocments: found " + vals.size() + " document values");
			}
			for (Iterator<?> i = vals.iterator(); i.hasNext(); ) {
				dv = (Documentvalue) i.next();
				if (dv != null) {
					doc = dv.getDocument();
					if (doc != null) {
						if (pro) rets.add(doc);
						else if (!pro && !isDocumentProtected(doc)) rets.add(doc);
					}
				}
			}
		}
		if (log.isDebugEnabled()) {
			log.debug("Found " + rets.size() + " documents");
		}
		return rets;
	}
	
	@SuppressWarnings("unchecked")
	private boolean isDocumentProtected(kf.client.Document doc) {
		if (doc != null) {
			Map map = new HashMap();
			map.put("FieldID", attr.get("kf_acc_pro_field_id"));
			map.put("DocumentID", doc.getDocumentID());
			Expression e = ExpressionFactory.matchAllDbExp(map, Expression.EQUAL_TO);
			SelectQuery s = new SelectQuery(Documentvalue.class, e);
			List dvs = context.performQuery(s);
			Documentvalue dv;
			if (dvs != null && dvs.size() > 0)	{
				dv = (Documentvalue) dvs.get(0);
				if ("on".equals(dv.getFieldValue())) return true;
				else return false;
			} else return false;
		} else return false;
	}
	
	private kf.client.Document getDocument(String id, boolean acc, boolean pro) throws Exception {
		prepareForAccess();
		kf.client.Document doc = (kf.client.Document) DataObjectUtils.objectForQuery(context, 
				new ObjectIdQuery(new ObjectId("Document", "DocumentID", id)));
		if (acc && !pro && isDocumentProtected(doc)) return null;
		else return doc;		
	}
	
	public ByteArrayOutputStream getAccountDocumentPDF(String id, boolean pro) throws Exception {
		return getDocumentPDF(getDocument(id, true, pro));
	}
	
	public ByteArrayOutputStream getProjectDocumentPDF(String id)
			throws Exception {
		return getDocumentPDF(getDocument(id, true, false));
	}
	
	public BinaryDocument getAccountThumbnail(String id, boolean pro) throws Exception {
		return getThumbnail(getDocument(id, true, pro));
	}
	
	public BinaryDocument getProjectThumbnail(String id)
			throws Exception {
		return getThumbnail(getDocument(id, true, false));
	}
	
	private BinaryDocument getThumbnail(kf.client.Document doc)
			throws Exception {
		return getBinaryContent(doc, "img", "t");
	}
	
	private ByteArrayOutputStream getDocumentPDF(kf.client.Document doc)
			throws Exception {
		BinaryDocument bd = getBinaryContent(doc);
		if (bd != null) return bd.getStream();
		else return null;
	}
	
	private BinaryDocument getBinaryContent(kf.client.Document doc) throws Exception {
		return getBinaryContent(doc, null, null);
	}
	
	private BinaryDocument getBinaryContent(kf.client.Document doc, String param,
			String val)	throws Exception {
		if (doc == null) return null;
		BinaryDocument bd = null;
		HttpClient client = new HttpClient();
        int size = 0;
        client.getState().setCredentials(
            new AuthScope(AuthScope.ANY_HOST, AuthScope.ANY_PORT),
            new UsernamePasswordCredentials(username, password)
        );
        GetMethod get = new GetMethod(url + "document-service");
        if (username != null)  {
        	log.debug("Using username: " + username);
        	get.setDoAuthentication(true);
        }
        InputStream is = null;
        try {
        	int status;
            get.setQueryString("id=" + doc.getDocumentID() + "&config_id="
            	+ configId + "&company_id=" + companyId + (param != null ?
            	"&" + param + "=" + val : ""));
            if (log.isDebugEnabled()) 
            	log.debug("Getting via HTTP: " + url + ": " + 
            			get.getPath() + "?" + get.getQueryString());
    		status = client.executeMethod(get);
    		if (status == 200) {
    			bd = new BinaryDocument();
    			bd.baos = new ByteArrayOutputStream();
    			is = get.getResponseBodyAsStream();
    			size = IOUtils.copy(is, bd.baos);
    			Header header = get.getResponseHeader("Content-Type");
    			bd.contentType = header.getValue();
    		} else log.warn("getDocumentPDF: server returned " + status);
        } catch (IOException e) {
        	log.error(e.getMessage(), e);
        } finally {
            // release any connection resources used by the method
        	try {
        		if (is != null) is.close();
        	} catch (IOException e) {
        		log.warn("Unable to close input stream");
        	}
        	is = null;
            if (get != null) get.releaseConnection();
            get = null;
            client = null;
        }
		if (log.isDebugEnabled() && bd != null) {
			log.debug("getBinaryContent: Returning a " + size/1000 + " KB file");
		}
		return bd;
	}
}
