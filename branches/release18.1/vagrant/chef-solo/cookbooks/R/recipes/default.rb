#
# Cookbook Name:: R
# Recipe:: default
#
# Recipe for Installing Required R binaries and packages for use 
# with a LabKey Server
#

#
# Add the FHCRC CRAN mirror to the package source list
# 
case node['platform']
when "ubuntu"
	apt_repository 'FHCRC-cran' do
		uri          'http://cran.fhcrc.org/bin/linux/ubuntu'
		components   ['precise/']
		keyserver    'keyserver.ubuntu.com'
		key          'E084DAB9'
	end
end

#
# Install required packages 
#
case node['platform']
when "centos", "redhat", "fedora"
 	# Add packages here
when "ubuntu", "debian"
	package "r-base"
	package "r-recommended"
	package "r-base-dev"
	package "curl"
	package "libcurl4-openssl-dev"
	package "libgd2-xpm-dev"
	package "libcairo2"
	package "libcairo2-dev"
	package "libxt-dev"
end

#
# Install standard set of R packages
#
script "install R packages from CRAN" do
	interpreter "bash"
	user "root" 
	cwd "/tmp"
	code <<-EOH
	fqdn_hostname=#{node[:fqdn]}
	echo " " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "Install Rlabkey " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	/usr/bin/Rscript -e 'install.packages(pkgs=c("Rlabkey"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))' >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1 2>&1
	echo " " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "Install data.table is used by some of the bioC packages " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	/usr/bin/Rscript -e 'install.packages(pkgs=c("data.table"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))' >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1 2>&1
	echo " " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "Install affymetrix " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	/usr/bin/Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(c("affy", "hthgu133pluspmcdf", "AnnotationDbi"), INSTALL_opts=c("--no-multiarch"))' >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1 2>&1
	echo " " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "Install knitR " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	/usr/bin/Rscript -e 'install.packages(pkgs=c("knitr"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))' >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1 2>&1
	echo " " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "Install Rserve " >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	echo "==============================================================" >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1
	/usr/bin/Rscript -e 'install.packages(pkgs=c("Rserve"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))' >> /srv/build-logs/$fqdn_hostname-R-install.log 2>&1 2>&1
	touch /srv/srv-info/RPackagesInstalled.created
	EOH
	not_if {File.exists?("/srv/srv-info/RPackagesInstalled.created")}
end




