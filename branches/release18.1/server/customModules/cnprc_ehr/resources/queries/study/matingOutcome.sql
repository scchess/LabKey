/*
 * Copyright (c) 2013-2017 LabKey Corporation
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

/* adaptation of onprc's matingOutcome.sql */
SELECT
mating.Id,
mating.male,
mating.date,
count(distinct pc.offspringId) as births,
group_concat(distinct pc.offspringId) as offspring
FROM
(SELECT
  m.id,
  m.male,
  m.date
FROM study.matings m
GROUP BY
  m.id, m.male, m.date) mating
LEFT JOIN
study.pregnancyConfirmations pc
ON
pc.id = mating.id AND
pc.sire = mating.male AND
mating.date < pc.conception AND
TIMESTAMPDIFF('SQL_TSI_DAY', mating.date, pc.conception) < 180
LEFT JOIN
(SELECT * FROM study.birth) birth
ON (birth.Id = pc.offspringId AND mating.date < birth.date AND TIMESTAMPDIFF('SQL_TSI_DAY', mating.date, birth.date) < 180)
GROUP BY mating.id, mating.male, mating.date