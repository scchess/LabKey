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
AN_ID As Id,
AN_ACQ_DATE,
AN_SEX As gender,
AN_BIRTHPLACE_GEOG AS geographic_origin,
AN_BIRTH_DATE AS birth,
(CASE WHEN AN_LOCATION_PREFIX = '0000' THEN AN_LOCATION_DATE ELSE NULL END) AS death,
AN_SP_CODE AS species,
(CASE WHEN AN_LOCATION_PREFIX = '0000' THEN 'Dead'
 WHEN AN_LOCATION_PREFIX = '0101' THEN 'Shipped'
 WHEN AN_LOCATION_PREFIX = '0200' THEN 'Alive'
 WHEN AN_LOCATION_PREFIX = '0100' THEN 'Escaped'
 WHEN AN_LOCATION_PREFIX = '0102' THEN 'On Loan'
 WHEN AN_LOCATION_PREFIX = '0103' THEN 'Temp Escape'
 END) AS calculated_status,
AN_SIRE_ID AS sire,
AN_DAM_ID AS dam,
AN_ACQ_SOURCE_INST AS origin,
AN_SPF_STATUS AS spf,
AN_GENERATION AS genNum,
AN_BIRTHPLACE_STATUS AS birthPlaceStatus,
AN_HARVEST_CODE AS harvestCode,
AN_HARVEST_DATE AS harvestDate,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZANIMAL