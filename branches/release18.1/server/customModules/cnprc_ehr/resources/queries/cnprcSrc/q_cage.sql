/*
 * Copyright (c) 2016 LabKey Corporation
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
ZH_CAGE_TYPE AS cage_type
FROM cnprcSrc.ZLOCATION_HISTORY WHERE ZH_TO_DATE IS NULL AND substring(ZH_LOCATION_ID, 8, 2) IS NOT NULL;