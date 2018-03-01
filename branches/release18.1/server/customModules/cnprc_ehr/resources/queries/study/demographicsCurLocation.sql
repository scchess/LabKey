/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

  d2.id,

  CASE
  WHEN d2.cage IS NULL
    THEN d2.room
  ELSE (d2.room || d2.cage)
  END                   AS Location,
  d2.room.area,
  d2.room,
  d2.cage,
  ifdefined(d2.cond)    AS cond,
  d2.date,
  d2.reason,
  d2.remark,
  coalesce(d2.room, '') AS room_order,
  d2.room_sortValue @hidden,
COALESCE (d2.cage, '') AS cage_order,
d2.cage_sortValue @hidden,
clh.cage_size cageSize,
clh.rate_class rateClass,
room_enc.supervisor
FROM study.housing d2
INNER JOIN (
select id from study.housing where enddate is null group by id having count(*) = 1
) ensureSingleRecord on ensureSingleRecord.id = d2.id
LEFT JOIN cnprc_ehr.cage_location_history clh ON clh.location = (d2.room || d2.cage) AND clh.to_date IS NULL
LEFT JOIN cnprc_ehr.room_enclosure room_enc ON room_enc.room = d2.room
WHERE d2.enddate IS NULL
AND d2.qcstate.publicdata = TRUE