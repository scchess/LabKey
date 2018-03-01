#
# Cookbook Name:: labkeyBase
# Recipe:: default
#
# This recipe should be used on all servers running LabKey Server. This recipe lays the ground work for the LabKey
# Server installation.  The recipe assumes that all LabKey related software and the LabKey itself will be installed
# into the /labkey directory 
#
#

#
# Resource to re-run Ohai after the creation of the Rserve
# user below. This is required to find the UID/GID of 
# newly created user in later resources.
#
ohai "reload_passwd" do
  action :nothing
  plugin "passwd"
end

#
# Install required packages
#
package "zip"
package "unzip"
package "graphviz"
package "sendmail"

#
# Create the required directories 
# 
directory "/labkey"  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey")}
end
directory "/labkey/apps"  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/apps")}
end
directory "/labkey/src"  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/src")}
end
directory "/labkey/apps/ops/bin"  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/apps/ops/bin")}
end
directory "/labkey/backup"  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/backup")}
end

#
# Create required user accounts and groups
# 
group "labkey" do
  action :create
  gid 3000
end
user "labkey" do
  comment "LabKey User"
  system true
  shell "/bin/bash"
  home "/home/labkey"
  uid 3001
  gid 3000
  supports :manage_home => true
end
user "tomcat" do
  comment "LabKey Tomcat User"
  system true
  shell "/bin/bash"
  home "/home/tomcat"
  uid 3002
  supports :manage_home => true
  notifies :reload, "ohai[reload_passwd]", :immediately
end
group "labkey" do
  action :modify
  members "tomcat"
  append true
end


# Update the aliases file and run newaliases to ensure that email directed to root goes to ops@labkey.com
ruby_block "update-aliases" do
  block do
    # Update the /etc/mail/aliases
    if File.open("/etc/mail/aliases"){|f| f.read} !~ /ops\@labkey.com/ then
      File.open('/etc/mail/aliases', 'a') do |f2|
        f2.puts "# LabKey Specific aliases"
        f2.puts "tomcat:         root"
        f2.puts "postgres:       root"
        f2.puts "labkey:         root"
        f2.puts "lksync:         root"
        f2.puts "root:           ops@labkey.com"
      end
      hn=%x[newaliases]
      Chef::Log.info("sendmail aliases have been updated: Output from command = #{hn}")
    end
  end
  action :create
end





