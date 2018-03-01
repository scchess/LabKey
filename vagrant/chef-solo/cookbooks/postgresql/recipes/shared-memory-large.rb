#
# Cookbook Name:: postgresql
# Recipe:: shared-memory-m1.large
#
# This recipe will set the kernel shared memory max (shmmax) and all (shmall) settings on the server
# Use this recipe if you are installing on an m1.large type instance at AWS
#   - (this type of instance has 7.5GB of memory)
# 

# This sets the shared memory max setting to 3GB.  
ruby_block "increase-share-memory-max" do
  block do
    `sysctl -w kernel.shmmax=3221225472`
    `sysctl -w kernel.shmall=786432`
    if File.open("/etc/sysctl.conf"){|f| f.read} !~ /kernel.shmmax/ then
      File.open('/etc/sysctl.conf', 'a') do |f2|  
        f2.puts "# Added to increase size of shared memory max to support a large postgres database "  
        f2.puts "kernel.shmmax=3221225472"  
        f2.puts "kernel.shmall=786432"  
      end
    end
    Chef::Log.info("Kernel Shared Memory Max was increased to 3GB.")
  end
  action :create
end
