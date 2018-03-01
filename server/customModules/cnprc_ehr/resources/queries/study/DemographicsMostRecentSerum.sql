/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

mostRecentSerum.id,
mostRecentSerum.MostRecentSerumDate,
timestampdiff('SQL_TSI_DAY', mostRecentSerum.MostRecentSerumDate, now()) AS DaysSinceSample

FROM (
SELECT
  s.Id AS Id,
  max(s.date) AS MostRecentSerumDate

FROM study.serum s

GROUP BY s.id
) mostRecentSerum
