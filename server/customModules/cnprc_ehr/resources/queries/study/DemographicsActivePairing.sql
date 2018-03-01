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
  p.id,
  group_concat(DISTINCT pairedWithId, ', ') as pairedWithIds,
  group_concat(DISTINCT observation, ', ') AS observations,
  max(symbol.PairedSymbol ) as pairedSymbol
  FROM study.pairings p
    inner join
    (SELECT
          pair1.id,
       CASE
       WHEN (pair2.Id IS NULL) AND (pair1.observation <> 'AW')
         THEN 'DD'
       WHEN (SELECT COUNT(*)
             FROM study.pairings pair3
             WHERE pair3.Id = a.Id
                   AND pair3.endDate IS NULL)
            > 1
         THEN '**'
       -- CAST is for natural sort
       WHEN CAST(pair1.Id.curLocation.cage AS INTEGER) < CAST(pair2.Id.curLocation.cage AS INTEGER)
         THEN '//'
       WHEN CAST(pair1.Id.curLocation.cage AS INTEGER) > CAST(pair2.Id.curLocation.cage AS INTEGER)
         THEN '\\'
       WHEN pair1.Id < pair2.Id
         THEN '//'
       WHEN pair1.Id > pair2.Id
         THEN '\\'
       END AS PairedSymbol
     FROM study.demographics a
       JOIN study.pairings pair1 ON pair1.Id = a.Id
       LEFT OUTER JOIN study.pairings pair2 ON pair2.pairId = pair1.pairId
                                               AND pair2.Id <> a.Id
     WHERE pair1.endDate IS NULL

  AND a.id.curLocation.location IS NOT NULL) symbol on symbol.id = p.id

WHERE enddate IS NULL
GROUP BY p.id