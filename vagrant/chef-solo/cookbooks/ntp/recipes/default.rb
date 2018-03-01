#
# Cookbook Name:: ntp
# Recipe:: default
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009, Opscode, Inc
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
# BC from LabKey: Added instruction to set timezone to Pacific and if running at Rackspace, 
# to break the synchronization with Xen. 


case node[:platform] 
when "ubuntu","debian"
  package "ntpdate" do
    action :install
  end
end

package "ntp" do
  action :install
end

service node[:ntp][:service] do
  action :start
end

template "/etc/ntp.conf" do
  source "ntp.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => node[:ntp][:service])
end

# Change the timezone 
script "set-timezone"  do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  mv /etc/localtime /etc/localtime.orig
  ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  ntpdate ntp.ubuntu.com
  touch /srv/build-logs/timezone.set
  EOH
  not_if {File.exists?("/srv/build-logs/timezone.set")}
end

# Break sychronization with the Xen host server
# If at Rackspace, execute 
ruby_block "break-xen-timesync-rackspace" do
  block do
    if node[:cloud][:provider] == "rackspace" then
      if File.open("/etc/sysctl.conf"){|f| f.read} !~ /independent_wallclock/ then
        File.open('/etc/sysctl.conf', 'a') do |f2|  
          f2.puts "# Added to set my own time in the VM. This breaks synchronization with XEN host "  
          f2.puts "xen.independent_wallclock = 1"  
        end
      end
      setclock = `echo 1 > /proc/sys/xen/independent_wallclock`
    end
  end
  only_if { node.attribute?("cloud") }
  action :create
end
# If on a virtual server running a kvm hypervisor 
ruby_block "break-xen-timesync-kvm" do
  block do
    if node[:virtualization][:system] == "kvm" then
      if File.open("/etc/sysctl.conf"){|f| f.read} !~ /independent_wallclock/ then
        File.open('/etc/sysctl.conf', 'a') do |f2|  
          f2.puts "# Added to set my own time in the VM. This breaks synchronization with XEN host "  
          f2.puts "xen.independent_wallclock = 1"  
        end
      end
      setclock = `echo 1 > /proc/sys/xen/independent_wallclock`
    end
  end
  only_if { node.attribute?("virtualization") }
  action :create
end

