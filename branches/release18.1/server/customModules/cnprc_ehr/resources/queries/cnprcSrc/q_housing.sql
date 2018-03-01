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
RELOC_AN_ID AS Id,
RELOC_DATE_IN,
RELOC_DATE_OUT AS enddate,
TRIM(REPLACE(SUBSTRING(RELOC_LOCATION, 1, 7), ' ', '')) AS room,
TRIM(SUBSTRING(RELOC_LOCATION, 8, 2))AS cage,
RELOC_SALE_COMMENT AS reason,
RELOC_SEQ AS reloc_seq,
OBJECTID AS objectid,
DATE_TIME
FROM cnprcSrc.ZRELOCATION
WHERE RELOC_LOCATION IS NOT NULL AND RELOC_LOCATION_PREFIX = '0200';