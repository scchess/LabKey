#
# Cookbook Name:: Xvfb
# Recipe:: default
#
# Recipe for installing X Virtual Frame Buffer 
# 
# B Connolly for LabKey 

# Set the required attributes
node.set["labkey"]["xvfb"]["displayNumber"] = ":2"

# Install the required packages
package "xvfb" do
  case node[:platform]
  when "centos","redhat","fedora"
    package_name "xorg-x11-server-Xvfb"
  when "suse" 
    package_name "xorg-x11-server-extra"
  when "debian","ubuntu"
    package_name "xvfb"
  end
  action :install
end

# Verify that required directory exists 
directory "/labkey/apps/ops" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/apps/ops")}
end

# Install the service start/stop script 
template "/etc/init.d/xvfb" do
  source "xvfb-init-script.erb"
  owner "root"
  group "root"
  mode 0755
  variables(
      :displayNumber => node[:labkey][:xvfb][:displayNumber]
  )
end

# Configure the service
service "xvfb" do
  supports :status => false, :restart => false, :reload => false
  start_command "/etc/init.d/xvfb start"
  stop_command "/etc/init.d/xvfb stop"
  enabled
  ignore_failure true
  action [ :enable, :start ]
end
