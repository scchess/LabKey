/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  demo.id,
  demo.birth,
  COALESCE(demo.id.MostRecentArrival.EarliestArrival, demo.birth) AS earliestArrivalOrBirthDate,
  COALESCE(demo.id.MostRecentArrival.MostRecentArrival, demo.birth) AS latestArrivalOrBirthDate,
  CASE
  WHEN demo.calculated_status = 'Alive' THEN CAST(now() AS DATE)
  WHEN demo.calculated_status = 'Dead' THEN deaths.date
  WHEN (demo.calculated_status = 'Shipped') OR (demo.calculated_status = 'Escaped') THEN demo.Id.MostRecentDeparture.MostRecentDeparture
  ELSE NULL END AS timeAtCnprcEndDate,
  CASE
  WHEN demo.Id.MostRecentDeparture.MostRecentDeparture IS NOT NULL THEN demo.Id.MostRecentDeparture.MostRecentDeparture
  WHEN demo.calculated_status = 'Dead' THEN demo.Id.lastHousing.enddate
  ELSE NULL END AS departureOrLastHousingDate
FROM study.demographics demo
LEFT JOIN study.deaths
       ON deaths.Id = demo.Id