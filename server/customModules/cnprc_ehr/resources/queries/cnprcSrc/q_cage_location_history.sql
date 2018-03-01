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
TRIM(REPLACE(ZH_LOCATION_ID, ' ', '')) AS location,
TRIM(REPLACE(ZH_ENCLOSURE_ID, ' ', '')) AS room,
TRIM(SUBSTRING(ZH_LOCATION_ID, 8, 2)) AS cage,
ZH_PK AS location_history_pk,
ZH_CAGE_SIZE AS cage_size,
CASE
  WHEN ZH_CAGE_SIZE IS NULL THEN NULL
  WHEN TRIM (
    TRANSLATE (ZH_CAGE_SIZE,'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', '1234567890')
    ) = '' THEN NULL
  ELSE
  CAST (
    TRANSLATE (ZH_CAGE_SIZE,'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', '1234567890')
    AS INTEGER)
    END
    AS cage_size_number,
ZH_RATE_CLASS AS rate_class,
ZH_FROM_DATE AS from_date,
ZH_TO_DATE AS to_date,
ZH_FILE_STATUS AS file_status,
OBJECTID AS objectid,
DATE_TIME
FROM
cnprcSrc.ZLOCATION_HISTORY
WHERE
(ZH_TO_DATE is null or ZH_TO_DATE > to_date('01-01-1900', 'DD-MM-YYYY') AND ZH_FROM_DATE > to_date('01-01-1900', 'DD-MM-YYYY'));