/*
 * Copyright (c) 2010-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
  oldWeights.Id,
  oldWeights.Id.MostRecentWeight.MostRecentWeightDate AS LatestWeightDate,
  oldWeights.Id.MostRecentWeight.MostRecentWeight AS LatestWeight,
  timestampdiff('SQL_TSI_DAY', oldWeights.date, oldWeights.Id.MostRecentWeight.MostRecentWeightDate) AS IntervalInDays,
  age_in_months(oldWeights.date, oldWeights.Id.MostRecentWeight.MostRecentWeightDate) AS IntervalInMonths,
  oldWeights.weight AS OldWeight,
  round(((oldWeights.Id.MostRecentWeight.MostRecentWeight - oldWeights.weight) * 100 / oldWeights.weight), 1) AS PctChange
FROM
(SELECT oldWeightsWithDupes.Id,
  MAX(oldWeightsWithDupes.date) AS date,  -- all things being equal, pick the more recent date
  MAX(oldWeightsWithDupes.weight) AS weight  -- should all be the same for an animal ID, but need to get down to 1 weight per ID
  FROM
  (
    SELECT largestPastWeightsFull.Id,
    largestPastWeightsFull.weight,
    largestPastWeightsFull.date
    FROM
    (
      SELECT weight.Id,
        MAX(weight.weight) AS weight
      FROM study.weight weight
      WHERE weight.date >= timestampadd('SQL_TSI_DAY', -180, now())
      GROUP BY weight.Id
    ) largestPastWeights
    JOIN study.weight largestPastWeightsFull
      ON largestPastWeightsFull.Id = largestPastWeights.Id
      AND largestPastWeightsFull.weight = largestPastWeights.weight
  ) oldWeightsWithDupes
  GROUP BY oldWeightsWithDupes.Id
) oldWeights
WHERE ((oldWeights.Id.MostRecentWeight.MostRecentWeight - oldWeights.weight) * 100 / oldWeights.weight) <= -10.0
AND oldWeights.Id.Demographics.calculated_status = 'Alive'