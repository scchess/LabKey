RServe Environment
==================

This configuration makes is very easy to create an RServe service for local development.  A new virtual machine will be created with everything you need to run RServe as a remote service for a LabKey installation.  This configuration is for development purposes only and isn't recommended for production machines.

This is the very similiar to <labkey>/vagrant/rserve, but includes a newer version of ubuntu, uses chef_zero, and include knitr/rmarkdown/pandoc

## Setup

See ../README.md for instructions on setting up and using Vagrant on your computer


## Start a RServe server 

1. Open a Command Prompt or Terminal window 
2. Goto this directory
1. Optional: Set LABKEY_FILEROOT and/or LABKEY_PIPEROOT in your environment to point to an alternate location that match your LabKey Server's file and pipeline roots.  
    * Usually the default setting of `../../build/deploy/files` is sufficient.
4. Execute `vagrant up`
5. That's it. It'll take some time when executing this command the first time. It'll download the Vagrant base box once and install all required packages.


## Configure LabKey Server to use RServe
1. Start up your local build of LabKey Server.
2. Go to the admin console, click on 'Experimental Features', enable the 'Rserve Reports' feature.
3. Go to the admin console, click on 'Views & Scripting'
4. If there is already an ‘R Scripting Engine’ configuration, select and delete it.
5. Add a new Remote R Engine configuration using the following:
- File extensions: r,R
- Machine name: 192.168.10.20
- Port: 6311
- path mapping entry: [local] file:/C:/tomcat/temp/reports_temp/ -> [remote] file:/labkey/reports_temp
- path mapping entry: [local] file:/C:/labkey/trunk/build/deploy/files/ -> [remote] file:/labkey/piperoot
- Remote User: rserve_user
- Remote Password: rserve_pass

Once configured this way, all R reports will be passed to the RServe virtual machine and executed.

Note that is possible to configure both a local and remote R scripting engine configuration if the RServe Report feature has been enabled.  If you do have
both a local and remote R engine enabled then you need to tell LabKey how you want your R report to run.  By default, LabKey will run any R report against the local R scripting engine.
To indicate that a specific R report should run against a remote R engine (Rserve), you need to include a report metadata file with the <scriptEngine remote="true"/> element.  For example, given a module
report called 'example.R', you would need to add a file called 'example.report.xml' with the following contents:
<?xml version="1.0" encoding="UTF-8"?>
<ReportDescriptor>
     <hidden>true</hidden>
     <description>sample R Report metadata file that picks up the remote engine</description>
     <reportType>
         <R>
             <scriptEngine remote="true"/>
         </R>
     </reportType>
</ReportDescriptor>
