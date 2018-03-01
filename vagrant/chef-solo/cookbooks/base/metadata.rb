maintainer          "LabKey"
maintainer_email    "cookbooks@labkey.com"
license             "Apache 2.0"
name                "base"
description         "Configuration changes required for every server"
version             "0.0.1"

%w{ ubuntu debian }.each do |os|
    supports os
end
