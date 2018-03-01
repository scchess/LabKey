# 
# Forked from Nick Stenning's docker-slapd repository (https://github.com/nickstenning/docker-slapd)
# 
# NOTE: To store the data outside the container, mount /var/lib/ldap as a data volume

FROM ubuntu
MAINTAINER LabKey Test Team <test@labkey.com>

# Default configuration: can be overridden at the docker command line
ENV LDAP_ROOTPASS testRootPassword
ENV LDAP_ORGANISATION LabKeyTest
ENV LDAP_DOMAIN test.labkey.local
ENV HOME /

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install slapd
RUN (apt-get update; \
	LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils)

# Add the required files to the container. These files are added to the / directory
ADD slapd.sh /
ADD ldapusers.ldif /

# Clean up container after installation and configuration 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 389

# Configure the LDAP server and start the slapd process. 
CMD ["/slapd.sh"]
