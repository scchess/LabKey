/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
d.id,
d.gender,
'Offspring' as Relationship,
d2.id  AS Offspring,
d2.birth,
d2.gender as Sex,
d2.id.flagList.values as Flags,
d2.id.curLocation.location as Location,
d2.calculated_status,
d2.id.lastHousing.location AS LastKnownLocation,
d.qcstate
FROM study.Demographics d
INNER JOIN study.Demographics d2
  ON ((d2.id.parents.sire = d.id OR d2.id.parents.dam = d.id) AND d.id != d2.id)

