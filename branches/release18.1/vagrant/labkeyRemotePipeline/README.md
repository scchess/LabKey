LabKey Server Remote Pipeline Server Environment
==================

This configuration makes is very easy to create an Remote Pipeline Server for local development.  A new virtual machine will be created with everything you need to run a LabKey Remote Pipeline Server.  This configuration is for development purposes only and isn't recommended for production machines.

## What is in this VM? 

* Ubuntu 12.04LTS Linux OS
* ActiveMQ Server (5.9.0)
    * This is started at boot-time, fully configured and ready to accept connections from your dev workstation
* LabKey Remote Pipeline Server
    * Start/Stop script is created and ready to be used
    * The Default Configuration will 
        * Download 14.1 release bits 
        * Installs LabKey Server binaries 
        * Creates ms2Config.xml, ms1Config.xml, microarrayConfig.xml 
        * Creates and configures pipelineConfig.xml to use locally installed ActiveMQ and listen as the `labkeyRemotePipeline` location
    * LABKEY_HOME directory is accessible via Windows Explorer or Command Prompt at `./vagrant/labkeyRemotePipeline/_labkey`
    * Run your own binaries or configuration files by: 
        * Copying files into `./vagrant/labkeyRemotePipeline/_labkey` directory tree
        * Restart LabKey Remote Pipeline Server using your Command Prompt or Terminal app. 



## Setup

See ../README.md for instructions on setting up and using Vagrant on your computer



## Start a LabKey Remote Pipeline Server  

1. Open a Command Prompt or Terminal window 
2. Goto this directory
1. Optional: Set LABKEY_FILEROOT and/or LABKEY_PIPEROOT in your environment to point to an alternate location that match your LabKey Server's file and pipeline roots.  
    * Usually the default setting of `../../build/deploy/files` is sufficient.
4. Execute `vagrant up`
5. That's it. It'll take some time when executing this command the first time. It'll download the Vagrant base box once and install all required packages.

At this point the `activeMQ` server will be running, but the LabKey Remote Pipeline Server process will not be service will not be started.


### Start the Labkey Remote Pipeline Server process the downloaded version 

1. Execute `vagrant ssh -c 'sudo /etc/init.d/labkeyRemotePipeline start'

You can see the logs from Labkey Remote Pipeline Server process running on the VM at `./vagrant/labkeyRemotePipeline/_labkey/logs/output.log`



### Install custom configuration files

1. Stop the running Labkey Remote Pipeline Server process by executing `vagrant ssh -c 'sudo /etc/init.d/labkeyRemotePipeline stop'`
1. Copy your custom configuration files to `./vagrant/labkeyRemotePipeline/_labkey/config/` directory 
1. Start the running Labkey Remote Pipeline Server process by executing `vagrant ssh -c 'sudo /etc/init.d/labkeyRemotePipeline start'`

You can see the logs from Labkey Remote Pipeline Server process at `./vagrant/labkeyRemotePipeline/_labkey/logs/output.log`



### Install custom build

1. Stop the running Labkey Remote Pipeline Server process by executing `vagrant ssh -c 'sudo /etc/init.d/labkeyRemotePipeline stop'`
1. Copy your the compiled binaries to `./vagrant/labkeyRemotePipeline/_labkey/` directory 
1. Start the running Labkey Remote Pipeline Server process by executing `vagrant ssh -c 'sudo /etc/init.d/labkeyRemotePipeline start'`

You can see the logs from Labkey Remote Pipeline Server process running on the VM at `./vagrant/labkeyRemotePipeline/_labkey/logs/output.log`




## Configure LabKey Server to use the LabKey Remote Pipeline Server
1. Change the `labkey.xml` configuration file used by your local build to use the activeMQ server running on the LabKey Remote Pipeline Server (192.168.10.20)
2. Create custom configuration files which use the `labkeyRemotePipeline` location for tasks you want to run on the LabKey Remote Pipeline Server
3. Start up your local build of LabKey Server.

Now you can start testing. 




