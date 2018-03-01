/*
 * Copyright (c) 2011-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

c.lsid,
c.id,
c.date,
c.gender,
c.species,
c.testId,
 c.alertOnAbnormal,
 c.alertOnAny,
c.result,
c.resultOORIndicator,
c.AgeAtTime,
ac.ageClass,
r.ref_range_min,
r.ref_range_max,
-- r.key,
-- ac."min",
-- ac."max",
round(convert(r.ref_range_min, numeric), 2) || '-' || round(convert(r.ref_range_max, numeric), 2) as range,
CASE
WHEN convert(c.result, double) >= r.ref_range_min AND convert(c.result, double) <= r.ref_range_max
  THEN 'Normal'
WHEN convert(c.result, double) < r.ref_range_min
  THEN 'Low'
WHEN convert(c.result, double) > r.ref_range_max
  THEN 'High'
END as status,
c.taskid,
c.qcstate

FROM
          (
            SELECT
            c.lsid,
            c.id.dataset.demographics.gender as gender,
            c.id.dataset.demographics.species as species,
            c.testId,
             c.testid.alertOnAbnormal as alertOnAbnormal,
             c.testid.alertOnAny as alertOnAny,
            c.result,
            c.resultOORIndicator,
            c.taskid,
            c.qcstate,
            c.id,
            c.date,
              ROUND(CONVERT(age_in_months(c.id.dataset.demographics.birth, c.date), DOUBLE) / 12, 1) as AgeAtTime
             FROM "Immunology Results" c
             WHERE c.qcstate.publicdata = true
          ) c

LEFT JOIN ehr_lookups.ageclass ac
ON (
c.ageAtTime >= ac."min" AND
(c.ageAtTime < ac."max" OR ac."max" is null) AND
c.species = ac.species
)

LEFT JOIN ehr_lookups.lab_test_range r ON (
c.testId = r.test AND
c.species = r.species AND
ac.ageClass = r.age_class AND
c.gender = r.gender and
r.type = 'Immunology'
)

