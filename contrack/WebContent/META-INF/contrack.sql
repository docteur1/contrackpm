-- MySQL dump 10.11
--
-- Host: localhost    Database: sinkluge
-- ------------------------------------------------------
-- Server version	5.0.83

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `change_orders`
--

DROP TABLE IF EXISTS `change_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `change_orders` (
  `co_id` int(10) unsigned NOT NULL auto_increment,
  `co_num` varchar(45) NOT NULL,
  `job_id` int(10) unsigned NOT NULL,
  `co_description` varchar(255) NOT NULL,
  PRIMARY KEY  (`co_id`),
  UNIQUE KEY `num_unique` (`co_num`,`job_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `change_request_detail`
--

DROP TABLE IF EXISTS `change_request_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `change_request_detail` (
  `crd_id` int(10) unsigned NOT NULL auto_increment,
  `cr_id` int(10) unsigned default NULL,
  `change_auth_num` int(10) unsigned default NULL,
  `job_id` int(10) unsigned NOT NULL,
  `sub_ca_num` int(10) unsigned default NULL,
  `cost_code_id` int(10) unsigned NOT NULL,
  `contract_id` int(10) unsigned NOT NULL,
  `comments` text,
  `work_description` text NOT NULL,
  `authorization` tinyint(1) default NULL,
  `sent_date` date default NULL,
  `fee` double(12,2) NOT NULL,
  `bonds` double(12,2) NOT NULL,
  `amount` double(12,2) NOT NULL,
  `created` date default NULL,
  PRIMARY KEY  (`crd_id`),
  KEY `cr_id` (`cr_id`),
  KEY `cost_code_id` (`cost_code_id`),
  KEY `contract_id` (`contract_id`),
  KEY `sub_ca_unique` (`contract_id`,`sub_ca_num`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `change_requests`
--

DROP TABLE IF EXISTS `change_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `change_requests` (
  `cr_id` int(10) unsigned NOT NULL auto_increment,
  `num` int(10) unsigned NOT NULL,
  `job_id` int(10) unsigned NOT NULL,
  `title` varchar(256) NOT NULL,
  `description` text NOT NULL,
  `date` date NOT NULL,
  `submit_date` date default NULL,
  `approved_date` date default NULL,
  `status` varchar(50) NOT NULL,
  `comments` text,
  `result` varchar(50) NOT NULL,
  `days_added` float NOT NULL,
  `co_id` int(10) unsigned NOT NULL,
  `to_id` int(10) unsigned NOT NULL,
  `signed_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`cr_id`),
  UNIQUE KEY `num_unique` (`num`,`job_id`),
  KEY `co_id` (`co_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `changes`
--

DROP TABLE IF EXISTS `changes`;
/*!50001 DROP VIEW IF EXISTS `changes`*/;
/*!50001 CREATE TABLE `changes` (
  `job_id` int(10) unsigned,
  `cost_code_id` int(10) unsigned,
  `amount` double(19,2),
  `num` bigint(21),
  `fees` double(19,2),
  `bonds` double(19,2)
) ENGINE=MyISAM */;

--
-- Table structure for table `company`
--

DROP TABLE IF EXISTS `company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company` (
  `company_id` int(11) NOT NULL auto_increment,
  `company_name` varchar(100) default NULL,
  `description` varchar(50) default NULL,
  `website` varchar(50) default NULL,
  `federal_id` varchar(50) default NULL,
  `license_number` varchar(50) default NULL,
  `safety_manual` char(1) default 'n',
  `address` varchar(100) default NULL,
  `city` varchar(50) default NULL,
  `state` varchar(25) default NULL,
  `zip` varchar(10) default NULL,
  `phone` varchar(16) default NULL,
  `fax` varchar(16) default NULL,
  `ext_trained` tinyint(1) default '0',
  PRIMARY KEY  (`company_id`),
  UNIQUE KEY `company_name` (`company_name`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_account_ids`
--

DROP TABLE IF EXISTS `company_account_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_account_ids` (
  `company_id` int(10) unsigned NOT NULL,
  `site_id` int(11) NOT NULL,
  `account_id` varchar(15) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `company_comments`
--

DROP TABLE IF EXISTS `company_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_comments` (
  `comment_id` int(10) unsigned NOT NULL auto_increment,
  `company_id` int(10) unsigned default NULL,
  `comment_text` text NOT NULL,
  `strike` tinyint(1) default NULL,
  `user_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`comment_id`),
  KEY `company_id` (`company_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_roles`
--

DROP TABLE IF EXISTS `contact_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_roles` (
  `email` varchar(50) NOT NULL default '',
  `role_name` varchar(20) NOT NULL default 'valid',
  PRIMARY KEY  (`email`,`role_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_users`
--

DROP TABLE IF EXISTS `contact_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_users` (
  `email` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `has_temp_password` tinyint(1) default NULL,
  `font_size` int(10) unsigned default '8',
  PRIMARY KEY  (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contacts` (
  `contact_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default '',
  `title` varchar(50) default '',
  `company_id` int(11) default '0',
  `phone` varchar(16) default '',
  `extension` varchar(16) default '',
  `fax` varchar(16) default '',
  `email` varchar(50) default '',
  `mobile_phone` varchar(16) default '',
  `address` varchar(100) default NULL,
  `city` varchar(32) default '',
  `state` varchar(16) default '',
  `zip` varchar(16) default '',
  `radio_num` varchar(16) default '',
  `pager` varchar(16) default '',
  `comment` text,
  PRIMARY KEY  (`contact_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contracts` (
  `company_id` int(11) default NULL,
  `amount` double default NULL,
  `agreement_date` date default NULL,
  `date_sent` date default NULL,
  `date_received` date default NULL,
  `gen_insurance_expire` date default NULL,
  `workers_comp_expire` date default NULL,
  `submittal_required` char(1) NOT NULL default 'n',
  `lien_waiver` float default NULL,
  `contract_id` int(11) NOT NULL auto_increment,
  `cost_code_id` bigint(20) default NULL,
  `description` text,
  `insurance_proof` char(1) NOT NULL default 'n',
  `workers_comp_proof` char(1) NOT NULL default 'n',
  `req_tech_submittals` char(1) NOT NULL default 'n',
  `have_tech_submittals` char(1) NOT NULL default 'n',
  `req_specialty` varchar(255) default NULL,
  `have_specialty` char(1) NOT NULL default 'n',
  `req_warranty` char(1) NOT NULL default 'n',
  `have_warranty` char(1) NOT NULL default 'n',
  `have_lien_release` char(1) NOT NULL default 'n',
  `req_owner_training` char(1) NOT NULL default 'n',
  `have_owner_training` char(1) NOT NULL default 'n',
  `tracking_notes` text,
  `completed` char(1) NOT NULL default 'n',
  `job_id` int(10) unsigned default NULL,
  `contact_id` int(10) unsigned default NULL,
  `retention_rate` float default '0',
  `altContractId` varchar(10) default NULL,
  PRIMARY KEY  (`contract_id`),
  KEY `cost_code_id` (`cost_code_id`),
  KEY `company_id` (`company_id`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cost_codes`
--

DROP TABLE IF EXISTS `cost_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cost_codes` (
  `code_id` int(10) unsigned NOT NULL auto_increment,
  `division` varchar(15) NOT NULL,
  `cost_code` varchar(15) NOT NULL,
  `cost_type` char(1) NOT NULL,
  `description` varchar(50) NOT NULL,
  `site_id` int(11) NOT NULL,
  PRIMARY KEY  (`code_id`),
  UNIQUE KEY `site_id` (`site_id`,`division`,`cost_code`,`cost_type`),
  UNIQUE KEY `site_id_2` (`site_id`,`division`,`cost_code`,`cost_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cost_types`
--

DROP TABLE IF EXISTS `cost_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cost_types` (
  `letter` char(1) NOT NULL,
  `description` varchar(50) NOT NULL,
  `labor` tinyint(1) default '0',
  `mapping` varchar(10) default NULL,
  `contractable` tinyint(1) default '0',
  `contract` text,
  `contract_title` varchar(50) default NULL,
  `contractee_title` varchar(50) default NULL,
  `site_work` tinyint(1) default '0',
  `site_id` int(11) NOT NULL,
  PRIMARY KEY  (`site_id`,`letter`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `default_permissions`
--

DROP TABLE IF EXISTS `default_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_permissions` (
  `role_name` varchar(50) NOT NULL default '',
  `name` varchar(25) NOT NULL,
  `val` set('DELETE','WRITE','READ','PRINT') default NULL,
  PRIMARY KEY  (`role_name`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `divisions`
--

DROP TABLE IF EXISTS `divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `divisions` (
  `division` varchar(15) NOT NULL,
  `description` varchar(50) NOT NULL default '',
  `site_id` int(11) NOT NULL,
  PRIMARY KEY  (`site_id`,`division`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `error_log`
--

DROP TABLE IF EXISTS `error_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `error_log` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `message` text NOT NULL,
  `comments` text,
  `sent` tinyint(1) NOT NULL default '0',
  `error_time` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ext_sessions`
--

DROP TABLE IF EXISTS `ext_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ext_sessions` (
  `id` varchar(255) NOT NULL default '',
  `name` varchar(255) default NULL,
  `host` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `created` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `closed` tinyint(1) default '0',
  `agent` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fax_log`
--

DROP TABLE IF EXISTS `fax_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fax_log` (
  `fax_log_id` int(11) NOT NULL auto_increment,
  `job_id` varchar(7) NOT NULL default '',
  `fax` varchar(16) default NULL,
  `document` varchar(20) NOT NULL default '',
  `contact_name` varchar(255) default '',
  `company_name` varchar(255) default '',
  `description` varchar(50) default '',
  `status` varchar(255) default NULL,
  `viewed` tinyint(1) default '0',
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`fax_log_id`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `file_id` int(10) unsigned NOT NULL auto_increment,
  `id` varchar(20) NOT NULL default '',
  `type` varchar(4) NOT NULL default '',
  `content_type` varchar(30) NOT NULL default '',
  `file` mediumblob,
  `uploaded_by` varchar(50) NOT NULL default '',
  `uploaded` datetime NOT NULL,
  `description` varchar(100) NOT NULL default '',
  `size` bigint(20) unsigned default NULL,
  `contact_id` int(10) unsigned default NULL,
  `filename` varchar(100) NOT NULL default '',
  `print` tinyint(1) default '0',
  `protected` tinyint(1) default '0',
  `email` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`file_id`),
  KEY `id` (`id`),
  KEY `type` (`type`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job`
--

DROP TABLE IF EXISTS `job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job` (
  `job_num` varchar(15) NOT NULL,
  `job_name` varchar(128) default NULL,
  `start_date` date default NULL,
  `end_date` date default NULL,
  `contract_method` varchar(25) NOT NULL,
  `project_category` varchar(25) NOT NULL,
  `building_size` varchar(25) default NULL,
  `site_size` varchar(25) default NULL,
  `address` varchar(50) default NULL,
  `city` varchar(50) default NULL,
  `state` varchar(16) default NULL,
  `zip` varchar(16) default NULL,
  `builders_risk_ins_expire` date default NULL,
  `phone_one` varchar(16) default NULL,
  `phone_two` varchar(16) default NULL,
  `fax` varchar(16) default NULL,
  `contract_amount_start` float default NULL,
  `contract_amount_end` float default NULL,
  `substantial_completion_date` date default NULL,
  `active` char(1) default NULL,
  `materials_op` float default NULL,
  `extended_support` char(1) default NULL,
  `description` text,
  `bid_documents` text,
  `date_costs_updated` datetime default NULL,
  `submittal_copies` int(11) default NULL,
  `submit_co_to` enum('Architect','Owner') default 'Owner',
  `job_id` int(10) unsigned NOT NULL auto_increment,
  `retention_rate` float default '0.05',
  `site_id` int(11) default '1',
  PRIMARY KEY  (`job_id`),
  UNIQUE KEY `job_num` (`job_num`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_contacts`
--

DROP TABLE IF EXISTS `job_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_contacts` (
  `job_contact_id` int(10) unsigned NOT NULL auto_increment,
  `job_id` int(10) unsigned default NULL,
  `contact_id` int(10) unsigned default NULL,
  `company_id` int(10) unsigned default NULL,
  `type` enum('Contact','Owner','Architect') default NULL,
  `isDefault` tinyint(1) default '0',
  PRIMARY KEY  (`job_contact_id`),
  UNIQUE KEY `job_id` (`job_id`,`contact_id`,`company_id`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_cost_detail`
--

DROP TABLE IF EXISTS `job_cost_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_cost_detail` (
  `cost_code` varchar(15) NOT NULL,
  `code_description` varchar(255) default NULL,
  `comment` varchar(255) default NULL,
  `overhead` char(1) character set utf8 collate utf8_bin default NULL,
  `estimate` float default '0',
  `budget` float default '0',
  `cost_to_complete` float default '0',
  `percent_complete` float default '0',
  `pm_cost_to_date` float default '0',
  `pm_hours_to_date` float default '0',
  `job_id` int(10) unsigned default NULL,
  `cost_code_id` int(10) unsigned NOT NULL auto_increment,
  `phase_code` char(1) NOT NULL,
  `division` varchar(15) NOT NULL,
  `locked` tinyint(1) default '0',
  PRIMARY KEY  (`cost_code_id`),
  UNIQUE KEY `job_id` (`job_id`,`division`,`cost_code`,`phase_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_divisions`
--

DROP TABLE IF EXISTS `job_divisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_divisions` (
  `jd_id` int(10) unsigned NOT NULL auto_increment,
  `job_id` int(10) unsigned NOT NULL,
  `division` varchar(15) NOT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY  (`jd_id`),
  UNIQUE KEY `job_id` (`job_id`,`division`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_permissions`
--

DROP TABLE IF EXISTS `job_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_permissions` (
  `job_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(25) NOT NULL,
  `val` set('DELETE','WRITE','READ','PRINT') default NULL,
  `user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`job_id`,`user_id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_team`
--

DROP TABLE IF EXISTS `job_team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_team` (
  `job_team_id` int(10) unsigned NOT NULL auto_increment,
  `job_id` int(10) unsigned default NULL,
  `name` varchar(100) NOT NULL,
  `role` varchar(25) NOT NULL,
  `mobile` varchar(14) default NULL,
  `email` varchar(50) default NULL,
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`job_team_id`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kf_documents`
--

DROP TABLE IF EXISTS `kf_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kf_documents` (
  `document_id` bigint(20) unsigned NOT NULL,
  `type` char(4) NOT NULL,
  `id` varchar(20) NOT NULL,
  `print` tinyint(1) default NULL,
  `share` tinyint(1) default NULL,
  PRIMARY KEY  (`document_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kfw_links`
--

DROP TABLE IF EXISTS `kfw_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kfw_links` (
  `document_id` bigint(20) unsigned NOT NULL,
  `document_key` varchar(30) NOT NULL,
  `site_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`document_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `letter_contacts`
--

DROP TABLE IF EXISTS `letter_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `letter_contacts` (
  `letter_id` int(11) NOT NULL default '0',
  `contact_id` int(11) NOT NULL default '0',
  `method` enum('Email','Fax','Print') NOT NULL default 'Print',
  `company_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`contact_id`,`letter_id`,`method`,`company_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `letters`
--

DROP TABLE IF EXISTS `letters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `letters` (
  `letter_id` int(11) NOT NULL auto_increment,
  `subject` varchar(255) default NULL,
  `date_created` date default NULL,
  `cc` varchar(255) default NULL,
  `salutation` varchar(50) default NULL,
  `body_text` text,
  `job_id` int(10) unsigned default NULL,
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`letter_id`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lists`
--

DROP TABLE IF EXISTS `lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lists` (
  `id` varchar(25) NOT NULL,
  `val` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`id`,`val`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log`
--

DROP TABLE IF EXISTS `log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log` (
  `log_id` bigint(20) unsigned NOT NULL auto_increment,
  `id` varchar(20) NOT NULL,
  `type` varchar(4) NOT NULL,
  `uid` int(11) NOT NULL,
  `activity` enum('Created','Updated','Faxed','Printed','eSubmited','Read','Opened','Emailed','Deleted') default 'Updated',
  `external` tinyint(1) default '0',
  `to_company_id` int(10) unsigned default NULL,
  `to_contact_id` int(10) unsigned default NULL,
  `comment` varchar(255) default NULL,
  `stamp` datetime default NULL,
  PRIMARY KEY  (`log_id`),
  KEY `id` (`id`,`type`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `owner_pay_requests`
--

DROP TABLE IF EXISTS `owner_pay_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `owner_pay_requests` (
  `opr_id` int(10) unsigned NOT NULL auto_increment,
  `period` varchar(9) NOT NULL default '',
  `paid_by_owner` date default NULL,
  `job_id` int(10) unsigned default NULL,
  `locked` tinyint(1) default NULL,
  PRIMARY KEY  (`opr_id`),
  UNIQUE KEY `job_id` (`job_id`,`period`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pay_requests`
--

DROP TABLE IF EXISTS `pay_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pay_requests` (
  `pr_id` int(10) unsigned NOT NULL auto_increment,
  `opr_id` int(10) unsigned default NULL,
  `contract_id` int(10) unsigned default NULL,
  `request_num` smallint(6) default NULL,
  `date_created` date default NULL,
  `date_approved` date default NULL,
  `date_paid` date default NULL,
  `ref_num` varchar(100) default NULL,
  `internal_comments` varchar(255) default NULL,
  `external_comments` varchar(255) default NULL,
  `ext_created` tinyint(1) default NULL,
  `lien_waiver` enum('Not Required','Requested','Filed') default NULL,
  `account_id` int(10) unsigned default NULL,
  `invoice_num` varchar(70) default NULL,
  `co` float(12,2) default NULL,
  `value_of_work` float(12,2) default NULL,
  `adj_value_of_work` float(12,2) default NULL,
  `previous_billings` float(12,2) default NULL,
  `adj_previous_billings` float(12,2) default NULL,
  `retention` float(12,2) default NULL,
  `adj_retention` float(12,2) default NULL,
  `paid` float(12,2) default NULL,
  `final` tinyint(1) default '0',
  `e_update` tinyint(1) default '0',
  PRIMARY KEY  (`pr_id`),
  UNIQUE KEY `opr_id` (`opr_id`,`contract_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `id` varchar(25) NOT NULL,
  `txt` text NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rfi`
--

DROP TABLE IF EXISTS `rfi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rfi` (
  `rfi_id` int(11) NOT NULL auto_increment,
  `rfi_num` varchar(15) default NULL,
  `company_id` int(11) default NULL,
  `date_created` date default NULL,
  `urgency` enum('Work Stopped','As Soon As Possible','At Next Visit','At Your Convenience') default NULL,
  `respond_by` date default NULL,
  `date_received` date default NULL,
  `request` text,
  `reply` text,
  `job_id` int(10) unsigned default NULL,
  `contact_id` int(10) unsigned default NULL,
  `e_submit` tinyint(1) default '0',
  `e_update` tinyint(1) default '0',
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`rfi_id`),
  KEY `rfi_num` (`rfi_num`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `role_name` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`role_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session_log`
--

DROP TABLE IF EXISTS `session_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session_log` (
  `session_log_id` int(10) unsigned NOT NULL auto_increment,
  `agent` varchar(150) NOT NULL,
  `created` datetime NOT NULL,
  `destroyed` datetime NOT NULL,
  `reason` varchar(50) NOT NULL,
  `host` varchar(255) NOT NULL,
  `user_id` varchar(16) default NULL,
  PRIMARY KEY  (`session_log_id`),
  KEY `user_id` (`user_id`),
  KEY `user_id_2` (`user_id`),
  KEY `user_id_3` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `id` varchar(25) NOT NULL,
  `name` varchar(50) NOT NULL,
  `val` varchar(255) default NULL,
  PRIMARY KEY  (`id`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sites` (
  `site_id` int(10) unsigned NOT NULL auto_increment,
  `site_name` varchar(100) default NULL,
  `logo` mediumblob,
  `def` int(1) default '0',
  `content_type` varchar(150) default NULL,
  PRIMARY KEY  (`site_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `submittal_links`
--

DROP TABLE IF EXISTS `submittal_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `submittal_links` (
  `submittal_id` int(10) unsigned NOT NULL default '0',
  `contract_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`submittal_id`,`contract_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `submittals`
--

DROP TABLE IF EXISTS `submittals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `submittals` (
  `submittal_id` int(11) NOT NULL auto_increment,
  `contract_id` int(10) unsigned NOT NULL default '0',
  `submittal_num` varchar(15) default NULL,
  `attempt` int(11) default NULL,
  `description` text,
  `date_received` date default NULL,
  `date_to_architect` date default NULL,
  `date_from_architect` date default NULL,
  `date_to_sub` date default NULL,
  `submittal_status` varchar(50) default NULL,
  `submittal_type` varchar(50) default NULL,
  `date_created` date default NULL,
  `comment_to_architect` text,
  `comment_to_sub` text,
  `printed_exceptions` text,
  `alt_cost_code` varchar(100) default NULL,
  `architect_id` int(10) unsigned default NULL,
  `job_id` int(10) unsigned default NULL,
  `comment_from_sub` text,
  `architect_stamp` tinyint(1) default '0',
  `e_update` tinyint(1) default '0',
  `e_submit` tinyint(1) default '0',
  `comment_from_architect` text,
  `contractor_stamp` varchar(25) default NULL,
  `cost_code_id` int(10) unsigned NOT NULL default '0',
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`submittal_id`),
  KEY `contract_id` (`contract_id`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `suspense_cache`
--

DROP TABLE IF EXISTS `suspense_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suspense_cache` (
  `sc_id` int(10) unsigned NOT NULL auto_increment,
  `job_id` int(10) unsigned NOT NULL,
  `voucher_id` int(10) unsigned NOT NULL,
  `company` varchar(100) default NULL,
  `po_num` varchar(50) default NULL,
  `invoice_num` varchar(50) default NULL,
  `voucher_date` date default NULL,
  `amount` double(12,2) default NULL,
  `description` varchar(150) default NULL,
  `updated` tinyint(1) default '0',
  PRIMARY KEY  (`sc_id`),
  UNIQUE KEY `voucher_id` (`voucher_id`),
  UNIQUE KEY `voucher_id_2` (`voucher_id`),
  UNIQUE KEY `voucher_id_3` (`voucher_id`),
  UNIQUE KEY `voucher_id_4` (`voucher_id`),
  UNIQUE KEY `voucher_id_5` (`voucher_id`),
  UNIQUE KEY `voucher_id_6` (`voucher_id`),
  KEY `job_id` (`job_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transmittal`
--

DROP TABLE IF EXISTS `transmittal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transmittal` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `job_id` int(10) unsigned NOT NULL default '0',
  `my` tinyint(1) default NULL,
  `company_id` int(10) unsigned default NULL,
  `contact_id` int(10) unsigned default NULL,
  `user` varchar(50) default NULL,
  `attn` varchar(100) default NULL,
  `company_name` varchar(70) default NULL,
  `address` varchar(70) default NULL,
  `city` varchar(40) default NULL,
  `state` varchar(15) default NULL,
  `zip` varchar(15) default NULL,
  `phone` varchar(20) default NULL,
  `fax` varchar(20) default NULL,
  `respond_by` date default NULL,
  `copy_to` varchar(100) default NULL,
  `attachments` enum('Shop Drawings','Specifications','Prints/Plans','Copy Of Letter','Samples','Change Order','None','Other','Submittals') default NULL,
  `description` text,
  `remarks` text,
  `purpose` enum('For Your Approval','Per Your Request','Approved as Submitted','To Be Resubmitted','For Your Use','For Review And Comment','Approved As Noted','Other','None') default NULL,
  `transmittal_status` enum('Response Required','Submittals Processed','Completed') default NULL,
  `pages` int(11) default NULL,
  `created` date default NULL,
  `user_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`),
  KEY `job_id` (`job_id`),
  KEY `company_id` (`company_id`),
  KEY `contact_id` (`contact_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_jobs`
--

DROP TABLE IF EXISTS `user_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_jobs` (
  `job_id` int(10) unsigned NOT NULL default '0',
  `user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`job_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `username` varchar(20) NOT NULL,
  `role_name` varchar(20) NOT NULL,
  PRIMARY KEY  (`username`,`role_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `uid` varchar(32) default NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(50) default NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `email` varchar(50) default NULL,
  `title` varchar(50) default NULL,
  `address` varchar(100) default NULL,
  `city` varchar(36) default NULL,
  `state` varchar(20) default NULL,
  `zip` varchar(16) default NULL,
  `phone` varchar(16) default NULL,
  `ext` varchar(10) default NULL,
  `fax` varchar(16) default NULL,
  `mobile` varchar(16) default NULL,
  `font_size` tinyint(3) unsigned default '8',
  `photo` blob,
  `active` tinyint(1) default '1',
  `radio` varchar(16) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uid` (`uid`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Final view structure for view `changes`
--

/*!50001 DROP TABLE `changes`*/;
/*!50001 DROP VIEW IF EXISTS `changes`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `changes` AS select `jcd`.`job_id` AS `job_id`,`crd`.`cost_code_id` AS `cost_code_id`,sum((`crd`.`amount` * (`cr`.`status` = _utf8'Approved'))) AS `amount`,count(`crd`.`crd_id`) AS `num`,sum((`crd`.`fee` * (`cr`.`status` = _utf8'Approved'))) AS `fees`,sum((`crd`.`bonds` * (`cr`.`status` = _utf8'Approved'))) AS `bonds` from ((`job_cost_detail` `jcd` join `change_request_detail` `crd` on((`jcd`.`cost_code_id` = `crd`.`cost_code_id`))) left join `change_requests` `cr` on((`crd`.`cr_id` = `cr`.`cr_id`))) group by `crd`.`cost_code_id` */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-07-14 23:02:29

/* Contrack specific settings */
insert into settings (id, name, val) values ('job', 'retention_rate', '0.05');
insert into settings (id, name, val) values ('build', 'build', '1002');
insert into settings (id, name, val) values ('site', 'admin_email', 'noreply@contrack');
insert into settings (id, name, val) values ('site', 'admin_groups', 'Administrators');
insert into settings (id, name, val) values ('site', 'alt_ldap_host', null);
insert into settings (id, name, val) values ('site', 'asterisk_context', null);
insert into settings (id, name, val) values('site', 'asterisk_host', null);
insert into settings (id, name, val) values('site', 'asterisk_pass', null);
insert into settings (id, name, val) values('site', 'asterisk_port', null);
insert into settings (id, name, val) values('site', 'asterisk_prefix', null);
insert into settings (id, name, val) values('site', 'asterisk_user', null);
insert into settings (id, name, val) values('site', 'bind_dn', null);
insert into settings (id, name, val) values('site', 'bind_pw', null);
insert into settings (id, name, val) values('site', 'default_group', 'Contrack Users');
insert into settings (id, name, val) values('site', 'external_url', 'http://contrack/');
insert into settings (id, name, val) values('site', 'fax_host', null);
insert into settings (id, name, val) values('site', 'fax_pass', null);
insert into settings (id, name, val) values('site', 'fax_user', null);
insert into settings (id, name, val) values('site', 'key', null);
insert into settings (id, name, val) values('site', 'kf_endpoint', null);
insert into settings (id, name, val) values('site', 'kf_password', null);
insert into settings (id, name, val) values('site', 'kf_username', null);
insert into settings (id, name, val) values('site', 'ldap_host', null);
insert into settings (id, name, val) values('site', 'notify_errors', '1');
insert into settings (id, name, val) values('site', 'pdf_key', 'encrypt');
insert into settings (id, name, val) values('site', 'searchbase', null);
insert into settings (id, name, val) values('site', 'session_timeout_mins', '120'); 
insert into settings (id, name, val) values('site', 'site_url', 'http://contrack/');
insert into settings (id, name, val) values('site', 'smtp_host', 'localhost');
insert into settings (id, name, val) values('site', 'smtp_pass', null);
insert into settings (id, name, val) values('site', 'smtp_user', null);
insert into settings (id, name, val) values('site', 'upload_limit', '4048');
insert into settings (id, name, val) values('site', 'user_class', 'com.sinkluge.sqluser.SQLUser');
insert into settings (id, name, val) values('site1', 'accounting_email', 'accounting@contrack');
insert into settings (id, name, val) values('site1', 'acc_classname', null);
insert into settings (id, name, val) values('site1', 'acc_endpoint', null);
insert into settings (id, name, val) values('site1', 'acc_password', null);
insert into settings (id, name, val) values('site1', 'acc_username', null);
insert into settings (id, name, val) values('site1', 'address', '123 Street');
insert into settings (id, name, val) values('site1', 'city', 'Salt Lake City');
insert into settings (id, name, val) values('site1', 'fax', '(801) 555-1001');
insert into settings (id, name, val) values('site1', 'full_name', 'Jones Construction Company');
insert into settings (id, name, val) values('site1', 'kf_acc_field_check_id', '0');
insert into settings (id, name, val) values('site1', 'kf_acc_field_id', '0');
insert into settings (id, name, val) values('site1', 'kf_acc_field_po_id', '0');
insert into settings (id, name, val) values('site1', 'kf_acc_field_vendor_id', '0');
insert into settings (id, name, val) values('site1', 'kf_acc_pro_field_id', '0');
insert into settings (id, name, val) values('site1', 'kf_company_id', '0');
insert into settings (id, name, val) values('site1', 'kf_config_id', '0');
insert into settings (id, name, val) values('site1', 'kf_proj_field_id', '0');
insert into settings (id, name, val) values('site1', 'kf_update_index', '0');
insert into settings (id, name, val) values('site1', 'phone', '(801) 555-1000');
insert into settings (id, name, val) values('site1', 'short_name', 'Jones Construction');
insert into settings (id, name, val) values('site1', 'state', 'UT');
insert into settings (id, name, val) values('site1', 'url', 'contrack.com');
insert into settings (id, name, val) values('site1', 'zip', '84100');
insert into sites (site_id, site_name, def) values (1, 'Default (DO NOT DELETE)', 1);
insert into default_permissions (role_name, name, val) values ('Contrack Users', 'PROJECT', 'READ');
insert into default_permissions (role_name, name, val) values ('Administrators', 'PROJECT', 'READ');
insert into users (id, username, password, first_name, last_name, font_size, email)
	values (1, 'root', md5('password'), 'Default', 'User', 9, 'root@domain');
insert into user_roles (username, role_name) values ('root', 'Administrators');
insert into user_roles (username, role_name) values ('root', 'Contrack Users');
insert into job (job_num, job_name, start_date, end_date, substantial_completion_date, 
	contract_amount_start, site_id, active) values 
	('TEST', 'TEST', '2000-01-01', '2000-01-01', '2000-01-01', 0, 1, 'y');
CREATE DEFINER=`root`@`localhost` FUNCTION `costorder`(s char(15)) RETURNS char(15) CHARSET utf8 
	return lpad(s, 15,'0');
