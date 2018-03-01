#
# Copyright (c) 2011-2017 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
####################################################
# Upgrade testing script for Debian 5. Here is how to use it 
# 
# 1. Start a cloud server on Rackspace
#       - Name the server "debian-test-01"
# 2. Log in as the root user (password will come email)
# 3. Run the commands below.   
#    - There are 6 or 7 steps. 
#    - For Steps 1->4 and 6 Simply cut and paste the commands between line that says 
#        ####### -- Step 1 Cut and paste from here  
#        and 
#        ####### -- to here
#    - Do not cut and paste all the commands as some of the commands require user import 
#    - and thus will cause some or all commands afterward to fail.  Remember this is fast, not elegant 
# 
# Once you are done with Step 6, you can start testing. All the pertinent commands are 
# at the bottom of these document. 
# 
# NOTE: Remember to delete the server when you are done. We get charged for every hour of use.
####################################################

####### -- Step 1 Cut and paste from here 
# Make directories 
mkdir /labkey
mkdir /labkey/src
mkdir /labkey/src/labkey 
mkdir /labkey/apps

# Other 
useradd -m tomcat

# Install some software 
cat "deb http://backports.debian.org/debian-backports lenny-backports main" >> /etc/apt/sources.list
apt-get update 
apt-get -t lenny-backports install postgresql-8.4 postgresql-client-8.4 less 

####### -- to here 

####### Step 2: cut and paste from here 

# Install java 
apt-get install sun-java6-jdk

####### --- to here 

####### --- Step 3: cut and paste from here 
# Get and install tomcat 
cd /labkey/src/
wget http://archive.apache.org/dist/tomcat/tomcat-5/v5.5.29/bin/apache-tomcat-5.5.29.tar.gz
wget http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.26/bin/apache-tomcat-6.0.26.tar.gz

cd /labkey/apps
tar xzf /labkey/src/apache-tomcat-5.5.29.tar.gz
tar xzf /labkey/src/apache-tomcat-6.0.26.tar.gz

# Get LabKey distribution and backup files to test the upgrade 
# The testing will be an upgrade from the 10.3 branch. This will be grapped from 
# same location as the backup files 
cd /labkey/src/labkey
wget https://www.labkey.org/Login/Internal/login.post --post-data "email=lkreader@labkey.com&password=xxxxxxxxx" --save-cookies cookies.cpas --keep-session-cookies
wget https://www.labkey.org/_webdav/Internal/Staff/bconn/testing/%40files/10.3/hosted_adaptive_files-20110120.tar.gz --load-cookies cookies.cpas
wget https://www.labkey.org/_webdav/Internal/Staff/bconn/testing/%40files/10.3/LabKey10.3-15363-LabkeyOrg-bin.tar.gz --load-cookies cookies.cpas
wget https://www.labkey.org/_webdav/Internal/Staff/bconn/testing/%40files/10.3/postgres_testdatabase-20110120.bak --load-cookies cookies.cpas
wget https://www.labkey.org/_webdav/Internal/Staff/bconn/testing/%40files/10.3/ROOT.xml --load-cookies cookies.cpas
wget https://www.labkey.org/_webdav/Internal/Staff/bconn/testing/%40files/10.3/pg_hba.conf --load-cookies cookies.cpas
rm -f cookies.cpas

# Set environment variables for testing 
# Assume you will start testing with 5.5
ln -s /labkey/apps/apache-tomcat-5.5.29 /labkey/apps/tomcat
export CATALINA_HOME=/labkey/apps/tomcat
export JAVA_HOME=/usr/lib64/jvm/java-6-sun/

# Extract the LabKey files 
# NOTE: The backup database and files assume that the site-wide file root is /labkey/labkey_adaptive/files
cd /labkey
mkdir /labkey/labkey
mkdir /labkey/labkey/files
cd labkey/files
tar xzf /labkey/src/labkey/hosted_adaptive_files-20110120.tar.gz

# Copy the jar files to catalina_home
cp /labkey/src/labkey/ROOT.xml /labkey/apps/apache-tomcat-5.5.29/conf/Catalina/localhost
mkdir /labkey/apps/apache-tomcat-6.0.26/conf/Catalina/
mkdir /labkey/apps/apache-tomcat-6.0.26/conf/Catalina/localhost
cp /labkey/src/labkey/ROOT.xml /labkey/apps/apache-tomcat-6.0.26/conf/Catalina/localhost

####### -- to here 

####### --Step 5: perform the postgres configuration below by hand. 
echo " You will need to perform the backup by hand.  Here are the commands to run at another prompt "
echo " "
echo "      su - postgres "
echo "      createuser -s -P labkey "
echo "          Set the password to be 'LabKey789' "
echo "      createdb labkey "
echo "      pg_restore -d labkey --format=c /labkey/src/labkey/postgres_testdatabase-20110120.bak "
echo "      exit  "
echo ""
echo "      and then restart the postgres server using /etc/init.d/postgresql restart "
echo " "
echo " Hit the enter key when you have completed the restore using the command above"
read -p "  " read_variable

####### -- to here

####### -- Step 6: cut and paste from here 

# Install Previous Version of LabKey that I will use to test. 
cd /labkey/src/labkey 
tar xzf LabKey10.3-15363-LabkeyOrg-bin.tar.gz
cd LabKey10.3-15363-LabkeyOrg-bin
cp -R bin /labkey/labkey
cp -R modules /labkey/labkey
cp -R labkeywebapp /labkey/labkey
cp -R pipeline-lib /labkey/labkey

# Setup tomcat 6.0
cp -f tomcat-lib/*.jar /labkey/apps/apache-tomcat-6.0.26/lib
cp -f tomcat-lib/*.jar /labkey/apps/apache-tomcat-6.0.26/lib

# Start the server running tomcat 5.5 
/labkey/apps/tomcat/bin/startup.sh 

###### -- to here 

####################################################
####################################################
# Perform the Testing 
####################################################
####################################################

# Test with 5.5 
upgrade.sh -l /labkey/labkey -d /labkey/src/labkey/LabKey10.3-15363-LabkeyOrg-bin -c /labkey/apps/tomcat/ --catalina

# Setup tomcat 6.x.x for testing 
/labkey/apps/tomcat/bin/shutdown.sh 
rm -f /labkey/apps/tomcat
ln -s /labkey/apps/apache-tomcat-6.0.26 /labkey/apps/tomcat
/labkey/apps/tomcat/bin/startup.sh

# Perform the upgrade test 
upgrade.sh -l /labkey/labkey -d /labkey/src/labkey/LabKey10.3-15363-LabkeyOrg-bin -c /labkey/apps/tomcat/ --catalina -n 6.0