package com.sinkluge.list;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

public class List {

	private HashMap<Integer, JobInfo> jobList;
	
	public class Contract {
		private String codeDescription;
		private int contactId;

		public int getContactId() {
			return contactId;
		}

		protected void setContactId(int contactId) {
			this.contactId = contactId;
		}

		public String getCodeDescription() {
			return codeDescription;
		}

		protected void setCodeDescription(String codeDescription) {
			this.codeDescription = codeDescription;
		}
	}
	
	
	public class JobInfo {
		private int jobId;
		private String jobName;
		private ArrayList<Contract> contracts;
		protected JobInfo() {
			contracts = new ArrayList<Contract>();
		}
		public String getJobName() {
			return jobName;
		}
		protected void setJobName(String jobName) {
			this.jobName = jobName;
		}
		protected void addContract(int contractId, String codeDescription) {
			Contract c = new Contract();
			c.setCodeDescription(codeDescription);
			c.setContactId(contractId);
			contracts.add(c);
		}
		public Iterator<Contract> getContractIterator() {
			return contracts.iterator();
		}
		public boolean hasContracts() {
			return contracts.size() != 0;
		}
		public int getJobId() {
			return jobId;
		}
		protected void setJobId(int jobId) {
			this.jobId = jobId;
		}
		protected void clear() {
			contracts.clear();
			contracts = null;
		}
		public int getCount() {
			return contracts.size();
		}
	}
	
	public List() {
		jobList = new HashMap<Integer, JobInfo>();
	}
	
	public void addJob(int jobId, String jobName) {
		JobInfo ji = new JobInfo();	
		ji.setJobId(jobId);
		ji.setJobName(jobName);
		jobList.put(jobId, ji);
	}

	public void addContract(int jobId, String jobName, int contractId, String codeDescription) {
		JobInfo ji = jobList.get(jobId);
		if (ji == null) {
			System.out.println("job info is null, creating");
			ji = new JobInfo();
			ji.setJobId(jobId);
			ji.setJobName(jobName);
		}
		ji.addContract(contractId, codeDescription);
		jobList.put(jobId, ji);
	}
	
	public boolean isEmpty() {
		return jobList.isEmpty();
	}
	
	public Iterator<JobInfo> getJobs() {
		return jobList.values().iterator();
	}
	
	public void clear() {
		jobList.clear();
	}
	
}
