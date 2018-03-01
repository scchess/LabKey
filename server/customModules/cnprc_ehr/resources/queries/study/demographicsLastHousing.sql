/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  d2.id,
  -- Adding case statement because when cage is null no value is returned even when there is a room.
  CASE WHEN max(d2.cage) IS NULL
    THEN
      max(d2.room)
  ELSE (max(d2.room) || MAX (d2.cage)) END AS Location,
  max(d2.room.area)                               AS area,
  max(d2.room)                                    AS room,
  max(d2.cage)                                    AS cage,
  max(h.maxDate)                                  AS date,
  max(h.enddate)                                  AS enddate
FROM study.housing d2
  JOIN (SELECT
          id,
          max(date)      AS maxDate,
          max(enddate)   AS enddate,
          max(reloc_seq) AS reloc_seq
        FROM study.housing h
        GROUP BY id) h
    ON ((h.reloc_seq IS NULL AND h.id = d2.id AND d2.date = h.maxdate) OR
        (h.reloc_seq IS NOT NULL AND h.id = d2.id AND h.reloc_seq = d2.reloc_seq))
WHERE d2.qcstate.publicdata = TRUE
GROUP BY d2.id
