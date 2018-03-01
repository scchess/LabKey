/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
SELECT
  d.id,
  coalesce(p2.parent, d.dam) as dam,
  CASE
    WHEN d.id.demographicsBirthInfo.femaleGeneticsVerify IS NOT NULL THEN 'Genetic'
    WHEN d.dam IS NOT NULL THEN 'Observed'
    ELSE null
  END as damType,
  coalesce(p1.parent, d.sire) as sire,
  CASE
    WHEN d.id.demographicsBirthInfo.maleGeneticsVerify IS NOT NULL THEN 'Genetic'
    WHEN d.sire IS NOT NULL THEN 'Observed'
    ELSE null
  END as sireType,
  CASE
    WHEN (coalesce(p2.parent, d.dam) IS NOT NULL AND coalesce(p1.parent, d.sire) IS NOT NULL) THEN 2
    WHEN (coalesce(p2.parent, d.dam) IS NOT NULL OR coalesce(p1.parent, d.sire) IS NOT NULL) THEN 1
    ELSE 0
  END as numParents
FROM study.demographics d
LEFT JOIN (
  select p1.id, max(p1.parent) as parent
  FROM study.parentage p1
  WHERE  p1.relationship = 'Sire'
  GROUP BY p1.Id
) p1 ON (d.Id = p1.id)
LEFT JOIN (
  select p2.id, max(p2.parent) as parent
  FROM study.parentage p2
  WHERE p2.relationship = 'Dam'
  GROUP BY p2.Id
) p2 ON (d.Id = p2.id)
