/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

mostRecentTetanus.id,
mostRecentTetanus.MostRecentTetanusDate,
timestampdiff('SQL_TSI_DAY', mostRecentTetanus.MostRecentTetanusDate, now()) AS DaysSinceTetanus,
mostRecentTetanus.TetanusCount


FROM (
SELECT
  d.Id AS Id,
  max(d.date) AS MostRecentTetanusDate,
  count(*) as TetanusCount
FROM study.drug d
where code in ('T', 'ET')
GROUP BY d.id
) mostRecentTetanus