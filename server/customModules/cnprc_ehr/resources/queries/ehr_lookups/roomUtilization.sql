/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  r.room,
  count(DISTINCT c.cage) as TotalCages,
  max(cbr.availableCages) as AvailableCages,
  count(DISTINCT h.cage) as CagesUsed,
  max(cbr.availableCages) - count(DISTINCT h.cage) as CagesEmpty,
  round(((CAST(count(DISTINCT h.cage) as double)) / cast(max(cbr.availableCages) as double)) * 100, 1) as pctUsed,
  count(DISTINCT h.id) as TotalAnimals,
  count(DISTINCT (case when h.id.demographics.species = 'MMU' then h.id else null end)) as TotalMMUAnimals,
  count(DISTINCT (case when h.id.demographics.species = 'CMO' then h.id else null end)) as TotalCMOAnimals,
  count(DISTINCT (case when h.id.demographics.species = 'MCY' then h.id else null end)) as TotalMCYAnimals,
  count(DISTINCT (case when h.id.demographics.id is null or h.id.demographics.species not in ('MMU','CMO','MCY') then h.id else null end)) as TotalOtherAnimals
FROM ehr_lookups.rooms r
LEFT JOIN (
	SELECT c.room, c.cage
	FROM ehr_lookups.cage c
	WHERE cage is not null

    --allow for rooms w/o cages
	UNION ALL
	SELECT r.room, null as cage
	FROM ehr_lookups.rooms r
) c on (r.room = c.room)
LEFT JOIN study.housing h ON (r.room=h.room AND (c.cage=h.cage OR (c.cage is null and h.cage is null)) AND h.isActive = true)
LEFT JOIN ehr_lookups.availableCagesByRoom cbr ON (cbr.room = r.room)
WHERE r.datedisabled is null
GROUP BY r.room
