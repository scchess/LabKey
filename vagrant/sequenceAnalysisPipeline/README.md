SequenceAnalysis Remote Pipeline Server Environment
==================

This configuration makes is very easy to create an Remote Pipeline Server for local development.  A new virtual machine will be created with everything you need to run a LabKey Remote Pipeline Server.  This configuration is for development purposes only and isn't recommended for production machines.

This is patterned after the labkeyRemotePipeline configuration.  Please refer to that README for additional information.  The key differences are:

* Expects ActiveMQ to run on the host machine
* Creates sequenceanalysisConfig.xml
* Creates and configures pipelineConfig.xml to use locally installed ActiveMQ and listen as the `remotepipelinevagrant` location
* Uses a base docker image, built off dockerhub, which contains the sequence external tools
* Rsyncs and uses the build dir of the local enlistment