#
# Cookbook Name:: base
# Recipe:: default
#

Chef::Log.info("Guest VM IP address = #{node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first}")
Chef::Log.info("To access the Host machine from the Guest VM use #{node['labkey']['host_ip']}")

# 
# Install all updates using apt 
# 
# Run apt-get update to create the stamp file
case node['platform']
when "ubuntu", "debian"
    execute 'apt-get-upgrade' do
        command 'apt-get -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade'
        ignore_failure true
        environment ({'DEBIAN_FRONTEND' => "noninteractive"})
    end
end 

#
# Install new packages
#
package "wget"
package "ssl-cert"
package "netcat"
package "strace"
package "vim"

#
# Remove packages 
#
# - There are some Ubuntu 12 packages that cause problems. These problems are mostly
#   annoying log messages. These packages are not used by any labkey specific 
#   software 
#
case node['platform']
when "ubuntu"
    package "popularity-contest" do
        action :purge
    end
end
package "vim-tiny" do
    action :purge
end

#
# Add in the build-logs directory to hold output from all services built during install.
#
directory "/srv/build-logs"  do
    owner "root"
    group "root"
    mode "0777"
    action :create
    not_if { File.exists?("/srv/build-logs") }
end

# Add the srv-info directory to hold information about the server. 
directory "/srv/srv-info"  do
    owner "root"
    group "root"
    mode "0777"
    action :create
    not_if { File.exists?("/srv/srv-info") }
end

#
# Disable ipv6 on Vagrant VMs 
# 
ruby_block "disable-ipv6" do
  block do    
    # Update the /etc/sysctl.conf file and add in commands 
    if File.open("/etc/sysctl.conf"){|f| f.read} !~ /LabKey/ then
      File.open('/etc/sysctl.conf', 'a') do |f2|  
        f2.puts "# Added by LabKey to disable IPV6"
        f2.puts "net.ipv6.conf.all.disable_ipv6 = 1"
        f2.puts "net.ipv6.conf.default.disable_ipv6 = 1"
        f2.puts "net.ipv6.conf.lo.disable_ipv6 = 1"
      end
      # Run command to disable now
      `sysctl -p`
    end
  end
  action :create
  only_if { platform?("debian", "ubuntu") }
end

# 
# Change VI configuration settings to enable arrow keys and numpad on Vagrant VMs
# 
cookbook_file "/etc/vim/vimrc.local" do
    source "vimrc.local"
    mode "0644"
end
