/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
-- authored by client
-- LK added objectid
-- LK removed order by as it breaks merge
-- LK added date_time
SELECT
departs.reloc_an_id AS Id,
(CASE WHEN departs.reloc_location_prefix = '0100' THEN 'Escaped'
      WHEN departs.reloc_location_prefix = '0101' THEN 'Shipped'
      WHEN departs.reloc_location_prefix = '0102' THEN 'On Loan'
      WHEN departs.reloc_location_prefix = '0103' THEN 'Tmp Escp'
 END) AS reloctype,
departs.reloc_location AS destination,
departs.reloc_date_in, -- Date the animal left the center, some return
departs.reloc_sale_comment AS remark,
(CASE WHEN returns.reloc_location_prefix = '0000' THEN 'Dead'
      WHEN returns.reloc_location_prefix = '0100' THEN 'Escaped'
      WHEN returns.reloc_location_prefix = '0101' THEN 'Shipped'
      WHEN returns.reloc_location_prefix = '0102' THEN 'On Loan'
      WHEN returns.reloc_location_prefix = '0103' THEN 'Tmp Escp'
      WHEN returns.reloc_location_prefix = '0200' THEN 'Here'
 END) AS nextreloctype,
departs.OBJECTID AS objectid,
GREATEST(departs.DATE_TIME, COALESCE(returns.DATE_TIME, to_date('01-01-1900', 'DD-MM-YYYY'))) AS DATE_TIME
FROM
  cnprcSrc.ZRELOCATION departs
     LEFT OUTER JOIN cnprcSrc.ZRELOCATION returns
          ON (returns.reloc_an_id = departs.reloc_an_id AND returns.reloc_seq = departs.reloc_seq + 1)
WHERE departs.reloc_location_prefix IN ('0100', '0101', '0102', '0103')
