maintainer          "LabKey"
maintainer_email    "cookbooks@labkey.com"
license             "Apache 2.0"
name                "postgresql"
description         "Install and configure PostgreSQL for use with a LabKey Server"
version             "0.0.1"

%w{ ubuntu debian }.each do |os|
    supports os
end
