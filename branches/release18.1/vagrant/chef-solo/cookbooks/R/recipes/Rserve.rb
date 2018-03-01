#
# Cookbook Name:: R
# Recipe:: Rserve
#
# Recipe for configuring Rserve to run as as daemon 
#

#
# Set placeholder variables
#
rserve_uid = "3015"
rserve_gid = "3015"

#
# Resource to re-run Ohai after the creation of the Rserve
# user below. This is required to find the UID/GID of 
# newly created user in later resources.
#
ohai "reload_passwd" do
  action :nothing
  plugin "etc"
end

#
# Create rserve group and user
#
group "rserve" do
  action :create
  gid rserve_gid
end
user "rserve" do
    comment "Rserve system account"
    shell "/bin/bash"
    home "/home/labkey"
    uid rserve_uid
    gid rserve_gid
    supports :manage_home => true
    notifies :reload, "ohai[reload_passwd]", :immediately
end

#
# Create Rserve configuration file 
#
template "/etc/Rserv.conf" do
  source "Rserv.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :rserve_uid => rserve_uid,
    :rserve_gid => rserve_gid
  )
end

# 
# Create Rserve logins file 
#
cookbook_file "/etc/Rserv.logins" do
  source "Rserv.logins"
  owner "rserve"
  group "root"
  mode "600"
  action :create
end

#
# Create the Rserve service start/stop script
#
cookbook_file "/etc/init.d/rserved" do
  source "rserved"
  owner "root"
  group "root"
  mode "775"
  action :create
end

#
# Install the rserved service. Enable the rserve daemon to start at boot time
# and start the service.
#
service "rserved" do
  supports :status => true, :restart => true, :reload => true
  start_command "/etc/init.d/rserved start"
  stop_command "/etc/init.d/rserved stop"
  enabled
  ignore_failure true
  action [ :enable, :start ]
end
