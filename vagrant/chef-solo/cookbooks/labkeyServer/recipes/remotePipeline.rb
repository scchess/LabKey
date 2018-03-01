#
# Cookbook Name:: labkeyServer
# Recipe:: remotePipeline
#
# This recipe is used to install the LabKey Server Remote Pipeline on a Vagrant VM
# The recipe will
#   - Download the LabKey Server distribution from a URL specified in the attributes or json-config file
#   - Install labkey in /labkey/labkey if there the /labkey/labkey/modules directory does not already exist
#   - Create ms2Config, ms1Config and pipelineConfig in the /labkey/labkey/configs directory, 
#     if the /labkey/labkey/configs directory does not already contain them
#   - Copy the required jars to /labkey/labkey
#   - Create the service start script at /etc/init.d/labkeyRemotePipeline
#   - Creates the Pipeline BIN directory /labkey/bin 
#     (use the tpp recipe to install proteomics tools in that directory)
#

#
# Variables for the recipe.
#
vagrant_labkey_install_dir = "/vagrant/_labkey"
download_file = node['labkey']['server']["#{node['labkey']['server']['labkey_version']}"]['url'].split('/').last
app_name = download_file.split('.tar.gz')[0]

#
# Create the required directories and symbolic links
#
# Create download directory
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

# Create TEMP directory to be used by Remote Pipeline Service 
directory "/labkey/tmp"  do
    owner "labkey"
    group "labkey"
    mode "0755"
    action :create
end
# Create logs directory to be used by Remote Pipeline Service if it 
# does not already exist
# This directory resides on VM host. Setting ownership fails
directory "#{vagrant_labkey_install_dir}/logs"  do
    mode "0755"
    action :create
    not_if {File.exists?("#{vagrant_labkey_install_dir}/logs")}
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
      mode "0644"
      owner"root"
      group "root"
      not_if { File.exists?("#{node['labkey']['server']['download_dir']}/#{download_file}") }
    end
    #
    # Unzip the downloaded distribution
    #
    bash "unzip-labkey"  do
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
    bash "install-labkey"  do
        user "root"
        cwd "#{node['labkey']['server']['download_dir']}/#{app_name}"
        code <<-EOH
        LABKEY_HOME=#{node['labkey']['server']['install_dir']}
        CATALINA_HOME=/labkey/apps/tomcat
        cp -R bin $LABKEY_HOME
        cp -R modules $LABKEY_HOME
        cp -R labkeywebapp $LABKEY_HOME
        cp -R pipeline-lib $LABKEY_HOME
        cp -f tomcat-lib/labkeyBootstrap.jar $LABKEY_HOME
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
# Install the Remote Pipeline configuration files. 
# If the files already exist, then we will not update
# them.
# 

# Create configs directory if it does not already exist
directory "#{vagrant_labkey_install_dir}/config" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    not_if { File.exists?("#{vagrant_labkey_install_dir}/config") }
end

# Create the pipelineConfig.xml configuration file 
template "#{vagrant_labkey_install_dir}/config/pipelineConfig.xml" do
    source "pipelineConfig.xml.erb"
    mode "0644"
    owner"root"
    group "root"
    variables(
        :lock_dir => "#{vagrant_labkey_install_dir}/syncp-locks",
        :activemq_host => node['labkey']['activemq_host']
    )
    not_if { File.exists?("#{vagrant_labkey_install_dir}/config/pipelineConfig.xml") }
end

# Create the ms1Config.xml configuration file 
cookbook_file "#{vagrant_labkey_install_dir}/config/ms1Config.xml" do
  source "ms1Config.xml"
  mode "0600"
  owner"root"
  group "root"
  not_if { File.exists?("#{vagrant_labkey_install_dir}/config/ms1Config.xml") }
end

# Create the ms2Config.xml configuration file 
cookbook_file "#{vagrant_labkey_install_dir}/config/ms2Config.xml" do
  source "ms2Config.xml"
  mode "0600"
  owner"root"
  group "root"
  not_if { File.exists?("#{vagrant_labkey_install_dir}/config/ms2Config.xml") }
end

# Create the microarrayConfig.xml configuration file 
cookbook_file "#{vagrant_labkey_install_dir}/config/microarrayConfig.xml" do
  source "microarrayConfig.xml"
  mode "0600"
  owner"root"
  group "root"
  not_if { File.exists?("#{vagrant_labkey_install_dir}/config/microarrayConfig.xml") }
end


#
# Create the service start/stop script LabKey Remote Pipeline. 
#
template "/etc/init.d/labkeyRemotePipeline" do
    source "labkeyRemotePipeline.initscript.erb"
    mode "0755"
    owner"root"
    group "root"
    variables(
        :java_home => node['java']['java_home']
    )
end
#
# Configure the service.
#
service "labkeyRemotePipeline" do
    supports :status => false, :restart => false, :reload => false
    start_command "/etc/init.d/labkeyRemotePipeline start"
    stop_command "/etc/init.d/labkeyRemotePipeline stop"
    action [ :disable ]
end

