drop table user_log;
create table users (
	id int unsigned not null auto_increment,
	uid varchar(32),
	username varchar(20) not null,
	password varchar(50),
	first_name varchar(30) not null,
	last_name varchar(30) not null,
	email varchar(50),
	title varchar(50),
	address varchar(100),
	city varchar(36),
	state varchar(20),
	zip varchar(16),
	phone varchar(16),
	ext varchar(10),
	fax varchar (16),
	mobile varchar (16),
	font_size tinyint unsigned default 8,
	photo blob,
	active tinyint(1) default 1,
	primary key (id),
	unique (uid),
	unique (username)
);
alter table users engine = MyISAM;
drop table log;
create table log (
	log_id bigint unsigned not null auto_increment,
	id varchar(20) not null,
	type varchar(4) not null,
	uid int not null,
	activity enum('Created', 'Updated', 'Faxed', 'Printed', 'eSubmited', 'Read', 'Opened', 'Emailed', 'Deleted') default 'Updated',
	external tinyint(1) default 0,
	to_company_id int unsigned,
	to_contact_id int unsigned,
	comment varchar(255),
	stamp datetime,
	primary key (log_id),
	unique u (id, type, activity)
) engine = MyISAM;
update settings set val = "com.sinkluge.ldap.ActiveDirectoryUser" where id = "site" and name = "user_class";
insert ignore into users (username, first_name, last_name) 
	select distinct updated_username, substring_index(updated_by, ' ', 1) as first_name, 
	substring_index(updated_by, ' ', -1) from transmittal where 
	updated_username is not null and updated_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct created_username, substring_index(created_by, ' ', 1) as first_name, 
	substring_index(created_by, ' ', -1) from transmittal where 
	created_username is not null and created_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct updated_username, substring_index(updated_by, ' ', 1) as first_name, 
	substring_index(updated_by, ' ', -1) from change_requests where 
	updated_username is not null and updated_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct created_username, substring_index(created_by, ' ', 1) as first_name, 
	substring_index(created_by, ' ', -1) from change_requests where 
	created_username is not null and created_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct signed_username, substring_index(signed_by, ' ', 1) as first_name, 
	substring_index(created_by, ' ', -1) from change_requests where 
	created_username is not null and created_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct updated_username, substring_index(updated_by, ' ', 1) as first_name, 
	substring_index(updated_by, ' ', -1) from change_request_detail where 
	updated_username is not null and updated_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct created_username, substring_index(created_by, ' ', 1) as first_name, 
	substring_index(created_by, ' ', -1) from change_request_detail where 
	created_username is not null and created_by is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct username, substring_index(fullname, ' ', 1) as first_name, 
	substring_index(fullname, ' ', -1) from company_comments where 
	username is not null and fullname is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct username, substring_index(user, ' ', 1) as first_name, 
	substring_index(user, ' ', -1) from letters where 
	username is not null and user is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct username, substring_index(user, ' ', 1) as first_name, 
	substring_index(user, ' ', -1) from rfi where 
	username is not null and user is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct username, substring_index(user, ' ', 1) as first_name, 
	substring_index(user, ' ', -1) from submittals where 
	username is not null and user is not null;
insert ignore into users (username, first_name, last_name) 
	select distinct username, substring_index(name, ' ', 1) as first_name, 
	substring_index(name, ' ', -1) from job_team where 
	username is not null and name is not null;
alter table transmittal add user_id int unsigned;
alter table transmittal add index(user_id);
update transmittal, users set transmittal.user_id = users.id where transmittal.username = users.username;
alter table change_requests add signed_id int unsigned;
update change_requests, users set change_requests.signed_id = users.id where change_requests.signed_username = users.username;
alter table change_requests modify signed_by varchar(50);
alter table change_requests modify signed_username varchar(20);
alter table submittals add user_id int unsigned;
update submittals, users set submittals.user_id = users.id where submittals.username = users.username;
alter table rfi add user_id int unsigned;
update rfi, users set rfi.user_id = users.id where rfi.username = users.username;
alter table letters add user_id int unsigned;
update letters, users set letters.user_id = users.id where letters.username = users.username;
alter table job_team add user_id int unsigned;
update job_team, users set job_team.user_id = users.id where job_team.username = users.username;
alter table fax_log add user_id int unsigned;
update fax_log, users set fax_log.user_id = users.id where fax_log.username = users.username;
alter table error_log add user_id int unsigned;
update error_log, users set error_log.user_id = users.id where error_log.username = users.username;
truncate table log;
alter table job_permissions add user_id int unsigned;
update job_permissions, users set job_permissions.user_id = users.id where job_permissions.username = users.username;
insert ignore into log (id, type, uid, activity, stamp) select transmittal.id, "TR", users.id, "Created", 
	created from transmittal join users on created_username = users.username;
