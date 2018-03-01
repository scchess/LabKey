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
a.AN_ACQ_DATE,
a.AN_BIRTH_DATE AS birth,
(CASE WHEN a.AN_BIRTH_DATE_EST = 'E' THEN 'TRUE' ELSE 'FALSE' END) AS estimated,
(CASE WHEN r.RELOC_SEQ = 0 THEN TRIM(REPLACE(SUBSTRING(r.RELOC_LOCATION, 1, 7), ' ', '')) ELSE NULL END) AS initialRoom,
(CASE WHEN r.RELOC_SEQ = 0 THEN TRIM(SUBSTRING(r.RELOC_LOCATION, 8, 2)) ELSE NULL END) AS initialCage,
a.AN_SP_CODE AS species,
a.AN_SIRE_ID AS sire,
a.AN_DAM_ID AS dam,
a.AN_SEX AS gender,
(SELECT g.GEOG_NAME FROM cnprcSrc.ZGEOGRAPHIC g WHERE a.AN_BIRTHPLACE_GEOG = g.GEOG_CODE) AS geographic_origin,
a.AN_ACQ_TYPE AS AcquisitionType,
a.AN_PREV_ID AS arrivalId,
a.AN_ACQ_SOURCE_INST AS source,
a.AN_BIRTHPLACE AS birthPlace,
r.OBJECTID AS objectid,
CAST(CASE WHEN(r.DATE_TIME > a.DATE_TIME)
  THEN
    r.DATE_TIME
  ELSE a.DATE_TIME
END  AS TIMESTAMP )AS date_time
FROM cnprcSrc.ZRELOCATION r
LEFT JOIN  cnprcSrc.ZANIMAL a
ON a.AN_ID = r.RELOC_AN_ID
WHERE a.AN_ACQ_TYPE = '1' AND r.RELOC_DATE_IN = a.AN_ACQ_DATE AND r.RELOC_LOCATION_PREFIX = '0200';