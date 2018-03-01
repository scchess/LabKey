#
# Cookbook Name:: tomcat
# Recipe:: default
#
#
# This recipe will install Tomcat 5.5.29 for use with a LabKey Server 
#
#############################################
#
# DO NOT USE THIS RECIPE. TOMCAT 5.5 HAS BEEN END-OF-LIFE-ED.
#
##############################################


# Install required packages 
package "autoconf"

# Ensure that download directory is created
directory "/labkey/src"  do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if {File.exists?("/labkey/src")}
end

# Download Tomcat
remote_file "/labkey/src/apache-tomcat-5.5.29.tar.gz" do
  source "http://archive.apache.org/dist/tomcat/tomcat-5/v5.5.29/bin/apache-tomcat-5.5.29.tar.gz"
  mode "0755"
  owner"root"
  group "root"
end

# Unzip and move the files to the correct place 
script "install-tomcat"  do
  interpreter "bash"
  user "root"
  cwd "/labkey/apps"
  code <<-EOH
  tar -xzf /labkey/src/apache-tomcat-5.5.29.tar.gz
  ln -s /labkey/apps/apache-tomcat-5.5.29 /labkey/apps/tomcat
  chown -R tomcat.tomcat /labkey/apps/tomcat/
  chown -R tomcat.tomcat /labkey/apps/apache-tomcat-5.5.29
  EOH
  not_if {File.exists?("/labkey/apps/tomcat/LICENSE")}
end

# Delete the sample and management apps 
directory "/labkey/apps/tomcat/webapps/balancer"  do
  recursive true
  action :delete
end
directory "/labkey/apps/tomcat/webapps/jsp-examples"  do
  recursive true
  action :delete
end
directory "/labkey/apps/tomcat/webapps/servlets-examples"  do
  recursive true
  action :delete
end
directory "/labkey/apps/tomcat/webapps/tomcat-docs"  do
  recursive true
  action :delete
end
file "/labkey/apps/tomcat/conf/Catalina/localhost/manager.xml"  do
  action :delete
end
file "/labkey/apps/tomcat/conf/Catalina/localhost/host-manager.xml"  do
  action :delete
end

# Install configuration files 
# 

# Default setting is to not to use SSL. If you want to use SSL, you need to specify it in the JSON file.
remote_file "/labkey/apps/tomcat/conf/server.xml" do
  case node[:tomcat][:ssl]
  when "true"
    source "server-ssl.xml"
  else
    source "server.xml"
  end
  mode "0700"
  owner"tomcat"
  group "tomcat"
end
remote_file "/labkey/apps/tomcat/conf/web.xml" do
  source "web.xml"
  mode "0700"
  owner"tomcat"
  group "tomcat"
end
template "/etc/init.d/tomcat" do
  case node[:tomcat][:debug]
  when "true"
    source "tomcat-debug.initscript.erb"
  else
    source "tomcat.initscript.erb"
  end
  mode "0755"
  owner"tomcat"
  group "tomcat"
end

# Create new TMP directory which will house the search indexes 
directory "/labkey/tomcat-tmp"  do
  owner "tomcat"
  group "tomcat"
  mode "0700"
  action :create
  not_if {File.exists?("/labkey/tomcat-tmp")}
end


# Generate Self Signed Certificate 
directory "/labkey/apps/tomcat/SSL"  do
  owner "tomcat"
  group "tomcat"
  mode "0700"
  action :create
  not_if {File.exists?("/labkey/apps/tomcat/SSL")}
end

ruby_block "generate-keystore" do
  block do
    if !FileTest.exist?("/labkey/apps/tomcat/keystore.tomcat") then
    	public_hostname = `hostname -f`.split(' ')[1]
    	`keytool -genkey -dname \"CN=#{public_hostname}, OU=LabKey, O=LabKey, L=Seatle, S=Washington, C=US\" -alias tomcat -keystore /labkey/apps/tomcat/SSL/keystore.tomcat -storepass changeit -keypass changeit -keyalg RSA -validity 730 -storetype pkcs12`
    	`chown tomcat:tomcat /labkey/apps/tomcat/SSL/keystore.tomcat`
    	`chmod 600 /labkey/apps/tomcat/SSL/keystore.tomcat`
    end
    Chef::Log.info("SSL Keystore has been created.")
  end
  action :create
  not_if {File.exists?("/labkey/apps/tomcat/SSL/keystore.tomcat")}
end

# Install JSVC service
script "install-jsvc"  do
  interpreter "bash"
  user "root"
  cwd "/labkey/apps"
  code <<-EOH
  fqdn_hostname=$(hostname -f)
  if [ -z $JAVA_HOME ]; then export JAVA_HOME=/usr/lib/jvm/java-6-sun; fi
  tar xzf /labkey/apps/tomcat/bin/jsvc.tar.gz
  cd /labkey/apps/jsvc-src
  sh support/buildconf.sh > /srv/build-logs/$fqdn_hostname-jsvc-install.log 2>&1
  chmod +x configure
  ./configure >> /srv/build-logs/$fqdn_hostname-jsvc-install.log 2>&1
  make >> /srv/build-logs/$fqdn_hostname-jsvc-install.log 2>&1
  EOH
  not_if {File.exists?("/labkey/apps/jsvc-src/CHANGES.txt")}
end

# Configure the service
service "tomcat" do
  supports :status => false, :restart => false, :reload => false
  start_command "/etc/init.d/tomcat start"
  stop_command "/etc/init.d/tomcat stop"
  enabled
  ignore_failure true
  action [ :enable, :start ]
end
