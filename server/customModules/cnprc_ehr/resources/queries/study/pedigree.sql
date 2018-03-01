/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
d.id as Id,
d.dam as Dam,
d.sire as Sire,
CASE (d.id.demographics.gender)
  WHEN 'M' THEN 1
  WHEN 'F' THEN 2
  ELSE 3
END AS gender,
d.id.demographics.gender as gender_code,
CASE (d.id.demographics.calculated_status)
  WHEN 'Alive' THEN 0
  ELSE 1
END
AS status,
d.id.demographics.calculated_status as status_code,
d.id.demographics.species,
'DOB:' || COALESCE(CAST(CAST(d.id.Demographics.birth AS DATE) AS VARCHAR), 'NA')
    || '|Birth Loc: ' || COALESCE(d.id.DemographicsBirthPlace.birthPlace, 'NA')
    || '|Gen:' || d.id.Demographics.genNum
    || '|Flags:' || COALESCE(d.id.activeFlagList.Values, 'None')
    as Display,
'Demographics' as source
FROM study.demographics d