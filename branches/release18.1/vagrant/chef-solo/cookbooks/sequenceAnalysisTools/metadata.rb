maintainer          "LabKey"
maintainer_email    "bbimber@gmail.com"
license             "Apache 2.0"
name                "sequenceAnalysisTools"
description         "Install SequenceAnalysis pipeline toolset"
version             "0.0.1"

%w{ ubuntu debian }.each do |os|
    supports os
end
