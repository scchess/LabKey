#
# Author:: Brian Connolly
# Cookbook Name:: tomcat
# Attributes:: default
#


# default tomcat attributes.
default['tomcat']['tomcat_version'] = '7'
default['tomcat']['ssl'] = 'true'
default['tomcat']['debug'] = 'false'
default['tomcat']['install_dir'] = '/labkey/apps'
default['tomcat']['download_dir'] = '/labkey/src'
default['tomcat']['tmp_dir'] = '/labkey/tomcat-tmp'

# These attributes configure the memory usage of the tomcat installation
# The defaults values are those used when running on server with 8GB
# of memory, such as m1.large instance at AWS
default['tomcat']['heap_start'] = '512M'
default['tomcat']['heap_max'] = '4096M'
default['tomcat']['permgen_max'] = '192M'

# Download locations for Tomcat
# Tomcat 5.5
default['tomcat']['5.5']['url'] = 'http://archive.apache.org/dist/tomcat/tomcat-5/v5.5.36/bin/apache-tomcat-5.5.36.tar.gz'
# Tomcat 6.0
default['tomcat']['6']['url'] = 'http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz'
# Tomcat 7.0
default['tomcat']['7']['url'] = 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.47/bin/apache-tomcat-7.0.47.tar.gz'
