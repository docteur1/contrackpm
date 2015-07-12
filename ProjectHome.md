# Summary #
Construction project document control and contract management. Written in java intended to run on tomcat on a mysql database. Collaboration with project team members (architects, subcontracts, owners) through the team member website.

### Documents managed and created by Contrack (as PDFs): ###
  * Subcontract and Purchase Order Agreements
    * Lien releases
    * Warranties and Project Closeouts
  * Changes
    * Requests for changes
    * Authorization letters
  * RFIs
  * Submittals
  * Transmittals
  * Project Letters

### Financial: ###
  * Track budgets and costs
  * API to interface with accounting software
    * Interface written for [ComputerEase(TM)](http://www.construction-software.com/index.cfm)
    * Could potential interface with any OBDC/JDBC database
    * Could interface with any SDK (Quickbooks)
  * Invoice routing and approval
  * Subcontractor pay application processing

### Other features: ###
  * LDAP (Active Directory) user database or SQL user database.
  * Hylafax client built in
  * Support for [KlickFileWeb](http://www.klickfile.com/pages/klickfile-web) for document  scanning and archival
  * Asterisk support for click to call phone numbers built in through the Asterisk manager API.
  * Logging and tracing
  * Attachment support

[Email project owner](mailto:gbellsworth@gmail.com) for more information about deploying Contrack at your site or to join the development team.