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

-- living animals at center
SELECT
  payor.Id,
  MAX(payor.date) AS lastPayorDate,
  CAST(group_concat(payor.payor_id) AS VARCHAR) AS lastPayorId,
  MAX(demo.calculated_status) AS animalStatus  -- should only ever be one, MAX() is to make SQL happy
FROM study.payor_assignments payor
  JOIN study.demographics demo
    ON demo.Id = payor.Id
WHERE payor.enddate is NULL
      AND demo.calculated_status = 'Alive'
GROUP BY payor.Id

UNION ALL

-- all other animals
SELECT payor1.Id,
  payor1.date AS lastPayorDate,
  CAST(payor1.payor_id AS VARCHAR) AS lastPayorId,
  demo.calculated_status AS animalStatus
FROM (SELECT payor2.Id,
        MAX(payor2.date) AS mostRecentPayorDate
      FROM study.payor_assignments payor2
      GROUP BY payor2.Id) max_payors,
  study.payor_assignments payor1
  JOIN study.demographics demo
    ON demo.Id = payor1.Id
WHERE demo.calculated_status <> 'Alive'
      AND payor1.lsid =
          (SELECT payor3.lsid
           FROM study.payor_assignments payor3
           WHERE payor3.date = max_payors.mostRecentPayorDate
                 AND payor3.Id = max_payors.Id
           LIMIT 1)