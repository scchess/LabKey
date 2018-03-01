#
# Cookbook Name:: labkeyServer
# Recipe:: default
#
# This recipe is used to install LabKey Server.
# The recipe will
#   - Download the LabKey Server distribution from a URL specified in the attributes or json-config file
#   - Install labkey in /labkey/labkey/
#   - Copy the required jars to /labkey/apps/tomcat/lib directory
#   - Install the LabKey Server webapp as the ROOT webapp
#   - Create extraWebapps and extraModules directory
#   - Disable search engine crawling using robots.txt
#
#
# This recipe assumes that the tomcat6.rb recipe has already been run.
# This recipe will not work with tomcat 5.5 installations. You will need to modify the install-labkey script block
#

#
# Variables for the recipe.
#
vagrant_labkey_install_dir = "/vagrant/_labkey"
download_file = node['labkey']['server']["#{node['labkey']['server']['labkey_version']}"]['url'].split('/').last
app_name = download_file.split('.tar.gz')[0]

#
# Create the download directory if it does not exist
#
directory node['labkey']['server']['download_dir']  do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# Create vagrant_labkey_install_dir if it does not exist
# This directory resides on VM host. Setting ownership fails
directory vagrant_labkey_install_dir  do
    mode "0755"
    action :create
    not_if {File.exists?("#{vagrant_labkey_install_dir}")}
end


# Create symbolic link from /labkey/labkey to vagrant_labkey_install_dir
link node['labkey']['server']['install_dir'] do
    to vagrant_labkey_install_dir
end

#
# Install LabKey Server binaries if the /labkey/labkey/modules directory
# does not exist.
# If the directory exists, we will assume that developer wants to use 
# their own version of the LabKey Server. 
# 
if File.exists?("#{vagrant_labkey_install_dir}/modules")
    Chef::Log.info("#{vagrant_labkey_install_dir}/modules directory exists. LabKey Server binaries will not be installed as you want to use your own development bits.")
else
    #
    # Download LabKey distribution file
    #
    remote_file "#{node['labkey']['server']['download_dir']}/#{download_file}" do
      source node['labkey']['server']["#{node['labkey']['server']['labkey_version']}"]['url']
      mode "0755"
      owner"root"
      group "root"
      not_if { File.exists?("#{node['labkey']['server']['download_dir']}/#{download_file}") }
    end

    #
    # Unzip the downloaded distribution
    #
    script "unzip-labkey"  do
      interpreter "bash"
      user "root"
      cwd "#{node['labkey']['server']['download_dir']}"
      code <<-EOH
      tar xzf #{node['labkey']['server']['download_dir']}/#{download_file}
      EOH
      not_if {File.exists?("#{node['labkey']['server']['download_dir']}/#{app_name}")}
    end

    #
    # Install LabKey Server software
    #
    script "install-labkey"  do
      interpreter "bash"
      user "root"
      cwd "#{node['labkey']['server']['download_dir']}/#{app_name}"
      code <<-EOH
      LABKEY_HOME=#{node['labkey']['server']['install_dir']}
      CATALINA_HOME=/labkey/apps/tomcat
      mkdir -p $LABKEY_HOME/bin/
      cp -f bin/* $LABKEY_HOME/bin
      cp -R modules $LABKEY_HOME
      cp -R labkeywebapp $LABKEY_HOME
      cp -R pipeline-lib $LABKEY_HOME
      cp -f tomcat-lib/*.jar $CATALINA_HOME/lib
      chown -R tomcat.tomcat $LABKEY_HOME
      echo "LabKey Version: #{app_name}" > $LABKEY_HOME/.labkeyInstalled
      EOH
      not_if {File.exists?("#{node['labkey']['server']['install_dir']}/.labkeyInstalled")}
    end

    #
    # Create symbolic link from /labkey/labkey to install location if the install_dir
    # is different than /labkey/labkey
    #
    link "/labkey/labkey" do
        to "#{node['labkey']['server']['install_dir']}"
        not_if { File.directory?("/labkey/labkey") }
    end
end 

#
# Create the External Modules Directory
#
directory "#{node['labkey']['server']['install_dir']}/externalModules" do
  mode "0755"
  action :create
end

#
# Create the Extra Webapp Directory. 
#
directory "#{node['labkey']['server']['install_dir']}/extraWebapp" do
  mode "0755"
  action :create
end

#
# Stop the Tomcat Service
#
service "tomcat" do
  action [ :stop]
end

#
# Install the LabKey Server configuration file.
# If the variable node['labkey']['server']['serverGUID'] is defined in the json file, then use
# labkey-staging.xml.erb instead of labkey.xml.erb
#   - this is done so we can discern staging servers from production servers in mothership.
#
template "/labkey/apps/tomcat/conf/Catalina/localhost/ROOT.xml" do
  if node['labkey']['server']['serverGUID'] != nil then
    source "labkey-staging.xml.erb"
  else
    source "labkey.xml.erb"
  end
  owner "tomcat"
  group "tomcat"
  mode "0755"
end

#
#Start the Tomcat Service
#
service "tomcat" do
  action [ :start]
end

