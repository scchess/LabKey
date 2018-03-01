/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

mostRecentTB.id,
mostRecentTB.MostRecentTBDate,
timestampdiff('SQL_TSI_DAY', mostRecentTB.MostRecentTBDate, now()) AS DaysSinceTB


FROM (
SELECT
  tb.Id AS Id,
  max(tb.date) AS MostRecentTBDate
FROM study.tb tb
GROUP BY tb.id
) mostRecentTB