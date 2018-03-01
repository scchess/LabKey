#
# Cookbook Name:: tomcat
# Recipe:: tomcat6
#
# This recipe is used to isntall Apache Tomcat 6.0.x for use with a LabKey Server.
# The recipe will
#   - Download the tomcat distribution from the Apache tomcat site
#   - Install tomcat in /labkey/apps/
#   - Modify server.xml and web.xml to configure tomcat
#   - Remove sample and unused webapps
#   - Create self-signed ssl certificate if SSL is enabled
#   - Build and install the Apache Commons Daemon
#   - Install the service start/stop script and enable it to start at boot-time.
#

#
# Variables for the recipe.
#
download_file = node['tomcat']["#{node['tomcat']['tomcat_version']}"]['url'].split('/').last
app_name = download_file.split('.tar.gz')[0]


# Install required packages
case node["platform"]
when "ubuntu", "debian"
  package "autoconf"
end

# Check if Tomcat, APR and Apache2 packages are installed. If so, remove them.
case node["platform"]
when "ubuntu", "debian"
  package "tomcat" do
    action :purge
  end
  package "apache2" do
    action :purge
  end
end

#
# Ensure that the install_dir and download_dir directories are created
#
directory node['tomcat']['download_dir']  do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if { File.exists?(node['tomcat']['download_dir']) }
end
directory node['tomcat']['install_dir']  do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if { File.exists?(node['tomcat']['install_dir']) }
end

#
# Download Tomcat distribution
#
remote_file "#{node['tomcat']['download_dir']}/#{download_file}" do
  source node['tomcat']["#{node['tomcat']['tomcat_version']}"]['url']
  mode "0755"
  owner"root"
  group "root"
  not_if { File.exists?("#{node['tomcat']['download_dir']}/#{download_file}") }
end

#
# Unzip and move the files to the correct place
#
script "install-tomcat"  do
  interpreter "bash"
  user "root"
  cwd node['tomcat']['install_dir']
  code <<-EOH
  tar -xzf #{node['tomcat']['download_dir']}/#{download_file}
  chown -R tomcat.tomcat #{node['tomcat']['install_dir']}/#{app_name}
  EOH
  not_if {File.exists?("#{node['tomcat']['install_dir']}/#{app_name}/LICENSE")}
end

#
# Create symbolic link from /labkey/apps/tomcat to install location
#
link "/labkey/apps/tomcat" do
  to "#{node['tomcat']['install_dir']}/#{app_name}"
end

#
# Remove sample apps and un-used management apps that are installed and enabled by default
#
directory "/labkey/apps/tomcat/webapps/docs"  do
  recursive true
  action :delete
end
directory "/labkey/apps/tomcat/webapps/examples"  do
  recursive true
  action :delete
end
directory "/labkey/apps/tomcat/webapps/manager"  do
  recursive true
  action :delete
end
directory "/labkey/apps/tomcat/webapps/host-manager"  do
  recursive true
  action :delete
end

#
# Configure the Tomcat Server
#
# Install configuration files
directory "/labkey/apps/tomcat/conf/Catalina/localhost"  do
  owner "tomcat"
  group "tomcat"
  mode "0700"
  recursive true
  action :create
  not_if {File.exists?("/labkey/apps/tomcat/conf/Catalina/localhost")}
end
cookbook_file "/labkey/apps/tomcat/conf/server.xml" do
  case node['tomcat']['ssl']
  when "true"
    source "server-6.0-ssl.xml"
  else
    source "server-6.0.xml"
  end
  mode "0600"
  owner"tomcat"
  group "tomcat"
end
cookbook_file "/labkey/apps/tomcat/conf/web.xml" do
  source "web.xml"
  mode "0600"
  owner"tomcat"
  group "tomcat"
end
template "/etc/init.d/tomcat" do
  case node['tomcat']['debug']
  when "true"
    source "tomcat-debug.initscript.erb"
  else
    source "tomcat.initscript.erb"
  end
  mode "0755"
  owner"tomcat"
  group "tomcat"
end

#
# Create new Tomcat TMP directory which will house the search indexes, temporary data for
# generating labkey reports, etc. This directory can grow large and should be placed on
# a volume with good i/o.
#
directory node['tomcat']['tmp_dir']  do
  owner "tomcat"
  group "tomcat"
  mode "0700"
  action :create
  not_if { File.exists?(node['tomcat']['tmp_dir']) }
end

#
# If SSL is to be enabled, then generate Self Signed Certificate
#
directory "/labkey/apps/tomcat/SSL"  do
  owner "tomcat"
  group "tomcat"
  mode "0700"
  action :create
  not_if { File.exists?("/labkey/apps/tomcat/SSL") }
  only_if { node["tomcat"]["ssl"] == "true" }
end

ruby_block "generate-keystore" do
  block do
    if !FileTest.exist?("/labkey/apps/tomcat/keystore.tomcat") then
    	public_hostname = `hostname -f`.split(' ')[1]
    	`#{node['java']['java_home']}/bin/keytool -genkey -dname \"CN=#{public_hostname}, OU=LabKey, O=LabKey, L=Seatle, S=Washington, C=US\" -alias tomcat -keystore /labkey/apps/tomcat/SSL/keystore.tomcat -storepass changeit -keypass changeit -keyalg RSA -validity 730 -storetype pkcs12`
    	`chown tomcat:tomcat /labkey/apps/tomcat/SSL/keystore.tomcat`
    	`chmod 600 /labkey/apps/tomcat/SSL/keystore.tomcat`
    end
    Chef::Log.info("generate-keystore: SSL Keystore has been created.")
  end
  action :create
  not_if { File.exists?("/labkey/apps/tomcat/SSL/keystore.tomcat") or node[:tomcat][:ssl]!="true" }
end

#
# Install JSVC service which will be used to start and stop the tomcat application
# on this server
# - JSVC is also called the Apache Commons Deamon
#
script "install-jsvc"  do
  interpreter "bash"
  user "root"
  cwd "/labkey/apps"
  code <<-EOH
  fqdn_hostname=$(hostname -f)
  if [ -z $JAVA_HOME ]; then export JAVA_HOME=#{node['java']['java_home']}; fi
  if [ -e /labkey/apps/eid72sgtda9f ]; then rm -rf /labkey/apps/eid72sgtda9f; fi
  export PATH=$PATH:$JAVA_HOME/bin
  mkdir /labkey/apps/eid72sgtda9f
  tar xzf /labkey/apps/tomcat/bin/commons-daemon-native.tar.gz -C /labkey/apps/eid72sgtda9f
  cname=$(ls /labkey/apps/eid72sgtda9f)
  mv /labkey/apps/eid72sgtda9f/$cname /labkey/apps/commons-daemon
  rmdir /labkey/apps/eid72sgtda9f
  cd /labkey/apps/commons-daemon/unix
  sh support/buildconf.sh > /srv/build-logs/$fqdn_hostname-jsvc-install.log 2>&1
  ./configure >> /srv/build-logs/$fqdn_hostname-jsvc-install.log 2>&1
  make >> /srv/build-logs/$fqdn_hostname-jsvc-install.log 2>&1
  EOH
  not_if {File.exists?("/labkey/apps/commons-daemon/unix/CHANGES.txt")}
end

#
# Now that JSVC is successfully compiled, configure the service.
#
service "tomcat" do
  supports :status => false, :restart => false, :reload => false
  start_command "/etc/init.d/tomcat start"
  stop_command "/etc/init.d/tomcat stop"
  enabled
  ignore_failure true
  action [ :enable, :start ]
end
