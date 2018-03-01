#
# Cookbook Name:: sequenceAnalysisTools
# Recipe:: default
#
# Downloads, builds and installs SequenceAnalysis Tools binaries in the /labkey/bin directory.

#
# Variables for the recipe.
#
vagrant_labkey_install_dir = "/vagrant/_labkey"

# Install the packages 
package "gcc"
package "make"
package "expat"
package "mcrypt"
package "gnuplot"
package "swig"
package "unzip"

package "subversion"

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

# Create vagrant_labkey_install_dir if it does not exist
directory vagrant_labkey_install_dir  do
    owner "root"
    group "root"
    mode "0755"
    action :create
    not_if { File.exists?("#{vagrant_labkey_install_dir}") }
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

directory "/labkey/svn"  do
  owner "labkey"
  group "labkey"
  mode "0755"
  recursive true
  action :create
  not_if {File.exists?("/labkey/svn")}
end

# Create/Override the pipelineConfig.xml configuration file
file "#{vagrant_labkey_install_dir}/config/pipelineConfig.xml" do
    action :delete
end

template "#{vagrant_labkey_install_dir}/config/pipelineConfig.xml" do
    source "pipelineConfig.xml.erb"
    mode "0644"
    owner"root"
    group "root"
    variables(
        :lock_dir => "#{vagrant_labkey_install_dir}/syncp-locks",
        :activemq_host => node['labkey']['activemq_host'],
        :labkey_file_root => node['labkey']['labkey_file_root']
    )
    # always do this step, since we expect the default pipeline install to create this
    # not_if { File.exists?("#{vagrant_labkey_install_dir}/config/pipelineConfig.xml") }
end

# Create the sequenceanalysisConfig.xml configuration file
cookbook_file "#{vagrant_labkey_install_dir}/config/sequenceanalysisConfig.xml" do
  source "sequenceanalysisConfig.xml"
  mode "0600"
  owner"root"
  group "root"
  not_if { File.exists?("#{vagrant_labkey_install_dir}/config/sequenceanalysisConfig.xml") }
end

# These are created by the standard LK install, and can cause config problems
file "#{vagrant_labkey_install_dir}/config/microarrayConfig.xml" do
    action :delete
end

file "#{vagrant_labkey_install_dir}/config/ms1Config.xml" do
    action :delete
end

file "#{vagrant_labkey_install_dir}/config/ms2Config.xml" do
    action :delete
end


#
# Download sequence source and run shell script
# 
bash "install-sequencetools"  do
  user "root"
  cwd "/labkey"
  timeout 360000
  code <<-EOH

  #create working directories
  mkdir -p /labkey/remoteTempDir
  chown -R labkey:labkey /labkey/remoteTempDir/
  mkdir -p /vagrant/_labkey/syncp-locks
  chown -R labkey:labkey /vagrant/_labkey/syncp-locks/
  mkdir -p /labkey/logs
  chown -R labkey:labkey /labkey/logs/

  echo "Make sure we're using Oracle Java as the default"
  rm -Rf /usr/lib/jvm/default-java
  ln -s /usr/lib/jvm/jdk1.7.0_45 /usr/lib/jvm/default-java

  #echo "Setting CPAN to autoconfig"
  #if [ $(which cpan) ];
  #  (echo y;echo "o conf prerequisites_policy follow";echo "o conf commit")|cpan
  #fi

  echo "Checking out pipeline code"
  mkdir -p /labkey/svn/trunk

  if [[ ! -e /labkey/svn/trunk/pipeline_code/sequence_tools_install.sh ]];
  then
    mkdir -p /labkey/svn/trunk/pipeline_code/
    svn export --no-auth-cache --username cpas --password cpas https://hedgehog.fhcrc.org/tor/stedi/trunk/externalModules/labModules/SequenceAnalysis/pipeline_code/sequence_tools_install.sh /labkey/svn/trunk/pipeline_code/sequence_tools_install.sh
    chmod +x /labkey/svn/trunk/pipeline_code/sequence_tools_install.sh
    chown -R labkey:labkey /labkey/svn/
  fi

  echo "Running install script"
  mkdir -p /labkey/labkey
  bash /labkey/svn/trunk/pipeline_code/sequence_tools_install.sh -d /labkey -u labkey | tee /labkey/labkey/sequence_install.log

  EOH
end




