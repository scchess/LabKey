/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  sub.room enclosure,
  sub.cage_size,
  count(DISTINCT sub.HousingId) as Animals,
  count(DISTINCT (case when (sub.HousingId is not null) then sub.cage else null end)) as cageOccupancy,
  count(DISTINCT sub.cage) as cages,
  group_concat((case when (sub.HousingId is null) then sub.cage else null end),', ') as emptyCages
from
(
  select
    r.room,
    clh.cage_size,
    c.cage,
    h.id HousingId,
    clh.file_status CageLocationHistoryStatus,
    re.file_status RoomEnclosureFileStatus
  FROM ehr_lookups.rooms r
  LEFT JOIN (
    SELECT c.room, c.cage
    FROM ehr_lookups.cage c
    WHERE cage is not null
    ) c on (r.room = c.room)
  LEFT JOIN study.housing h ON (r.room=h.room AND c.cage=h.cage AND h.enddate is null)
  join cnprc_ehr.cage_location_history clh on clh.location = c.room || c.cage and clh.to_date is null
  join cnprc_ehr.room_enclosure re on re.room = r.room
  WHERE
  (clh.file_status = 'AC' and
  re.file_status = 'AC')
   and clh.cage_size is not null
) sub
GROUP BY sub.room, sub.cage_size
having count(case when (sub.HousingId is null) then 1 else null end) > 0

