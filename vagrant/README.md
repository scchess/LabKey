Using LabKey's Vagrant Projects
==================

You can use [Vagrant](http://www.vagrantup.com/) to start new virtual machines and Docker containers for testing and development purposes. These Vagrant projects are configured to work with your development environment. 

## Available Projects: 

### Virtual Machines: 

* rserve: Start a virtual machine running Rserve 
* labkeyRemotePipeline: Start a virtual machine running a LabKey Remote Pipeline Server


### Docker Containers:
* openldap: Start a Docker container running [openLDAP](http://www.openldap.org/). This can be used to test LDAP authentication
* shibboleth: Start a Docker container running [Shibbeloth](https://shibboleth.net/). This can be used to test SAML authentication 


## Setup 

1. Install VirtualBox 5.0.2 or greater (See https://www.virtualbox.org/wiki/Downloads)
2. Install latest version of Vagrant (See http://www.vagrantup.com/downloads.html)
3. (suggested) Install the Vagrant vbguest plugin (https://github.com/dotless-de/vagrant-vbguest)
    (This may be necessary for host/container sync'd folders to function properly)


### Configuration steps for MacOSX users

On MacOSX, update sudoers to allow Vagrant to update the NFS configuration file 
	sudo vi /etc/sudoers 
	(add)
	Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
	Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
	Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports
	%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE

If you skip this step, you will be asked for your password each time you run vagrant up.


## Using
Using these Vagrant projects is simple. 

### Create new virtual machine 
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./rserve`
1. Execute `vagrant up`

That's it. It'll take some time (~10-20min) when executing this command the first time as the command will 

* Download the Vagrant box from http://files.vagrantup.com/precise64.box
* Start the downloaded virtual machine using the installed VirtualBox application
* Execute `chef-solo` to install and configure the virtual machine (ie provisioning)
* Virtual machine vbox file will be located in `./PROJ_DIR/.vagrant/`


### How to acccess a running virtual machine 
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./rserve`
1. Execute `vagrant ssh`

### Reboot a running virtual machine
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./rserve`
1. Execute `vagrant halt`
1. Execute `vagrant up`

### Reload the Vagrantfile
If you change the vagrantfile and/or dockerfile of an already started server and 
pick up the changes, then run
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./openldap`
1. Execute `vagrant halt`
1. Execute `vagrant reload`

### Stop a running virtual machine
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./rserve`
1. Execute `vagrant halt`

### Start a stopped virtual machine
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./rserve`
1. Execute `vagrant up`

### Delete running virtual machine as you are done with it
1. Open a Command Prompt or Terminal window 
1. Goto the project directory you want to start, ie `cd ./rserve`
1. Execute `vagrant destroy`


## Troubleshooting

### See information on the VirtualBox VM
For example to see information on the dockerhost VM 
1. Open a Command Prompt or Terminal window 
1. Execute `VBoxManage showvminfo dockerhost`
	* where `dockerhost` is the name of the VM 

*NOTE:* To see a list of the Shared folders, search for string "Shared Folders:" in the output 

### To find the IP address of the VM
This takes a little bit of work 
1. Goto your `vagrant` directory 
1. open the file `dockerhost/Vagrantfile`
1. Look for variable named `VIP`. This is the IP address of your Virtual box VM


### Debugging
If you want to look at crazy amount of log entries, you add `--debug` to any command.


## Working with Docker Containers 

### How to see if a docker container is running and find out what ports are mapped
1. Open a Command Prompt or Terminal window 
1. Goto the `dockerhost` project directory 
1. Run `vagrant ssh -c "docker ps"`

### How to see both running and stopped containers
1. Open a Command Prompt or Terminal window 
1. Goto the `dockerhost` project directory 
1. Run `vagrant ssh -c "docker ps -a "`

### How to see all images on the docker server 
1. Open a Command Prompt or Terminal window 
1. Goto the `dockerhost` project directory 
1. Run `vagrant ssh -c "docker images"`
 
### How to find detailed information about a running container 
1. Open a Command Prompt or Terminal window 
1. Goto the `dockerhost` project directory 
1. Run `vagrant ssh -c "docker inspect CONTAINER "`

### How to run any docker command on the dockerhost 
1. Open a Command Prompt or Terminal window 
1. Goto the `dockerhost` project directory 
1. Run `vagrant ssh -c "docker CMD....."`

### How access(via ssh) a running Docker container 
1. Open a Command Prompt or Terminal window 
1. Goto the `dockerhost` project directory 
1. Execute `vagrant ssh -c "docker exec -i -t openldap bash"` 
	* where `openldap` is the name of the container. 

