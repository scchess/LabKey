/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
  d.id,
  d.calculated_status,
  s.*,
  s.objectid AS treatmentid
FROM study.demographics d
  JOIN (
         SELECT
           s.*,
           CASE
           WHEN (hours >= 6 AND hours < 20)
             THEN 'AM'
           WHEN (hours < 6 OR hours >= 20)
             THEN 'PM'
           ELSE 'Other'
           END                          AS timeOfDay,
           ((s.hours * 60) + s.minutes) AS timeOffset
         FROM (
                SELECT
                  t1.lsid,
                  t1.objectid,
                  t1.dataset,
                  t1.id                                                                      AS animalid,
                  coalesce(tt.time, ft.hourofday, ((hour(t1.date) * 100) + minute(t1.date))) AS time,
                  (coalesce(tt.time, ft.hourofday, (hour(t1.date) * 100)) / 100)             AS hours,
                  CASE
                  WHEN (tt.time IS NOT NULL OR ft.hourofday IS NOT NULL)
                    THEN (((coalesce(tt.time, ft.hourofday) / 100.0) - floor(coalesce(tt.time, ft.hourofday) / 100)) *
                          100)
                  ELSE minute(t1.date)
                  END                                                                        AS minutes,
                  CASE
                  WHEN (tt.time IS NULL)
                    THEN 'Default'
                  ELSE 'Custom'
                  END                                                                        AS timeType,

                  CASE
                  WHEN snomed.code IS NOT NULL
                    THEN 'Diet'
                  ELSE t1.category
                  END                                                                        AS category,
                  t1.frequency.definition                                                    AS frequency,
                  t1.date                                                                    AS startDate,
                  t1.enddate,
                  t1.projectCode,
                  t1.drugName,
                  t1.volume,
                  t1.vol_units,
                  t1.concentration,
                  t1.conc_units,
                  t1.amount,
                  t1.amount_units,
                  t1.amountWithUnits,
                  t1.amountAndVolume,
                  t1.dosage,
                  t1.dosage_units,
                  t1.qualifier,
                  t1.route,
                  t1.reason,
                  t1.performedby,
                  t1.remark,
                  t1.qcstate
                FROM study."Treatment Orders" t1
                  LEFT JOIN ehr.treatment_times tt ON (tt.treatmentid = t1.objectid)
                  LEFT JOIN ehr_lookups.treatment_frequency_times ft
                    ON (ft.frequency = t1.frequency.definition AND tt.rowid IS NULL)

                  LEFT JOIN (
                              SELECT sc.code
                              FROM ehr_lookups.snomed_subset_codes sc
                              WHERE sc.primaryCategory = 'Diet'
                              GROUP BY sc.code
                            ) snomed ON snomed.code = t1.code
                WHERE t1.date IS NOT NULL
              ) s
       ) s ON (s.animalid = d.id)
WHERE d.calculated_status = 'Alive'
      AND now() >= s.startDate AND (now() <= s.enddate OR s.enddate IS NULL)