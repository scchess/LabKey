/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  d1.id,
  CASE
  WHEN (COALESCE(d1.id.parents.sire, '') = COALESCE(d2.id.parents.sire, '') AND
        COALESCE(d1.id.parents.dam, '') = COALESCE(d2.id.parents.dam, '') AND COALESCE(d1.id.parents.sire, '') != '' AND
        COALESCE(d1.id.parents.dam, '') != '')
    THEN 'Full Sib'
  WHEN (COALESCE(d1.id.parents.sire, '') = COALESCE(d2.id.parents.sire, '') AND COALESCE(d1.id.parents.sire, '') != ''
        AND
        (COALESCE(d1.id.parents.dam, '') != COALESCE(d2.id.parents.dam, '') OR COALESCE(d1.id.parents.dam, '') = ''))
    THEN 'Half-Sib Paternal'
  WHEN (COALESCE(d1.id.parents.dam, '') = COALESCE(d2.id.parents.dam, '') AND COALESCE(d1.id.parents.dam, '') != '' AND
        (COALESCE(d1.id.parents.sire, '') != COALESCE(d2.id.parents.sire, '') OR COALESCE(d1.id.parents.sire, '') = ''))
    THEN 'Half-Sib Maternal'
  WHEN (COALESCE(d1.id.parents.sire, '') != COALESCE(d2.id.parents.sire, '') AND
        COALESCE(d1.id.parents.dam, '') != COALESCE(d2.id.parents.dam, ''))
    THEN 'ERROR'
  END                        AS Relationship,

  d2.id                      AS Sibling,
  d2.gender                  AS Sex,
  d2.id.flagList.values      AS Flags,
  d2.id.curLocation.location AS Location,
  d2.id.parents.dam          AS SiblingDam,
  d2.id.parents.sire         AS SiblingSire,
  d2.calculated_status,
  d2.id.lastHousing.location AS LastKnownLocation,
  d1.qcstate
FROM study.Demographics d1
  JOIN study.Demographics d2
    ON ((d2.id.parents.sire = d1.id.parents.sire OR d2.id.parents.dam = d1.id.parents.dam) AND d1.id != d2.id)
WHERE d2.id IS NOT NULL


