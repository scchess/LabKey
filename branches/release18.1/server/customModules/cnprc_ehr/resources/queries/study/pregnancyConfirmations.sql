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
SELECT conc.*,offspring.id.demographics.calculated_status,
(case when offspring.id.demographics.calculated_status = 'Dead' then
  ('Dead from ' || offspring.id.lastHousing.location)
 else offspring.id.curLocation.location end) as offspringLocation,
 COALESCE (offspring.id.lastHousing.enddate, offspring.id.curLocation.date)  as offspringLocationDate,
 birthViability || deliveryMode as deliveryType,
 timestampdiff('SQL_TSI_DAY',  conc.conception, COALESCE (termDate,now())) AS gestationDays,
 offspring.id.demographics.gender as offspringSex
FROM cnprc_ehr.conceptions conc
LEFT JOIN study.Demographics offspring
  ON conc.offspringid = offspring.id
WHERE
pgFlag IS NULL -- "check CON_INVALID_PG_FLAG for NULL to exclude them" as per high-level data mapping spreadsheet
AND
conc.Id IS NOT NULL;