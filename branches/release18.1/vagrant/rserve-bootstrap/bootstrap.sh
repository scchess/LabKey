#!/usr/bin/env bash

# TODO: Replace with puppet/chef/ansible

# Add FHCRC CRAN mirror to package source list
echo "deb http://cran.fhcrc.org/bin/linux/ubuntu precise/" >> /etc/apt/sources.list

# Add signature for CRAN signed libraries
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

apt-get update

# install R and R dev tools
apt-get install -y r-base
apt-get install -y r-base-dev

# install libcurl which is required for RCurl
apt-get install libcurl4-gnutls-dev

# install Rlabkey
/usr/bin/Rscript -e 'install.packages(pkgs=c("Rlabkey"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))'

# data.table is used by some of the bioC packages
/usr/bin/Rscript -e 'install.packages(pkgs=c("data.table"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))'

# install bioconductor
#/usr/bin/Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(INSTALL_opts=c("--no-multiarch"))'

# install affymetrix packages
/usr/bin/Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite(c("affy", "hthgu133pluspmcdf", "AnnotationDbi"), INSTALL_opts=c("--no-multiarch"))'

# install knitR
/usr/bin/Rscript -e 'install.packages(pkgs=c("knitr"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))'

# install Rserve
/usr/bin/Rscript -e 'install.packages(pkgs=c("Rserve"), repos=c("http://cran.fhcrc.org/"), INSTALL_opts=c("--no-multiarch"))'

# create a user for the Rserve server process
adduser --disabled-password --gecos "" rserve

# get rserve's user and group id
RSERVE_UID=$(id -u rserve)
RSERVE_GID=$(id -g rserve)

# configure Rserve
cat > /etc/Rserv.conf <<__EOF__
# Set encoding of strings to UTF8 instead of server native encoding
encoding utf8

# Location of password file
pwdfile /etc/Rserv.logins

# Read the password file at startup only, which is more efficient than
# reading it for each client connection.
cachepwd indefinitely

# Require users to provide a password, but not in plaintext
remote enable
auth required
plaintext disable

# Normally, the Rserver changes to an unprivileged user on startup. The
# password file would need to readable by this user. As client code also runs
# as the unprivileged user, it could also read the password file, or otherwise
# affect the listening service.
#
# Using the "su client" option, the Rserver runs as root, but when a client
# connects, the client connection handler process reads the password file,
# validates the user, and then changes to the unprivileged user. This
# configuration prevents a client from affecting the listening server or
# reading the password file.
#
# Note that the "su" option must appear before the "gid" and "uid" options,
# otherwise the Rserver changes as soon as it reads the "gid" and "uid" options.
#
su client

# User/group for running client code
gid ${RSERVE_UID}
uid ${RSERVE_GID}
__EOF__


# add login credentials to Rserve for remote connections
cat > /etc/Rserv.logins <<__EOF__
rserve_user rserve_pass
__EOF__

chmod 600 /etc/Rserv.logins

# create an Rserve startup script
cp /vagrant/rserved /etc/init.d/rserved
chmod 755 /etc/init.d/rserved

# add rserved startup script to correct runlevel
update-rc.d rserved defaults

# start up Rserve
/etc/init.d/rserved start


