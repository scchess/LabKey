#
# Cookbook Name:: tpp
# Recipe:: default
#
# Downloads, builds and installs TPP binaries in the /labkey/bin directory.

# Install the packages 
package "gcc"
package "make"
package "expat"
package "mcrypt"
package "gnuplot"
package "swig"
package "unzip"

# Install more packages where the package names are different on different platforms
case node[:platform] 
when "ubuntu","debian"
  package "libgd-tools"
  package "graphviz"
  package "g++"
  package "libexpat1-dev"
  package "zlib1g-dev"
  package "libbz2-dev"
  package "xsltproc"
  package "libxml-parser-perl"
when "suse"
  package "gd-devel"
  package "graphviz-gd"
  package "gcc-c++"
  package "libexpat-devel"
  package "libexpat1"
  package "zlib-devel"
  package "libbz2-1"
  package "libbz2-devel"
end

# Create Directories 
directory "/labkey/bin"  do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/bin")}
end
# Create Directories 
directory "/labkey/bin/tpp"  do
  owner "root"
  group "root"
  mode "0755"
  action :create
end
# Create Directories 
directory "/labkey/bin/tpp/bin"  do
  owner "root"
  group "root"
  mode "0755"
  action :create
end


#
# Download TPP soruce code from Sourceforge
# 
remote_file "/labkey/src/TPP_4.7.0-src.tgz" do
  source "http://downloads.sourceforge.net/project/sashimi/Trans-Proteomic%20Pipeline%20%28TPP%29/TPP%20v4.7%20%28polar%20vortex%29%20rev%200/TPP_4.7.0-src.tgz"  
  mode "0644"
  owner"root"
  group "root"
  not_if {File.exists?("/labkey/src/TPP_4.7.0-src.tgz")}
end

#
# Compile and install the TPP tools 
# 
bash "install-tpp"  do
  user "root"
  cwd "/labkey/src"
  code <<-EOH
  fqdn_hostname=$(hostname -f)
  tar xzf TPP_4.7.0-src.tgz 2>&1 > /srv/build-logs/$fqdn_hostname-tpp_build.log
  cd /labkey/src/TPP-4.7.0/trans_proteomic_pipeline/src
  echo "XML_ONLY=1" > Makefile.config.incl
  echo "TPP_ROOT=/labkey/bin/tpp/" >>  Makefile.config.incl
  echo "run make all " 2>&1 >> /srv/build-logs/$fqdn_hostname-tpp_build.log
  make all 2>&1 >> /srv/build-logs/$fqdn_hostname-tpp_build.log
  echo "run make install " 2>&1 >> /srv/build-logs/$fqdn_hostname-tpp_build.log
  make install 2>&1 >> /srv/build-logs/$fqdn_hostname-tpp_build.log
  cd /labkey/bin/tpp/bin
  cp -f * /labkey/bin
  chmod -R a+rx /labkey/bin
  EOH
end