insert ignore into log (id, type, uid, activity, stamp) select transmittal.id, "TR", users.id, "Updated",
	updated from transmittal join users on updated_username = users.username where updated != null;
insert ignore into log (id, type, uid, activity, stamp) select cr_id, "CR", users.id, "Created", 
	created from change_requests join users on created_username = users.username;
insert ignore into log (id, type, uid, activity, stamp) select cr_id, "CR", users.id, "Updated",
	updated from change_requests join users on updated_username = users.username where updated is not null;
insert ignore into log (id, type, uid, activity, stamp) select crd_id, "CD", users.id, "Created", 
	created from change_request_detail join users on created_username = users.username created is not null;
insert ignore into log (id, type, uid, activity, stamp) select cr_id, "CD", users.id, "Updated",
	updated from change_request_detail join users on updated_username = users.username where updated is not null;
insert ignore into log (id, type, uid, activity, stamp) select comment_id, "CC", users.id, "Updated",
	updated from company_comments join users on company_comments.username = users.username;
insert ignore into log (id, type, uid, activity, stamp) select letter_id, "LT", users.id, "Created",
	date_created from letters join users on letters.user_id = users.id;
insert ignore into log (id, type, uid, activity, stamp) select rfi_id, "RF", users.id, "Created",
	date_created from rfi join users on rfi.user_id = users.id;
insert ignore into log (id, type, uid, activity, stamp) select submittal_id, "SL", users.id, "Created",
	date_created from submittals join users on submittals.user_id = users.id;
insert ignore into log (id, type, external, uid, activity, stamp) select pr_id, "PR", ext_created, 0, "Created",
	date_created from pay_requests;
alter table log drop index u;
alter table log add index(id, type);
insert ignore into log (id, type, external, uid, activity, stamp) select pr_id, "PR", 0, 0, "Updated",
	int_modified from pay_requests where int_modified is not null;
insert ignore into log (id, type, external, uid, activity, stamp) select pr_id, "PR", 1, contacts.contact_id, "Updated",
	ext_modified from pay_requests join contracts using (contract_id) join contacts on contracts.company_id =
	contacts.company_id and contacts.name = pay_requests.ext_mod_by where ext_modified is not null;
update log set external = 0 where external is null;
delete from settings where id = "site" and name = "live_support_url";
delete from settings where id = "site" and name = "live_support_workgroup";
delete from settings where id = "site" and name = "local_area_code";
delete from settings where name = "kf_suspense_div";
delete from settings where name = "kf_suspense_code";
delete from settings where name like "%workflow%";
insert ignore into settings (id, name, val) select concat("ce", site_id),
	"route", "CONTRACK" from sites;
alter table company_comments modify username varchar(25);
alter table company_comments modify fullname varchar(25);
alter table job_permissions drop primary key;
alter table job_permissions modify username varchar(25);
alter table job_permissions drop user_id;
alter table job_permissions add user_id int unsigned not null;
update job_permissions, users set job_permissions.user_id = users.id where 
	job_permissions.username = users.username;
alter table job_permissions add primary key (job_id, user_id, name);
alter table user_jobs add user_id int unsigned not null;
alter table user_jobs modify username varchar(25);
alter table user_jobs drop primary key;
update user_jobs, users set user_jobs.user_id = users.id where 
	user_jobs.username = users.username;
delete from user_jobs where user_id = 0;
alter table user_jobs add primary key(job_id, user_id);
alter table suspense_cache drop index document_id;
alter table suspense_cache drop document_id;
alter table suspense_cache drop protected;
alter table suspense_cache add unique (voucher_id);
alter table suspense_cache drop action_needed;
drop table kfw_documents;
drop table kfw_links
create table kfw_links (
	document_id bigint unsigned not null,
	document_key varchar(30) not null,
	site_id int unsigned not null,
	primary key (document_id)
);
insert ignore into settings (id, name, val) values ("site", "site_url", "http://contrack.e-p.com/");
alter table files drop username;