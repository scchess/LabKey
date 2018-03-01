maintainer          "LabKey"
maintainer_email    "cookbooks@labkey.com"
license             "Apache 2.0"
name                "R"
description         "Install and configure R"
version             "0.0.1"

%w{ ubuntu debian }.each do |os|
    supports os
end
