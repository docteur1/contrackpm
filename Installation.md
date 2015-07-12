## Download Files ##

Download the following files:
  * `contrack.war`
  * `context-sample.xml`
  * `contrack.sql`

Download and install Tomcat 6, a J2SE 5 (or 6 should work but has not been tested), and MySQL 5 (only tested on 5 but not 5.1).

## Database ##

  1. Create a database in MySQL and assign a MySQL user appropriate rights.
  1. Load the database skeleton file `contrack.sql` using the following command `mysql -u username -p password databasename < contrack.sql`. MySQL will print any error messages. It will print none if the command is successful.

## Configure the Web Application ##

  1. Rename `context-sample.xml` to `contrack.xml` (or whatever context path your web application will have relative to the tomcat root) and place in the appropriate folder in your tomcat `conf` directory. (See `deployXML` on http://tomcat.apache.org/tomcat-6.0-doc/config/host.html#Standard%20Implementation).
  1. Open the file and change the settings according to http://tomcat.apache.org/tomcat-6.0-doc/jndi-datasource-examples-howto.html and http://tomcat.apache.org/tomcat-6.0-doc/realm-howto.html. **Note:** if you are using integrated authentication (SQL) you should only have to update the `<Resource>` tag with your database information.
  1. _Active Directory Integration Only_: See http://www.jspwiki.org/wiki/ActiveDirectoryIntegration and the comments in `context-sample.xml` on how to setup integration (or contact the development team).
  1. Download and copy latest stable MySQL JDBC driver and make it available to your server's `lib` directory (this varies great among OSes and flavors of Tomcat so see http://tomcat.apache.org/tomcat-6.0-doc/class-loader-howto.html.
  1. Copy `contrack.war` into your Tomcat installation's `webapps` directory. It may auto deploy according to your server configuration, if not see the Tomcat documentation.

## Log on ##

Check the server logs (again this depends on your tomcat install) for errors. If everything looks good. Open a browser and log into Contrack using the following credentials:
  * User: root
  * Password: password
If all went well you should be able to click on the "Main" menu and select "Administration" at this point you can change the root password (**recommended**) or setup new users and change settings.