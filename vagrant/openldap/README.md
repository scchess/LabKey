OpenLDAP Docker Container 
==================

This configuration makes is very easy to start a LDAP server for local development. The `dockerhost` virtual machine will be created (or started, if it is already created) and a Docker Container will be started running OpenLDAP. This configuration is for development purposes only and isn't recommended for production machines.


## What is in this Docker Container

* Latest version of Ubuntu Linux OS
* openLDAP
	* This is started at boot-time and is fully configured and ready to accept connections from your dev workstation 
	* Listens on 192.168.10.30:389
	* Two user accounts are available for your use: 
		* email: dev1@test.labkey.local
			* username: dev1
			* password: yeahforDocker2
		* email: tester1@test.labkey.local
			* username: tester1
			* password: yeahforDocker1


## Setup 

See ../README.md for instructions on setting up and using Vagrant on your computer


## Start the openLDAP server 

1. Open a Command Prompt or Terminal window 
1. Goto this directory
1. Execute `vagrant up`

That's it. It'll take some time when executing this command the first time. It'll download the Vagrant base box once and install all required packages.


## Configure your LabKey Server to use the LDAP server 

1. Start your LabKey Server 
1. Goto the Authentication Admin Console 
1. Click on `configure` link next to LDAP 
1. Use the following settings 
	* LDAP server URLs: `ldap://192.168.10.30:389
	* LDAP domain: `test.labkey.local`
	* LDAP principal template: `mail=${email},dc=test,dc=labkey,dc=local`
1. Hit Save

## Testing
Use the *TEST LDAP SETTINGS* link to verify the configuation. From the LDAP config test page use values like:
   LDAP Server Url: ldap://192.168.10.30:389
   Security Principle: mail=tester1@test.labkey.local,dc=test,dc=labkey,dc=local
   Password: <as configured in /vagrant/openldap/slapd/ldapusers.ldif>

Then enable LabKey LDAP authentiation and login from the regular login page as: tester1@test.labkey.local or  dev1@test.labkey.local

## Troubleshooting

See the **Troubleshooting** section in the ../README.md file for more information. 

### How to access the openLDAP server logs 

1. Open a Command Prompt or Terminal window 
1. Goto this directory
1. Execute `vagrant ssh`
1. Execute `cd /var/lib/ldap`
	* All log files are in this directory. 











