#
# Author:: Brian Connolly
# Cookbook Name:: labkeyServer
# Attributes:: default
#


# default LabKey Server attributes.
default['labkey']['server']['install_dir'] = '/labkey/labkey'
default['labkey']['server']['download_dir'] = '/labkey/src/labkey'
default['labkey']['server']['labkey_version'] = '13.3'
default['labkey']['server']['allow_search_engines'] = 'false'

# Download locations for LabKey Server
# LabKey 12.2
default['labkey']['server']['13.2']['url'] = 'http://labkey.s3.amazonaws.com/downloads/general/r/13.2/LabKey13.2-27552-bin.tar.gz'
# LabKey 12.3
default['labkey']['server']['12.3']['url'] = 'http://labkey.s3.amazonaws.com/downloads/general/r/12.3/LabKey12.3-23670-bin.tar.gz'
# LabKey TeamCity (ie a development version)
default['labkey']['server']['teamcity']['url'] = 'http://teamcity.labkey.org:8080/guestAuth/repository/download/bt127/lastSuccessful/standard/LabKey12.3Dev-22774-bin.tar.gz'
# LabKey 13.3
default['labkey']['server']['13.3']['url'] = 'http://labkey.s3.amazonaws.com/downloads/general/r/13.3/LabKey13.3-29491-bin.tar.gz'
# LabKey 14.1
default['labkey']['server']['14.1']['url'] = 'http://labkey.s3.amazonaws.com/downloads/general/d/beta/LabKey14.1Beta-31315-bin.tar.gz'
