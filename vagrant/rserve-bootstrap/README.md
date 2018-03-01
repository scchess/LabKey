RServe Environment
==================

**NOTE: This is a legacy project. Use the rserve project instead of this project**

This configuration makes is very easy to create an RServe service for local development.  A new virtual machine will be created with everything you need to run RServe as a remote service for a LabKey installation.  This configuration is for development purposes only and isn't recommended for production machines.

### Setup
1. Build [LabKey Server](https://www.labkey.org/wiki/home/Documentation/page.view?name=build)
2. Install [Vagrant](http://www.vagrantup.com) & [VirtualBox](https://www.virtualbox.org)
3. Optional: Set LABKEY_FILEROOT and/or LABKEY_PIPEROOT in your environment to point to an alternate location that match your LabKey Server's file and pipeline roots.  Usually the default setting of `../../build/deploy/files` is sufficient.
4. Execute `vagrant up` within the `vagrant/rserve` directory.
5. That's it. It'll take some time when executing this command the first time. It'll download the Vagrant base box once and install all required packages.

### Configure LabKey Server to use RServe
1. Start up your local build of LabKey Server.
2. Go to the admin console, click on 'Experimental Features', enable the 'Rserve Reports' feature.
3. Go to the admin console, click on 'Views & Scripting'
4. If there is already an ‘R Scripting Engine’ configuration, select and delete it.
5. Add a new R Scripting Engine configuration using the following:
- File extensions: r,R
- Machine name: 192.168.33.10
- Port: 6311
- Remote Report Share: /labkey/reports_temp
- Remote Pipeline Share: /labkey/piperoot
- Remote User: rserve_user
- Remote Password: rserve_pwd

Once configured, all R reports will be passed to the RServe virtual machine and executed.
