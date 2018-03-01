#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Description here 

#
# Variables for the recipe.
#
download_file = node['postgresql']["#{node['postgresql']['version']}"]['url'].split('/').last
app_name = download_file.split('.tar.gz')[0]

#
# Install required packages 
#
case node['platform']
when "centos", "redhat", "fedora"
  package "readline-devel"
when "ubuntu", "debian"
  package "libreadline-dev"
  package "zlib1g-dev"
  package "zlib-bin"
end

# Create the postgres user and group
group node['postgresql']['group'] do
  action :create
end
user node['postgresql']['os_user'] do
  comment "PostgreSQL User"
  gid node['postgresql']['group']
  home "/home/#{node['postgresql']['os_user']}"
  shell "/bin/bash"
  supports :manage_home => true
  action [:create, :manage]
end

#
# Ensure all the required directories are created.
#
directory node['postgresql']['download_dir']  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if { File.exists?(node['postgresql']['download_dir']) }
end
directory node['postgresql']['install_dir']  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if { File.exists?(node['postgresql']['install_dir']) }
end
directory node['postgresql']['data_dir']  do
  owner node['postgresql']['os_user']
  group node['postgresql']['os_user']
  mode "0700"
  recursive true
  action :create
  not_if { File.exists?(node['postgresql']['data_dir']) }
end

#
# Download PostgreSQL distribution
#
remote_file "#{node['postgresql']['download_dir']}/#{download_file}" do
  source node['postgresql']["#{node['postgresql']['version']}"]['url']
  mode "0755"
  owner"root"
  group "root"
  not_if { File.exists?("#{node['postgresql']['download_dir']}/#{download_file}") }
end

#
# Create build-log file with very loose permissions
#
file "/srv/build-logs/#{node[:fqdn]}-postgres_build.log" do
  owner "root"
  group "root"
  mode "0777"
  action :create
end

