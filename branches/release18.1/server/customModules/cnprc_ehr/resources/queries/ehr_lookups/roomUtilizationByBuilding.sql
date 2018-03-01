/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  t1.area,
  t1.totalRooms,
  t1.totalCages,
  t1.availableCages,
  t1.cagesUsed,
  t1.cagesEmpty,
  cast(((CAST(t1.cagesUsed as double) / t1.availableCages) * 100) as double) as pctUsed,
  cast((100.0 - ((CAST(t1.cagesUsed as double) / t1.availableCages) * 100)) as double) as pctEmpty,
  t1.totalAnimals,
  t1.totalMMUAnimals,
  t1.totalCMOAnimals,
  t1.totalMCYAnimals,
  t1.totalOtherAnimals

FROM (
SELECT
  r.room.area as area,
  count(DISTINCT r.room) as totalRooms,
  sum(r.totalCages ) as totalCages,
  sum(r.availableCages ) as availableCages,
  sum(r.cagesUsed ) as cagesUsed,
  sum(r.cagesEmpty ) as cagesEmpty,
  sum(r.totalAnimals) as totalAnimals,
  sum(r.totalMMUAnimals) as totalMMUAnimals,
  sum(r.totalCMOAnimals) as totalCMOAnimals,
  sum(r.totalMCYAnimals) as totalMCYAnimals,
  sum(r.totalOtherAnimals) as totalOtherAnimals

FROM ehr_lookups.roomUtilization r
     JOIN cnprc_ehr.room_enclosure re ON re.room = r.room
WHERE re.indoorOutdoorFlag = 'I'
GROUP BY r.room.area

) t1