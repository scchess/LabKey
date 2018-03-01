#
# Cookbook Name:: activemq
# Recipe:: default
#
# This recipe is used to install ActiveMQ on a Vagrant VM
# The recipe will
#   - Download activeMQ file
#   - Install activeMQ in /labkey/apps/apache-activemq-5.1.0 
#   - Create service start/stop script 
#   - Enable the service to start at boot-time and to listen on 
#     all network interfaces

# Variables
download_url = "http://archive.apache.org/dist/activemq/apache-activemq/5.9.0/apache-activemq-5.9.0-bin.tar.gz"
download_file = download_url.split('/').last
app_name = download_file.split('-bin.tar.gz')[0]
download_dir = "/labkey/src"

#
# Create the required directories and symbolic links
#
directory download_dir  do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
    not_if { File.exists?(download_dir) }
end

#
# Download the binary files 
#
remote_file "#{download_dir}/#{download_file}" do
    source download_url
    mode "0644"
    owner"root"
    group "root"
    not_if { File.exists?("#{download_dir}/#{download_file}") }
end

#
# Unzip the downloaded distribution
#
bash "unzip-activemq"  do
    user "root"
    cwd "#{download_dir}"
    code <<-EOH
    tar xzf #{download_dir}/#{download_file}
    EOH
    not_if {File.exists?("#{download_dir}/#{app_name}")}
end

#
# Install LabKey Server software
#
bash "install-activemq"  do
    user "root"
    cwd "#{download_dir}"
    code <<-EOH
    ACTIVEMQ_HOME=/labkey/apps/#{app_name}
    cp -R #{download_dir}/#{app_name} /labkey/apps
    chown -R labkey.labkey $ACTIVEMQ_HOME
    echo "ActiveMQ Version: #{app_name}" > $ACTIVEMQ_HOME/.activeMQInstalled
    EOH
    not_if {File.exists?("/labkey/apps/#{app_name}/.activeMQInstalled")}
end

# 
# Add ACTIVEMQ_HOME variable to /etc/environment 
# 
ruby_block "set-activemq-variable" do
  block do    
    # Update the environment file if it has not been done
    if File.open("/etc/environment"){|f| f.read} !~ /ACTIVEMQ/ then
      File.open('/etc/environment', 'a') do |f2|  
        f2.puts "ACTIVEMQ_HOME=/labkey/apps/#{app_name}"  
      end
    end
  end
  action :create
end

#
# Create and install the configuration files 
# 
cookbook_file "/labkey/apps/#{app_name}/conf/activemq.xml" do
  source "activemq.xml"
  mode "0600"
  owner"labkey"
  group "labkey"
end
cookbook_file "/labkey/apps/#{app_name}/conf/credentials.properties" do
  source "credentials.properties"
  mode "0600"
  owner"labkey"
  group "labkey"
end

# Create the service start/stop script LabKey Remote Pipeline. 
#
template "/etc/init.d/activemq" do
    source "activemq.initscript.erb"
    mode "0755"
    owner"root"
    group "root"
    variables(
        :java_home => node['java']['java_home'],
        :activemq_home => "/labkey/apps/#{app_name}"
    )
end

#
# Configure the service.
#
service "activemq" do
    supports :status => false, :restart => false, :reload => false
    start_command "/etc/init.d/activemq start"
    stop_command "/etc/init.d/activemq stop"
    action [ :enable, :start ]
end
