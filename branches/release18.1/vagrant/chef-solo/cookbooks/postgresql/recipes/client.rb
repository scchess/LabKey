#
# Cookbook Name:: postgresql
# Recipe:: client
#
#

case node[:platform] 
when "ubuntu","debian"
  package "postgresql-client"
when "redhat","centos","fedora"
  package "postgresql-devel"
end
