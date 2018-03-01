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
--  Adaptation of menseDay1.sql from ONPRC
SELECT
  t.Id,
  t.date,
  t.observationCode AS observation,
  t.previousMens,
  timestampdiff('SQL_TSI_DAY', t.previousMens, t.date) as daysSinceLastMens
FROM (
  SELECT
    menses1.Id,
    menses1.date as date,
    menses1.observationCode,
    (SELECT max(menses2.date) FROM study.menses menses2
    WHERE menses2.Id = menses1.Id and menses2.date < menses1.date group by menses2.Id) as previousMens
    FROM study.menses menses1
  ) t
WHERE (timestampdiff('SQL_TSI_DAY', t.previousMens, t.date)) > 14
