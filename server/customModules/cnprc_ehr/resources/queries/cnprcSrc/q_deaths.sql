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
SELECT
a.AN_ID AS Id,
a.AN_LOCATION_DATE,
a.AN_DEATH_COMMENT AS cause,
a.AN_DAM_ID AS dam,
a.AN_DEATH_TYPE AS manner,
(CASE WHEN a.AN_ID = n.an_id THEN 'TRUE' ELSE 'FALSE' END) AS notAtCenter,
RELOC.OBJECTID AS objectid,
CAST (
  GREATEST(a.date_time, IFNULL (n.date_time,to_date('01-01-1900', 'DD-MM-YYYY')))
AS TIMESTAMP ) AS DATE_TIME
FROM cnprcSrc.ZANIMAL a
JOIN cnprcSrc.ZRELOCATION RELOC ON RELOC.RELOC_AN_ID = A.AN_ID AND RELOC.RELOC_LOCATION_PREFIX = '0000'
LEFT JOIN (SELECT p.reloc_an_id as an_id,
  p.reloc_seq,
  p.reloc_location_prefix,
  p.reloc_location,
  p.reloc_date_in,
  p.reloc_date_out,
  d.date_time as date_time
from cnprcSrc.zrelocation p, cnprcSrc.zrelocation d
where d.reloc_an_id = p.reloc_an_id
  and d.reloc_location_prefix = '0000'
  and d.reloc_seq = p.reloc_seq + 1
  and p.reloc_location_prefix <> '0200'
order by 1) n
ON a.AN_ID = n.an_id
WHERE a.AN_LOCATION_PREFIX = '0000'