#
# Build and Install the PostgreSQL database.
#
script "install-postgres"  do
  interpreter "bash"
  user "root"
  cwd "#{node['postgresql']['download_dir']}"
  code <<-EOH
  fqdn_hostname=#{node[:fqdn]}
  tar xzf #{node['postgresql']['download_dir']}/#{download_file} 2>&1 > /srv/build-logs/$fqdn_hostname-postgres_build.log
  cd #{node['postgresql']['download_dir']}/#{app_name}
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "run configure " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  ./configure --prefix=#{node['postgresql']['install_dir']}/#{app_name} >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "run make  " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  make >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  if i[ "${?}" -ne "0" ] ; then
    echo "make command failed. Postgresql server software is not installed properly"
    exit 1
  fi
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "run make install " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  make install >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  # Verify that make install was successful
  if [ ! -f #{node['postgresql']['install_dir']}/#{app_name}/bin/psql ];
  then
    echo "make install command failed. Postgresql server software is not installed properly"
    exit 1
  fi
  touch /srv/build-logs/database-#{node['postgresql']['version']}.installed
  EOH
  not_if { File.exists?("/srv/build-logs/database-#{node['postgresql']['version']}.installed") }
end
log("Output from PostgreSQL build and install is located in /srv/build-logs")

#
# The rest of the recipe will only be run if the compile and install completes successfully.
# If it did not complete successfully, then we will skip these steps and write a log message
#
#
# Initialize the PostgreSQL database.
#
script "initialize database" do
  interpreter "bash"
  user node['postgresql']['os_user'] 
  cwd "#{node['postgresql']['install_dir']}"
  code <<-EOH
  fqdn_hostname=#{node[:fqdn]}
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "create database instance " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  echo " " >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{node['postgresql']['install_dir']}/#{app_name}/lib
  #{node['postgresql']['install_dir']}/#{app_name}/bin/initdb --locale=en_US.UTF-8 -D #{node['postgresql']['data_dir']} >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  mkdir #{node['postgresql']['data_dir']}/pg_log >> /srv/build-logs/$fqdn_hostname-postgres_build.log 2>&1
  touch #{node['postgresql']['data_dir']}/database_instance.created
  EOH
  not_if {File.exists?("#{node['postgresql']['data_dir']}/database_instance.created")}
end


#
# If the transaction log directory (log_dir) is not located in the data_dir
# ie you are storing the transaction log data on a different volume from the 
# postgresql data files, then move the directory and create a link from the 
# log_dir/pg_xlog directory to data_dir/pg_xlog
# Create the required directories
if File.dirname(File.expand_path("#{node['postgresql']['log_dir']}")) != File.expand_path("#{node['postgresql']['data_dir']}") then 
  directory "#{node['postgresql']['log_dir']}" do 
    owner node['postgresql']['os_user']
    group node['postgresql']['group']
    mode "0700"
    recursive true
    action :create
    not_if { File.exists?("#{node['postgresql']['log_dir']}") }
  end
  ruby_block "move-transaction-logs" do
    block do
      fileMove = `mv #{node['postgresql']['data_dir']}/pg_xlog #{node['postgresql']['log_dir']}/`
      permSet=`chown #{node['postgresql']['os_user']} #{node['postgresql']['log_dir']}/pg_xlog`
      create_link = `ln -s #{node['postgresql']['log_dir']}/pg_xlog #{node['postgresql']['data_dir']}/pg_xlog`
      Chef::Log.info("Moved postgres transaction log storage location to #{node['postgresql']['log_dir']}/pg_xlog.")
    end
    action :create
    not_if { File.exists?("#{node['postgresql']['log_dir']}/pg_xlog") }
  end
end

#
# Update environment variables for all users
#
case node['platform']
when "suse"
  ruby_block "add-postgres-variables-to-profile.local" do
    block do
      if File.exists?("/etc/profile.local") then
        if File.open("/etc/profile.local"){|f| f.read} !~ /LabKey/ then
            File.open('/etc/profile.local', 'a') do |f2|
              f2.puts "# Added by LabKey"
              f2.puts "export PATH=$PATH:#{node['postgresql']['install_dir']}/#{app_name}/bin"
              f2.puts "export LD_LIBRARY_PATH=#{node['postgresql']['install_dir']}/#{app_name}/lib:$LD_LIBRARY_PATH"
            end
        end
      else
        File.open('/etc/profile.local', 'a') do |f2|
          f2.puts "# Added by LabKey"
          f2.puts "export PATH=$PATH:#{node['postgresql']['install_dir']}/#{app_name}/bin"
          f2.puts "export LD_LIBRARY_PATH=#{node['postgresql']['install_dir']}/#{app_name}/lib:$LD_LIBRARY_PATH"
        end
      end
    end
  end
when "ubuntu", "debian", "redhat", "fedora"
  ruby_block "add-postgres-variables-to-bash.bashrc" do
    block do
      if File.open("/etc/bash.bashrc"){|f| f.read} !~ /LabKey/ then
          File.open('/etc/bash.bashrc', 'a') do |f2|
            f2.puts "# Added by LabKey"
            f2.puts "export PATH=$PATH:#{node['postgresql']['install_dir']}/#{app_name}/bin"
            f2.puts "export LD_LIBRARY_PATH=#{node['postgresql']['install_dir']}/#{app_name}/lib:$LD_LIBRARY_PATH"
          end
      end
    end
  end
end


# Install configuration files
if node["postgresql"]["hba_network"] == "false" then
  template "#{node['postgresql']['data_dir']}/pg_hba.conf" do
    source "pg_hba.conf.erb"
    owner node['postgresql']['os_user']
    group node['postgresql']['group']
    mode "0600"
  end
else
  template "#{node['postgresql']['data_dir']}/pg_hba.conf" do
    source "pg_hba.conf-allow-additional-network.erb"
    owner node['postgresql']['os_user']
    group node['postgresql']['group']
    mode "0600"
    variables(
      :network => node["postgresql"]["hba_network"]
    )
  end
end
template "#{node['postgresql']['data_dir']}/postgresql.conf" do
  source "postgresql.conf-#{node['postgresql']['version']}.erb"
  owner node['postgresql']['os_user']
  group node['postgresql']['group']
  mode "0600"
  variables(
    :install_dir => "#{node["postgresql"]["install_dir"]}/#{app_name}",
    :data_dir => node['postgresql']['data_dir'],
    :port => node["postgresql"]["port"],
    :shared_buffers => node["postgresql"]["shared_buffers"],
    :work_mem => node["postgresql"]["work_mem"],
    :maint_work_mem => node["postgresql"]["maint_work_mem"],
    :wal_buffers => node["postgresql"]["wal_buffers"],
    :checkpoint_segments => node["postgresql"]["checkpoint_segments"],
    :checkpoint_timeout => node["postgresql"]["checkpoint_timeout"],
    :random_page_cost => node["postgresql"]["random_page_cost"],
    :effective_cache_size => node["postgresql"]["effective_cache_size"]
  )
end

# Install Startup Script
template "/etc/init.d/postgresql-#{node['postgresql']['version']}" do
  source "init.erb"
  owner "root"
  group "root"
  mode "0755"
  variables(
    :install_dir => "#{node["postgresql"]["install_dir"]}/#{app_name}",
    :data_dir => node['postgresql']['data_dir'],
    :version => node["postgresql"]["version"],
    :os_user => node["postgresql"]["os_user"]
  )
end

service "postgresql-#{node['postgresql']['version']}" do
  supports :restart => true, :status => true
  action :enable 
end
service "postgresql-#{node['postgresql']['version']}" do
  action :start 
end

#
# Create new postgresql database user
#
# If the user specified in node[:postgresql][:user] == postgres, then
# simply set the postgres user password to node[:postgresql][:password]
#
script "create-new-users"  do
  interpreter "bash"
  user node['postgresql']['os_user']
  cwd "/tmp"
  code <<-EOH
  POSTGRES_ADMIN_PWD=#{node[:postgresql][:password]}
  #{node['postgresql']['install_dir']}/#{app_name}/bin/createlang -p #{node['postgresql']['port']} -d template1 PLpgsql
  echo -e "CREATE USER #{node[:postgresql][:user]} WITH PASSWORD '$POSTGRES_ADMIN_PWD' SUPERUSER;" | #{node['postgresql']['install_dir']}/#{app_name}/bin/psql -p #{node['postgresql']['port']} postgres
  touch #{node['postgresql']['data_dir']}/.labkey
  EOH
  not_if {File.exists?("#{node['postgresql']['data_dir']}/.labkey")}
  only_if { node[:postgresql][:user] != 'postgres' }
end
script "reset-postgres-users-password"  do
  interpreter "bash"
  user node['postgresql']['os_user']
  cwd "/tmp"
  code <<-EOH
  POSTGRES_ADMIN_PWD=#{node[:postgresql][:password]}
  #{node['postgresql']['install_dir']}/#{app_name}/bin/createlang -p #{node['postgresql']['port']} -d template1 PLpgsql
  echo -e "ALTER ROLE #{node[:postgresql][:user]} WITH PASSWORD '$POSTGRES_ADMIN_PWD';" | #{node['postgresql']['install_dir']}/#{app_name}/bin/psql -p #{node['postgresql']['port']} postgres
  touch #{node['postgresql']['data_dir']}/.labkey
  EOH
  not_if {File.exists?("#{node['postgresql']['data_dir']}/.labkey")}
  only_if { node[:postgresql][:user] == 'postgres' }
end
if node[:postgresql][:user] != 'postgres' then
  log("PostgreSQL database account has been created. Username = #{node[:postgresql][:user]} : Password = #{node[:postgresql][:password]}")
else
  log("PostgreSQL database account password has been changed. Username = #{node[:postgresql][:user]} : Password = #{node[:postgresql][:password]}")
end
