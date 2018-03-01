#
# Cookbook Name:: postgresql
# Recipe:: shared-memory-m1.small
#
# This recipe will set the kernel shared memory max (shmmax) and all (shmall) settings on the server
# Use this recipe if you are installing on an m1.small type instance at AWS
#   - (this type of instance has 1.7GB of memory)
# 

# This sets the shared memory max setting to 576MB.  
ruby_block "increase-share-memory-max" do
  block do
    `sysctl -w kernel.shmmax=603979776`
    `sysctl -w kernel.shmall=147456`
    if File.open("/etc/sysctl.conf"){|f| f.read} !~ /kernel.shmmax/ then
      File.open('/etc/sysctl.conf', 'a') do |f2|  
        f2.puts "# Added to increase size of shared memory max to support a large postgres database "  
        f2.puts "kernel.shmmax=603979776"  
        f2.puts "kernel.shmall=147456"  
      end
    end
    Chef::Log.info("Kernel Shared Memory Max was increased to 576MB.")
  end
  action :create
end
