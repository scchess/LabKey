#
# Cookbook Name:: postgresql
# Attributes:: default
#

# This attribute file has been modified by b.connolly at LabKey. The
# cookbook, and thus these attributes, are not specific to LabKey
# installation.

# Default Postgresql version
default["postgresql"]["version"] = "9.3"
default["postgresql"]["port"] = "5432"
default["postgresql"]["os_user"] = "postgres"
default["postgresql"]["group"] = "postgres"


# Download locations for PostgreSQL
# Postgresql 8.3
default['postgresql']['8.3']['url'] = 'http://ftp.postgresql.org/pub/source/v8.3.21/postgresql-8.3.21.tar.gz'
# Postgresql 8.4
default['postgresql']['8.4']['url'] = 'http://ftp.postgresql.org/pub/source/v8.4.17/postgresql-8.4.17.tar.gz'
# Postgresql 9.0
default['postgresql']['9.0']['url'] = 'http://ftp.postgresql.org/pub/source/v9.0.15/postgresql-9.0.15.tar.gz'
# Postgresql 9.1
default['postgresql']['9.1']['url'] = 'http://ftp.postgresql.org/pub/source/v9.1.11/postgresql-9.1.11.tar.gz'
# Postgresql 9.2
default['postgresql']['9.2']['url'] = 'http://ftp.postgresql.org/pub/source/v9.2.6/postgresql-9.2.6.tar.gz'
# Postgresql 9.3
default['postgresql']['9.3']['url'] = 'http://ftp.postgresql.org/pub/source/v9.3.2/postgresql-9.3.2.tar.gz'


# Installation and configuraton directories
default["postgresql"]["download_dir"] = "/labkey/src"
default["postgresql"]["install_dir"] = "/labkey/apps"

download_file = node['postgresql']["#{node['postgresql']['version']}"]['url'].split('/').last
app_name = download_file.split('.tar.gz')[0]
default["postgresql"]["data_dir"] = "#{node['postgresql']['install_dir']}/#{app_name}/data"
default["postgresql"]["log_dir"] = "#{node['postgresql']['data_dir']}/pg_xlog"


# Postgresql database accounts used by the LabKey Server
# Create psuedo-random password
default["postgresql"]["user"] = "labkey"
o =  [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
default["postgresql"]["password"] = (0...50).map{ o[rand(o.length)] }.join

# Sizing the postgresql installation
#
# The default settings will assume you are running a PostgreSQL server on
# a server with ~8GB of memory, like the m1.large instance at AWS.
# - This is identical to defaults of the Tomcat Server
#
default["postgresql"]["shared_buffers"] = "2048MB"
default["postgresql"]["work_mem"] = "20MB"
default["postgresql"]["maint_work_mem"] = "1024MB"
default["postgresql"]["wal_buffers"] = "10MB"
default["postgresql"]["checkpoint_segments"] = "10"
default["postgresql"]["checkpoint_timeout"] = "15min"
default["postgresql"]["random_page_cost"] = "1.4"
default["postgresql"]["effective_cache_size"] = "6144MB"



# PostgreSQL HBA configuration
# If this value is set to false, then we will use the pg_hba.conf.erb
# template, which only allows access to the server from local host.
# - If you want add an additional network, set the value of this
#   attribute to something like 140.107.155.74/24
default["postgresql"]["hba_network"] = "false"

